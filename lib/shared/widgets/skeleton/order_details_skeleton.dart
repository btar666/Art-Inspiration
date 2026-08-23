import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/orders/presentation/pages/order_details_page.dart';
import 'skeleton_shimmer.dart';

/// skeleton صفحة تفاصيل الطلب
class OrderDetailsSkeleton extends StatelessWidget {
  const OrderDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final footerHeight =
        screenHeight * OrderDetailsPageMetrics.footerHeightFraction;
    final bottomRadius = OrderDetailsPageMetrics.whiteContainerBottomRadius();

    return Scaffold(
      backgroundColor: OrderDetailsPageMetrics.pageBackground,
      body: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(bottomRadius),
                  bottomRight: Radius.circular(bottomRadius),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: SkeletonShimmer(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    children: [
                      Center(
                        child: SkeletonLine(width: 120.w, height: 20.h),
                      ),
                      SizedBox(height: 12.h),
                      _InfoCardSkeleton(
                        children: [
                          _InlineRowSkeleton(labelWidth: 88.w, valueWidth: 140.w),
                          SizedBox(height: 12.h),
                          _InlineRowSkeleton(labelWidth: 96.w, valueWidth: 120.w),
                          SizedBox(height: 12.h),
                          _InlineRowSkeleton(
                            labelWidth: 108.w,
                            valueWidth: 80.w,
                          ),
                          SizedBox(height: 12.h),
                          _InlineRowSkeleton(
                            labelWidth: 104.w,
                            valueWidth: 100.w,
                          ),
                          SizedBox(height: 12.h),
                          _InlineRowSkeleton(
                            labelWidth: 108.w,
                            valueWidth: 180.w,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _InfoCardSkeleton(
                        children: [
                          _InlineRowSkeleton(
                            labelWidth: 96.w,
                            valueWidth: 130.w,
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SkeletonLine(width: 140.w, height: 16.h),
                      ),
                      SizedBox(height: 12.h),
                      _InfoCardSkeleton(
                        children: [
                          _OrderLineItemSkeleton(),
                          SizedBox(height: 12.h),
                          Center(
                            child: SkeletonBox(
                              width: 168.w,
                              height: 1.h,
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _OrderLineItemSkeleton(),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SkeletonLine(width: 100.w, height: 16.h),
                      ),
                      SizedBox(height: 12.h),
                      _InfoCardSkeleton(
                        children: [
                          _InlineRowSkeleton(
                            labelWidth: 88.w,
                            valueWidth: 100.w,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: footerHeight,
            child: ColoredBox(
              color: OrderDetailsPageMetrics.pageBackground,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: OrderDetailsPageMetrics.footerPadding(),
                  child: SkeletonShimmer(
                    child: SkeletonBox(
                      height: 52.h,
                      borderRadius: BorderRadius.circular(21.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCardSkeleton extends StatelessWidget {
  const _InfoCardSkeleton({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: OrderDetailsPageMetrics.cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _InlineRowSkeleton extends StatelessWidget {
  const _InlineRowSkeleton({
    required this.labelWidth,
    required this.valueWidth,
  });

  final double labelWidth;
  final double valueWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        SkeletonLine(width: labelWidth, height: 13.h),
        SizedBox(width: 8.w),
        SkeletonLine(width: valueWidth, height: 13.h),
      ],
    );
  }
}

class _OrderLineItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SkeletonBox(
          width: 72.w,
          height: 72.w,
          borderRadius: BorderRadius.circular(14.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLine(width: 140.w, height: 14.h),
              SizedBox(height: 8.h),
              SkeletonLine(width: 100.w, height: 12.h),
            ],
          ),
        ),
        SkeletonBox(
          width: 72.w,
          height: 36.h,
          borderRadius: BorderRadius.circular(20.r),
        ),
      ],
    );
  }
}
