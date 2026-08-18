import 'package:cached_network_image/cached_network_image.dart';
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
  static double iconAssetSize() => 22.w;
}

/// كارد إشعار واحد
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onOpenProduct,
  });

  final AppNotificationModel notification;
  final ValueChanged<String>? onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isHighlighted;
    final hasProduct = notification.hasProduct;
    final imageUrl = notification.productImageUrl;

    return GestureDetector(
      onTap: hasProduct && notification.itemId != null
          ? () => onOpenProduct?.call(notification.itemId!)
          : null,
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(NotificationCardMetrics.cardRadius()),
        boxShadow: NotificationCardMetrics.cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(imageUrl: imageUrl),
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
          if (hasProduct) ...[
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.center,
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20.r),
                child: InkWell(
                  onTap: () {
                    final itemId = notification.itemId;
                    if (itemId == null) return;
                    onOpenProduct?.call(itemId);
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 8.h,
                    ),
                    child: Text(
                      'عرض المنتج',
                      style: AppTextStyles.notificationTitle(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = NotificationCardMetrics.iconSize();
    final assetSize = NotificationCardMetrics.iconAssetSize();

    Widget child;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      child = ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _LogoMark(size: assetSize),
        ),
      );
    } else {
      child = _LogoMark(size: assetSize);
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: NotificationCardMetrics.iconBackground,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-1.w, 0),
      child: Image.asset(
        AppAssets.logo,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
