import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../product_details_bottom_bar_metrics.dart';
import '../product_details_gallery_metrics.dart';
import 'skeleton_shimmer.dart';

/// skeleton صفحة تفاصيل المنتج — للتحميل بالمعرف
class ProductDetailsSkeleton extends StatelessWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomBarHeight =
        ProductDetailsBottomBarMetrics.occupiedHeight() + bottomInset;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                  child: SkeletonShimmer(
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        SkeletonBox(
                          width: 40.w,
                          height: 40.w,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        Expanded(
                          child: Center(
                            child: SkeletonLine(width: 100.w, height: 16.h),
                          ),
                        ),
                        SkeletonBox(
                          width: 40.w,
                          height: 40.w,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    8.h,
                    20.w,
                    bottomBarHeight + 16.h,
                  ),
                  child: SkeletonShimmer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final mainSide =
                                ProductDetailsGalleryMetrics.mainImageSide(
                              constraints.maxWidth,
                              hasThumbs: true,
                            );
                            final thumbGap =
                                ProductDetailsGalleryMetrics
                                    .thumbnailGapForCount(4, mainSide);
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: mainSide,
                                  height: mainSide,
                                  child: SkeletonBox(
                                    width: mainSide,
                                    height: mainSide,
                                    borderRadius: BorderRadius.circular(
                                      ProductDetailsGalleryMetrics
                                          .mainImageRadius(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: ProductDetailsGalleryMetrics
                                      .columnGap(),
                                ),
                                Column(
                                  children: [
                                    for (var i = 0; i < 4; i++) ...[
                                      if (i > 0)
                                        SizedBox(height: thumbGap),
                                      SkeletonBox(
                                        width: ProductDetailsGalleryMetrics
                                            .thumbnailWidth(),
                                        height: ProductDetailsGalleryMetrics
                                            .thumbnailHeight(),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 20.h),
                        SkeletonBox(
                          height: 18.h,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        SizedBox(height: 8.h),
                        SkeletonLine(width: 200.w, height: 18.h),
                        SizedBox(height: 14.h),
                        SkeletonBox(
                          height: 1.h,
                          borderRadius: BorderRadius.zero,
                        ),
                        SizedBox(height: 14.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SkeletonLine(width: 80.w, height: 16.h),
                        ),
                        SizedBox(height: 8.h),
                        SkeletonBox(
                          height: 13.h,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        SizedBox(height: 6.h),
                        SkeletonBox(
                          height: 13.h,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        SizedBox(height: 6.h),
                        SkeletonLine(width: 240.w, height: 13.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: ProductDetailsBottomBarMetrics.horizontalMargin(),
            right: ProductDetailsBottomBarMetrics.horizontalMargin(),
            bottom:
                ProductDetailsBottomBarMetrics.bottomMargin() + bottomInset,
            child: SkeletonShimmer(
              child: Column(
                children: [
                  SkeletonBox(
                    height: ProductDetailsBottomBarMetrics.priceRowHeight(),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  SizedBox(
                    height: ProductDetailsBottomBarMetrics.gapBetweenRows(),
                  ),
                  SkeletonBox(
                    height: ProductDetailsBottomBarMetrics.addToCartHeight(),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
