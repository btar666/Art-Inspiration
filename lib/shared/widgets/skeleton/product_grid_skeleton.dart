import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/home/presentation/widgets/home_product_card_metrics.dart';
import 'product_card_skeleton.dart';
import 'skeleton_shimmer.dart';

/// شبكة skeleton لبطاقات المنتجات
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.padding,
    this.bottomSpacing = 0,
  });

  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: padding ?? EdgeInsets.fromLTRB(20.w, 0, 20.w, bottomSpacing),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14.h,
            crossAxisSpacing: 14.w,
            childAspectRatio: HomeProductCardMetrics.aspectRatio(),
          ),
          itemCount: itemCount,
          itemBuilder: (_, __) => const ProductCardSkeleton(),
        ),
      ),
    );
  }
}

/// Sliver شبكة skeleton — للاستخدام داخل CustomScrollView
class ProductGridSkeletonSliver extends StatelessWidget {
  const ProductGridSkeletonSliver({
    super.key,
    this.itemCount = 6,
    this.padding,
    this.bottomSpacing = 0,
  });

  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SkeletonShimmer(
        child: Padding(
          padding: padding ??
              EdgeInsets.fromLTRB(20.w, 0, 20.w, bottomSpacing),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14.h,
              crossAxisSpacing: 14.w,
              childAspectRatio: HomeProductCardMetrics.aspectRatio(),
            ),
            itemCount: itemCount,
            itemBuilder: (_, __) => const ProductCardSkeleton(),
          ),
        ),
      ),
    );
  }
}
