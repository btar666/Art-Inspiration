import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_refresh_scroll_view.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';
import '../../data/models/catalog_snapshot.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../search/data/models/search_filter_state.dart';
import '../../../search/presentation/providers/search_filter_provider.dart';
import '../providers/products_provider.dart';
import 'home_category_chips.dart';
import 'home_product_card.dart';
import 'home_product_card_metrics.dart';
import 'home_promo_banner.dart';
import 'home_scroll_metrics.dart';
import 'home_top_section.dart';

/// محتوى الصفحة الرئيسية القابل للتمرير
class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final position = widget.scrollController.position;
    if (position.pixels < position.maxScrollExtent - 320) return;
    ref.read(catalogProvider.notifier).loadMore();
  }

  void _onCategorySelected(int index, List<String> categories) {
    final category = categories[index.clamp(0, categories.length - 1)];
    ref.read(catalogProvider.notifier).selectCategory(category);
  }

  int _selectedCategoryIndex(CatalogSnapshot catalog, List<String> categories) {
    final index = categories.indexOf(catalog.activeCategory);
    return index >= 0 ? index : 0;
  }

  Future<void> _onRefresh() async {
    // العودة للأعلى حتى يظهر التحديث بعد تحميل صفحات كثيرة
    if (widget.scrollController.hasClients) {
      widget.scrollController.jumpTo(0);
    }

    ref.invalidate(sliderProvider);
    await ref.read(catalogProvider.notifier).refresh();
  }

  void _openSearchPage() => context.go(AppRoutes.search);

  Future<void> _openSearchFilterFromHome() async {
    ref.read(appliedSearchFilterProvider.notifier).state = null;

    final popResult = await context.push<SearchFilterState>(
      AppRoutes.searchFilter,
      extra: const SearchFilterState(),
    );

    if (!mounted) return;

    final applied =
        ref.read(appliedSearchFilterProvider) ?? popResult;
    if (applied == null) return;

    ref.read(appliedSearchFilterProvider.notifier).state = applied;
    context.go(AppRoutes.search);
  }

  List<Widget> _catalogSlivers({
    required double logoSpacerHeight,
    required CatalogSnapshot catalog,
    required BuildContext context,
  }) {
    return [
            SliverToBoxAdapter(
              child: SizedBox(height: logoSpacerHeight),
            ),
            SliverToBoxAdapter(
              child: HomeSearchBar(
                onSearchTap: _openSearchPage,
                onFilterTap: _openSearchFilterFromHome,
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (catalog.hasWarning)
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                      child: _CatalogWarningBanner(message: catalog.warningMessage!),
                    ),
                  HomeCategoryChips(
                    categories: catalog.categories,
                    selectedIndex:
                        _selectedCategoryIndex(catalog, catalog.categories),
                    onSelected: (i) =>
                        _onCategorySelected(i, catalog.categories),
                  ),
                  const HomePromoBanner(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 12.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'جميع المنتجات',
                            style: AppTextStyles.homeSectionTitle(),
                          ),
                        ),
                        if (catalog.stats.totalProducts > 0)
                          Text(
                            '${catalog.products.length} من ${catalog.stats.totalProducts}',
                            style: AppTextStyles.settingsMenuItem(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (catalog.isLoadingMore && catalog.products.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (catalog.products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'لا توجد منتجات في هذا القسم',
                    style: AppTextStyles.settingsMenuItem(),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  0,
                  20.w,
                  120.h + MediaQuery.paddingOf(context).bottom,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14.h,
                    crossAxisSpacing: 14.w,
                    childAspectRatio: HomeProductCardMetrics.aspectRatio(),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = catalog.products[index];
                      return HomeProductCard(
                        key: ValueKey(product.id),
                        product: product,
                        onTap: () => ProductDetailsWidget.open(context, product),
                        onAddToCart: () =>
                            addProductToCart(context, ref, product),
                      );
                    },
                    childCount: catalog.products.length,
                  ),
                ),
              ),
            if (catalog.products.isNotEmpty &&
                (catalog.hasMore || catalog.isLoadingMore))
              SliverToBoxAdapter(
                child: PaginationFooter(
                  currentPage: catalog.currentPage,
                  lastPage: catalog.lastPage,
                  hasMore: catalog.hasMore,
                  isLoadingMore: catalog.isLoadingMore,
                  onLoadMore: () =>
                      ref.read(catalogProvider.notifier).loadMore(),
                ),
              ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final logoSpacerHeight = topInset + HomeScrollMetrics.logoBarHeight();
    final catalogAsync = ref.watch(catalogProvider);

    return catalogAsync.when(
      loading: () => AppRefreshScrollView(
        onRefresh: _onRefresh,
        controller: widget.scrollController,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: logoSpacerHeight)),
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (error, _) => AppRefreshScrollView(
        onRefresh: _onRefresh,
        controller: widget.scrollController,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: logoSpacerHeight)),
          SliverFillRemaining(
            child: _CatalogError(
              message: error.toString(),
              onRetry: _onRefresh,
            ),
          ),
        ],
      ),
      data: (catalog) => AppRefreshScrollView(
        onRefresh: _onRefresh,
        controller: widget.scrollController,
        slivers: _catalogSlivers(
          logoSpacerHeight: logoSpacerHeight,
          catalog: catalog,
          context: context,
        ),
      ),
    );
  }
}

class _CatalogWarningBanner extends StatelessWidget {
  const _CatalogWarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        message,
        style: AppTextStyles.settingsMenuItem(color: Colors.orange.shade900),
        textAlign: TextAlign.right,
      ),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            FilledButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
