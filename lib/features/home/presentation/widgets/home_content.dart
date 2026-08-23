import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/network/connectivity_error_handler.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_refresh_scroll_view.dart';
import '../../../../shared/widgets/connectivity_error_dialog.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../../../shared/widgets/skeleton/home_page_skeleton.dart';
import '../../../../shared/widgets/skeleton/product_grid_skeleton.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';
import '../../data/models/catalog_snapshot.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_featured_sections_provider.dart';
import '../providers/products_provider.dart';
import 'home_catalog_strips.dart';
import 'home_featured_product_strips.dart';
import 'home_product_card.dart';
import 'home_product_card_metrics.dart';
import 'home_promo_banner.dart';
import 'home_scroll_metrics.dart';

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

  Future<bool> _ensureConnectivityForAction() async {
    if (await ref.read(connectivityServiceProvider).isAppReachable()) {
      return true;
    }
    if (!mounted) return false;

    return ensureAppConnectivity(
      ref,
      () => ConnectivityErrorDialog.show(
        context,
        barrierDismissible: false,
      ),
    );
  }

  Future<void> _onRefresh() async {
    if (!await _ensureConnectivityForAction()) return;

    // العودة للأعلى حتى يظهر التحديث بعد تحميل صفحات كثيرة
    if (widget.scrollController.hasClients) {
      widget.scrollController.jumpTo(0);
    }

    ref.invalidate(sliderProvider);
    ref.invalidate(homeFeaturedSectionsProvider);
    await Future.wait([
      ref.read(authNotifierProvider.notifier).syncPricePolicyFromErp(),
      ref.read(catalogProvider.notifier).refresh(),
    ]);
  }

  Widget _buildHeroSection({required double topInset}) {
    return SizedBox(
      height: HomeScrollMetrics.heroHeight(topInset),
      width: double.infinity,
      child: const HomePromoBanner(),
    );
  }

  List<Widget> _catalogSlivers({
    required double topInset,
    required CatalogSnapshot catalog,
    required BuildContext context,
  }) {
    final products = catalog.products;
    return [
            SliverToBoxAdapter(
              child: _buildHeroSection(topInset: topInset),
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
                  HomeCatalogStrips(catalog: catalog),
                  const HomeFeaturedProductStrips(),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (catalog.isLoadingMore && products.isEmpty)
              ProductGridSkeletonSliver(
                bottomSpacing:
                    120.h + MediaQuery.paddingOf(context).bottom,
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
            if ((products.isNotEmpty || catalog.hasMore) &&
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
    final catalogAsync = ref.watch(catalogProvider);

    return catalogAsync.when(
      loading: () => AppRefreshScrollView(
        onRefresh: _onRefresh,
        controller: widget.scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: HomePageSkeleton(
              topInset: topInset,
              bottomInset: MediaQuery.paddingOf(context).bottom,
            ),
          ),
        ],
      ),
      error: (error, _) => ConnectivityErrorGate(
        error: error,
        onRetry: () async => ref.invalidate(catalogProvider),
        child: AppRefreshScrollView(
          onRefresh: _onRefresh,
          controller: widget.scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: HomeScrollMetrics.heroHeight(topInset),
              ),
            ),
            const SliverFillRemaining(child: SizedBox.shrink()),
          ],
        ),
      ),
      data: (catalog) => AppRefreshScrollView(
        onRefresh: _onRefresh,
        controller: widget.scrollController,
        slivers: _catalogSlivers(
          topInset: topInset,
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
