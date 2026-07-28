import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_api/data/app_api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/notification_model.dart';
import '../../data/notifications_mock_data.dart';

/// إشعارات من الباكند الخاص مع fallback للتجريبي
final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotificationModel>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier
    extends AsyncNotifier<List<AppNotificationModel>> {
  @override
  Future<List<AppNotificationModel>> build() async {
    ref.watch(authNotifierProvider);
    return _fetch();
  }

  Future<List<AppNotificationModel>> _fetch() async {
    try {
      final items =
          await ref.read(appApiServiceProvider).fetchNotifications();
      if (items.isEmpty) return const [];
      return items.map(_mapItem).toList();
    } catch (_) {
      return List.of(NotificationsMockData.items);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  void markAllAsRead() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final notification in current) notification.copyWith(isRead: true),
    ]);
  }

  AppNotificationModel _mapItem(AppNotificationItem item) {
    final createdAt = item.createdAt ?? DateTime.now();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day = DateTime(createdAt.year, createdAt.month, createdAt.day);

    final group = day == today
        ? NotificationGroup.today
        : day == yesterday
            ? NotificationGroup.yesterday
            : NotificationGroup.yesterday;

    final timeLabel =
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

    return AppNotificationModel(
      id: item.id.isEmpty ? timeLabel : item.id,
      group: group,
      title: item.title,
      description: item.body.isEmpty ? item.title : item.body,
      timeLabel: timeLabel,
      icon: Icons.notifications_outlined,
      isRead: false,
    );
  }
}

final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? const [];
  return notifications.any((notification) => !notification.isRead);
});
