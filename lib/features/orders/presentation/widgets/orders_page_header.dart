import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// رأس صفحة الفواتير — إشعارات + عنوان
class OrdersPageHeader extends StatelessWidget {
  const OrdersPageHeader({
    super.key,
    this.title = 'الفواتير',
    this.onNotificationTap,
  });

  final String title;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 28.sp),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.ordersPageTitle(),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_rounded,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
                Positioned(
                  top: 2.h,
                  right: 2.w,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.notificationDot,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
