import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../data/models/catalog_snapshot.dart';
import '../../../cart/presentation/cart_actions.dart';
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

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final logoSpacerHeight = topInset + HomeScrollMetrics.logoBarHeight();
    final catalogAsync = ref.watch(catalogProvider);

    return catalogAsync.when(
      loading: () => CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: logoSpacerHeight)),
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (error, _) => CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: logoSpacerHeight)),
          SliverFillRemaining(
            child: _CatalogError(
              message: error.toString(),
              onRetry: () => ref.read(catalogProvider.notifier).refresh(),
            ),
          ),
        ],
      ),
      data: (catalog) {
        final categories = catalog.categories;
        final selectedIndex = _selectedCategoryIndex(catalog, categories);
        final products = catalog.products;
        final totalProducts = catalog.stats.totalProducts;
        final loadedCount = products.length;

        return CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: logoSpacerHeight),
            ),
            const SliverToBoxAdapter(
              child: HomeSearchBar(),
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
                    categories: categories,
                    selectedIndex: selectedIndex,
                    onSelected: (i) => _onCategorySelected(i, categories),
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
                        if (totalProducts > 0)
                          Text(
                            '$loadedCount من $totalProducts',
                            style: AppTextStyles.settingsMenuItem(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (catalog.isLoadingMore && products.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (products.isEmpty)
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
                      final product = products[index];
                      return HomeProductCard(
                        key: ValueKey(product.id),
                        product: product,
                        onTap: () => ProductDetailsWidget.open(context, product),
                        onAddToCart: () =>
                            addProductToCart(context, ref, product),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
            if (products.isNotEmpty && (catalog.hasMore || catalog.isLoadingMore))
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
          ],
        );
      },
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
