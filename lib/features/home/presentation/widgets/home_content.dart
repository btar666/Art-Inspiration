import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../providers/products_provider.dart';
import 'erp_store_overview_card.dart';
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
  int _selectedCategoryIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final logoSpacerHeight = topInset + HomeScrollMetrics.logoBarHeight();
    final catalogAsync = ref.watch(catalogProvider);
    final auth = ref.watch(authNotifierProvider);
    final ordersTotal = ref.watch(erpOrdersTotalProvider).value;

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
        final selectedCategory = categories[
            _selectedCategoryIndex.clamp(0, categories.length - 1)];
        final visibleProducts = selectedCategory == 'الكل'
            ? catalog.products
            : catalog.products.where((p) {
                return p.categoryName == selectedCategory ||
                    p.brandName == selectedCategory;
              }).toList();

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
                  ErpStoreOverviewCard(
                    catalog: catalog,
                    ordersTotal: ordersTotal,
                    userName: auth.user?.name,
                  ),
                  HomeCategoryChips(
                    categories: categories,
                    selectedIndex:
                        _selectedCategoryIndex.clamp(0, categories.length - 1),
                    onSelected: (i) => setState(() => _selectedCategoryIndex = i),
                  ),
                  const HomePromoBanner(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
                    child: Text(
                      'جميع المنتجات',
                      style: AppTextStyles.homeSectionTitle(),
                    ),
                  ),
                ],
              ),
            ),
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
                    final product = visibleProducts[index];
                    return HomeProductCard(
                      key: ValueKey(product.id),
                      product: product,
                      onTap: () => ProductDetailsWidget.open(context, product),
                      onAddToCart: () =>
                          addProductToCart(context, ref, product),
                    );
                  },
                  childCount: visibleProducts.length,
                ),
              ),
            ),
            if (catalog.hasMore || catalog.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Center(
                    child: catalog.isLoadingMore
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink(),
                  ),
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
