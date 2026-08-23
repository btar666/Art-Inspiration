import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/skeleton/skeleton_image_placeholder.dart';
import '../../data/models/notification_model.dart';

/// مقاييس كارد الإشعار
abstract final class NotificationCardMetrics {
  static const Color pageBackground = Color(0xFFFFFFFF);
  static const Color iconBackground = Color(0x1A022B2F);
  static const Color titleColor = Color(0xFF040814);
  static const Color cardShadowColor = Color(0xFF659AB9);

  static double cardRadius() => 20.r;
  static double cardShadowBlur() => 3.76.r;

  static List<BoxShadow> cardShadow() => [
        BoxShadow(
          color: cardShadowColor.withValues(alpha: 0.22),
          blurRadius: cardShadowBlur(),
          offset: Offset(0, 2.h),
          spreadRadius: 0,
        ),
      ];

  static double iconSize() => 40.w;
  static double iconAssetSize() => 24.w;
  static double productThumbSize() => 52.w;
  static double unreadDotSize() => 8.w;
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
    if (notification.hasProduct) {
      return _ProductNotificationCard(
        notification: notification,
        onOpenProduct: onOpenProduct,
      );
    }
    return _GeneralNotificationCard(notification: notification);
  }
}

class _ProductNotificationCard extends StatelessWidget {
  const _ProductNotificationCard({
    required this.notification,
    this.onOpenProduct,
  });

  final AppNotificationModel notification;
  final ValueChanged<String>? onOpenProduct;

  void _openProduct() {
    final itemId = notification.itemId;
    if (itemId == null) return;
    onOpenProduct?.call(itemId);
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isHighlighted;
    final textMuted = NotificationCardMetrics.titleColor.withValues(
      alpha: isUnread ? 0.72 : 0.45,
    );
    final productLabel = _productDisplayName();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openProduct,
        borderRadius: BorderRadius.circular(NotificationCardMetrics.cardRadius()),
        child: Ink(
          decoration: BoxDecoration(
            color: isUnread
                ? AppColors.primaryLight.withValues(alpha: 0.42)
                : AppColors.background,
            borderRadius:
                BorderRadius.circular(NotificationCardMetrics.cardRadius()),
            border: Border.all(
              color: isUnread
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : AppColors.orderCardBorder,
              width: 1,
            ),
            boxShadow: isUnread ? null : NotificationCardMetrics.cardShadow(),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.notificationTitle(
                              color: isUnread
                                  ? NotificationCardMetrics.titleColor
                                  : NotificationCardMetrics.titleColor
                                      .withValues(alpha: 0.55),
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          notification.timeLabel,
                          style: AppTextStyles.notificationTime(
                            color: textMuted,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                    if (notification.description.trim().isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        notification.description,
                        style: AppTextStyles.notificationBody(
                          color: textMuted,
                        ).copyWith(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 12.h),
                    _ProductPreviewStrip(
                      imageUrl: notification.productImageUrl,
                      label: productLabel,
                      isUnread: isUnread,
                    ),
                  ],
                ),
              ),
              if (isUnread)
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    width: NotificationCardMetrics.unreadDotSize(),
                    height: NotificationCardMetrics.unreadDotSize(),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _productDisplayName() {
    final name = notification.productName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final title = notification.title.trim();
    if (title.isNotEmpty) return title;
    return 'عرض المنتج';
  }
}

class _ProductPreviewStrip extends StatelessWidget {
  const _ProductPreviewStrip({
    required this.imageUrl,
    required this.label,
    required this.isUnread,
  });

  final String? imageUrl;
  final String label;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final thumb = NotificationCardMetrics.productThumbSize();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: isUnread ? 0.82 : 1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _ProductThumb(imageUrl: imageUrl, size: thumb),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  style: AppTextStyles.notificationTitle(
                    color: NotificationCardMetrics.titleColor.withValues(
                      alpha: isUnread ? 1 : 0.6,
                    ),
                  ).copyWith(fontSize: 12.5.sp),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  'اضغط للاطلاع على المنتج',
                  style: AppTextStyles.notificationBody(
                    color: AppColors.primary.withValues(
                      alpha: isUnread ? 0.85 : 0.55,
                    ),
                  ).copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Transform.rotate(
            angle: math.pi,
            child: Icon(
              Icons.chevron_left_rounded,
              size: 22.sp,
              color: AppColors.primary.withValues(alpha: isUnread ? 0.9 : 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({
    required this.imageUrl,
    required this.size,
  });

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.r);
    final url = imageUrl?.trim() ?? '';

    if (url.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 22.sp,
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholder: (_, __) => SkeletonImagePlaceholder(borderRadius: radius),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.surface,
            alignment: Alignment.center,
            child: Icon(
              Icons.image_outlined,
              size: 22.sp,
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

class _GeneralNotificationCard extends StatelessWidget {
  const _GeneralNotificationCard({required this.notification});

  final AppNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isHighlighted;
    final textMuted = NotificationCardMetrics.titleColor.withValues(
      alpha: isUnread ? 0.72 : 0.45,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isUnread
            ? AppColors.primaryLight.withValues(alpha: 0.28)
            : AppColors.background,
        borderRadius:
            BorderRadius.circular(NotificationCardMetrics.cardRadius()),
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.orderCardBorder,
          width: 1,
        ),
        boxShadow: isUnread ? null : NotificationCardMetrics.cardShadow(),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationIcon(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.notificationTitle(
                          color: isUnread
                              ? NotificationCardMetrics.titleColor
                              : NotificationCardMetrics.titleColor
                                  .withValues(alpha: 0.55),
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread) ...[
                      SizedBox(width: 6.w),
                      Container(
                        width: NotificationCardMetrics.unreadDotSize(),
                        height: NotificationCardMetrics.unreadDotSize(),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                if (notification.description.trim().isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    notification.description,
                    style: AppTextStyles.notificationBody(
                      color: textMuted,
                    ).copyWith(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 6.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    notification.timeLabel,
                    style: AppTextStyles.notificationTime(color: textMuted),
                    textDirection: TextDirection.rtl,
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

class _NotificationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = NotificationCardMetrics.iconSize();
    final assetSize = NotificationCardMetrics.iconAssetSize();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: NotificationCardMetrics.iconBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(-1.w, 0),
        child: Image.asset(
          AppAssets.logo,
          width: assetSize,
          height: assetSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
