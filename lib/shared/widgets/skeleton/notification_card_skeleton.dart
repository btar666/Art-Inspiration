import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/notifications/presentation/widgets/notification_card.dart';
import 'skeleton_shimmer.dart';

/// skeleton كارد إشعار — مطابق للتصميم الجديد
class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({
    super.key,
    this.hasProductStrip = false,
  });

  final bool hasProductStrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.circular(NotificationCardMetrics.cardRadius()),
        border: Border.all(color: AppColors.orderCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: SkeletonBox(
                  height: 14.h,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              SizedBox(width: 10.w),
              SkeletonLine(width: 48.w, height: 10.h),
            ],
          ),
          SizedBox(height: 8.h),
          SkeletonLine(width: 220.w, height: 11.h),
          if (hasProductStrip) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  SkeletonBox(
                    width: NotificationCardMetrics.productThumbSize(),
                    height: NotificationCardMetrics.productThumbSize(),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SkeletonLine(width: 120.w, height: 12.h),
                        SizedBox(height: 4.h),
                        SkeletonLine(width: 140.w, height: 10.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// قائمة skeleton لصفحة الإشعارات
class NotificationsListSkeleton extends StatelessWidget {
  const NotificationsListSkeleton({
    super.key,
    this.padding,
  });

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: SkeletonLine(width: 80.w, height: 16.h),
          ),
          SizedBox(height: 12.h),
          const NotificationCardSkeleton(),
          SizedBox(height: 12.h),
          const NotificationCardSkeleton(hasProductStrip: true),
          SizedBox(height: 12.h),
          const NotificationCardSkeleton(hasProductStrip: true),
          SizedBox(height: 20.h),
          Align(
            alignment: Alignment.centerRight,
            child: SkeletonLine(width: 64.w, height: 16.h),
          ),
          SizedBox(height: 12.h),
          const NotificationCardSkeleton(hasProductStrip: true),
          SizedBox(height: 12.h),
          const NotificationCardSkeleton(),
        ],
      ),
    );
  }
}
