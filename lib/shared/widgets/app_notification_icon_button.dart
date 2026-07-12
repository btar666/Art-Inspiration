import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';

/// أيقونة الإشعارات — حمراء عند وجود جديد، نظيفة عند القراءة الكاملة
class AppNotificationIconButton extends ConsumerWidget {
  const AppNotificationIconButton({
    super.key,
    this.onTap,
    this.size,
  });

  final VoidCallback? onTap;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);
    final iconSize = size ?? 28.w;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        hasUnread ? AppAssets.notificationRed : AppAssets.notificationClean,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
