import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../home/data/home_mock_data.dart';
import '../../../home/data/models/product_model.dart';
import '../../../../shared/widgets/product/product_card.dart';
import '../../data/explore_mock_data.dart';
import '../../data/models/explore_models.dart';
import 'explore_brand_card.dart';
import 'explore_section_card.dart';

/// شبكة المحتوى لكل تبويب داخل CustomScrollView
abstract final class ExploreTabSlivers {
  static List<ProductModel> get _products => [
        ...HomeMockData.products,
        ...HomeMockData.products,
      ];

  static Widget build({
    required ExploreTab tab,
    required double bottomInset,
  }) {
    return switch (tab) {
      ExploreTab.general => _generalGrid(bottomInset),
      ExploreTab.brands => _brandsGrid(bottomInset),
      ExploreTab.sections => _sectionsGrid(bottomInset),
    };
  }

  static Widget _generalGrid(double bottomInset) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        16.h,
        20.w,
        100.h + bottomInset,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.54,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = _products[index];
            return ProductCard(
              key: ValueKey('explore_${product.id}_$index'),
              product: product,
              onAddToCart: () {},
            );
          },
          childCount: _products.length,
        ),
      ),
    );
  }

  static Widget _brandsGrid(double bottomInset) {
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
          childAspectRatio: 0.70,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ExploreBrandCard(brand: ExploreMockData.brands[index]);
          },
          childCount: ExploreMockData.brands.length,
        ),
      ),
    );
  }

  static Widget _sectionsGrid(double bottomInset) {
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
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final section = ExploreMockData.sections[index];
            return ExploreSectionCard(
              section: section,
              onTap: () => context.push(
                AppRoutes.exploreSectionPath(section.id),
              ),
            );
          },
          childCount: ExploreMockData.sections.length,
        ),
      ),
    );
  }
}
