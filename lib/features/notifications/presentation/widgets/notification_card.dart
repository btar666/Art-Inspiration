import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/notification_model.dart';

/// مقاييس كارد الإشعار — مطابقة للتصميم
abstract final class NotificationCardMetrics {
  static const Color pageBackground = Color(0xFFFFFFFF);
  static const Color iconBackground = Color(0x1A022B2F); // #022B2F @ 10%
  static const Color titleColor = Color(0xFF040814);
  static const Color cardShadowColor = Color(0xFF659AB9);

  static double cardRadius() => 24.r;
  static double cardShadowBlur() => 3.76.r;

  static List<BoxShadow> cardShadow() => [
        BoxShadow(
          color: cardShadowColor.withValues(alpha: 0.38),
          blurRadius: cardShadowBlur(),
          offset: Offset.zero,
          spreadRadius: 0,
        ),
      ];
  static double iconSize() => 34.08.w;
  static double iconAssetSize() => 16.w;
}

/// كارد إشعار واحد
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
  });

  final AppNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isHighlighted;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(NotificationCardMetrics.cardRadius()),
        boxShadow: NotificationCardMetrics.cardShadow(),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _NotificationIcon(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  notification.title,
                  style: AppTextStyles.notificationTitle(
                    color: isUnread
                        ? NotificationCardMetrics.titleColor
                        : NotificationCardMetrics.titleColor.withValues(
                            alpha: 0.5,
                          ),
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.description,
                  style: AppTextStyles.notificationBody(
                    color: isUnread
                        ? NotificationCardMetrics.titleColor
                        : NotificationCardMetrics.titleColor.withValues(
                            alpha: 0.5,
                          ),
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            notification.timeLabel,
            style: AppTextStyles.notificationTime(
              color: isUnread
                  ? NotificationCardMetrics.titleColor
                  : NotificationCardMetrics.titleColor.withValues(
                      alpha: 0.5,
                    ),
            ),
            textAlign: TextAlign.left,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon();

  @override
  Widget build(BuildContext context) {
    final size = NotificationCardMetrics.iconSize();
    final assetSize = NotificationCardMetrics.iconAssetSize();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: NotificationCardMetrics.iconBackground,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Image.asset(
        AppAssets.artNoti,
        width: assetSize,
        height: assetSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
