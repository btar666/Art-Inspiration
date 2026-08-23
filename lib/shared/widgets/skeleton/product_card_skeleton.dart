import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/home/presentation/widgets/home_product_card_metrics.dart';
import 'skeleton_shimmer.dart';

/// skeleton بطاقة منتج — مطابق لـ HomeProductCard
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = HomeProductCardMetrics.radius();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: HomeProductCardMetrics.shadowColor.withValues(alpha: 0.38),
            blurRadius: HomeProductCardMetrics.shadowBlur(),
            offset: Offset.zero,
          ),
        ],
      ),
      padding: HomeProductCardMetrics.padding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: HomeProductCardMetrics.imagePadding(),
            child: SkeletonBox(
              height: HomeProductCardMetrics.imageHeight(),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(height: HomeProductCardMetrics.imageToNameGap()),
          SkeletonLine(width: 120.w, height: 14.h),
          SizedBox(height: HomeProductCardMetrics.nameToCategoryGap()),
          SkeletonLine(width: 80.w, height: 11.h),
          SizedBox(height: HomeProductCardMetrics.categoryToDescriptionGap()),
          SkeletonBox(height: 10.h, borderRadius: BorderRadius.circular(6.r)),
          SizedBox(height: 4.h),
          SkeletonLine(width: 100.w, height: 10.h),
          SizedBox(height: HomeProductCardMetrics.descriptionToPriceGap()),
          Padding(
            padding: HomeProductCardMetrics.priceBarMargin(),
            child: SkeletonBox(
              height: HomeProductCardMetrics.priceBarHeight(),
              borderRadius: BorderRadius.circular(
                HomeProductCardMetrics.priceBarRadius(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
