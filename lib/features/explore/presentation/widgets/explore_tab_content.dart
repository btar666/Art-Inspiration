import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/data/home_mock_data.dart';
import '../../../home/data/models/catalog_snapshot.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/widgets/home_product_card.dart';
import '../../../home/presentation/widgets/home_product_card_metrics.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../data/models/explore_models.dart';
import 'explore_brand_card.dart';
import 'explore_brand_card_metrics.dart';
import 'explore_section_card.dart';
import 'explore_section_card_metrics.dart';

/// شبكة المحتوى لكل تبويب داخل CustomScrollView
abstract final class ExploreTabSlivers {
  static Widget build({
    required ExploreTab tab,
    required double bottomInset,
    required List<ProductModel> products,
    required List<String> brands,
    required List<String> categories,
    CatalogSnapshot? catalog,
    void Function(ProductModel product)? onAddToCart,
    VoidCallback? onLoadMore,
  }) {
    return switch (tab) {
      ExploreTab.general => _generalGrid(
          bottomInset,
          products,
          catalog,
          onAddToCart,
          onLoadMore,
        ),
      ExploreTab.brands => _brandsGrid(bottomInset, brands),
      ExploreTab.sections => _sectionsGrid(bottomInset, categories, catalog),
    };
  }

  static Widget _generalGrid(
    double bottomInset,
    List<ProductModel> products,
    CatalogSnapshot? catalog,
    void Function(ProductModel product)? onAddToCart,
    VoidCallback? onLoadMore,
  ) {
    final items = products.length <= 1
        ? [...HomeMockData.products, ...HomeMockData.products]
        : products;

    final total = catalog?.stats.totalProducts ?? items.length;
    final hasMore = catalog?.hasMore ?? false;
    final isLoadingMore = catalog?.isLoadingMore ?? false;

    return SliverMainAxisGroup(
      slivers: [
        if (total > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${items.length} من $total',
                  style: AppTextStyles.settingsMenuItem(),
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            0,
            20.w,
            0,
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
                final product = items[index];
                return HomeProductCard(
                  key: ValueKey('explore_${product.id}_$index'),
                  product: product,
                  onAddToCart: () => onAddToCart?.call(product),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
        if (hasMore || isLoadingMore)
          SliverToBoxAdapter(
            child: PaginationFooter(
              currentPage: catalog?.currentPage ?? 1,
              lastPage: catalog?.lastPage ?? 1,
              hasMore: hasMore,
              isLoadingMore: isLoadingMore,
              onLoadMore: onLoadMore,
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 100.h + bottomInset)),
      ],
    );
  }

  static Widget _brandsGrid(double bottomInset, List<String> brands) {
    if (brands.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'لا توجد براندات في النظام',
            style: AppTextStyles.settingsMenuItem(),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        16.h,
        20.w,
        100.h + bottomInset,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: ExploreBrandCardMetrics.gridAspectRatio(),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final name = brands[index];
            return ExploreBrandCard(
              brand: ExploreBrandModel(id: name, name: name),
              onTap: () => context.push(
                AppRoutes.exploreSectionPath(name),
              ),
            );
          },
          childCount: brands.length,
        ),
      ),
    );
  }

  static Widget _sectionsGrid(
    double bottomInset,
    List<String> categories,
    CatalogSnapshot? catalog,
  ) {
    final sections = categories.where((c) => c != 'الكل').toList();
    if (sections.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'لا توجد أقسام في النظام',
            style: AppTextStyles.settingsMenuItem(),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        16.h,
        20.w,
        100.h + bottomInset,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: ExploreSectionCardMetrics.gridAspectRatio(),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final name = sections[index];
            final section = ExploreSectionModel(
              id: name,
              name: name,
              imageUrl: catalog?.imageForCategory(name),
            );
            return ExploreSectionCard(
              section: section,
              onTap: () => context.push(
                AppRoutes.exploreSectionPath(section.id),
              ),
            );
          },
          childCount: sections.length,
        ),
      ),
    );
  }
}
