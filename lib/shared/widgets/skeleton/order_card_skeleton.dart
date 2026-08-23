import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import 'skeleton_shimmer.dart';

/// skeleton كارد طلب — مطابق لـ OrderCard
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 120.h),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.orderCardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: 72.w,
            height: 72.w,
            borderRadius: BorderRadius.circular(14.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SkeletonLine(width: 160.w, height: 14.h),
                SizedBox(height: 6.h),
                SkeletonLine(width: 100.w, height: 11.h),
                SizedBox(height: 10.h),
                SkeletonBox(
                  height: 1.h,
                  borderRadius: BorderRadius.zero,
                ),
                SizedBox(height: 10.h),
                SkeletonLine(width: 90.w, height: 13.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// قائمة skeleton لصفحة الطلبات
class OrdersListSkeleton extends StatelessWidget {
  const OrdersListSkeleton({
    super.key,
    this.itemCount = 4,
    this.padding,
  });

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: 14.h),
        itemBuilder: (_, __) => const OrderCardSkeleton(),
      ),
    );
  }
}
