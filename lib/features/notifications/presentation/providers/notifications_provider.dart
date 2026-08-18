import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/push_notifications.dart';
import '../../../app_api/data/app_api_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/notification_model.dart';
import '../../data/notifications_mock_data.dart';
import '../../data/notifications_storage.dart';

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

    PushNotifications.onForegroundMessage = _onForegroundMessage;
    ref.onDispose(() {
      if (PushNotifications.onForegroundMessage == _onForegroundMessage) {
        PushNotifications.onForegroundMessage = null;
      }
    });

    return _fetch();
  }

  void _onForegroundMessage() {
    refreshInBackground();
  }

  Future<List<AppNotificationModel>> _fetch() async {
    try {
      final items =
          await ref.read(appApiServiceProvider).fetchNotifications();
      final filtered = await _filterForCurrentUser(items);
      if (filtered.isEmpty) return const [];
      return filtered.map(_mapItem).toList();
    } catch (_) {
      final mock = List.of(NotificationsMockData.items);
      return mock;
    }
  }

  String _currentNotificationUserKey() {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return '';
    return user.notificationUserKey;
  }

  Future<List<AppNotificationItem>> _filterForCurrentUser(
    List<AppNotificationItem> items,
  ) async {
    final userKey = _currentNotificationUserKey();
    if (userKey.isEmpty) return items;

    final storage = ref.read(notificationsStorageProvider);
    final since = storage.visibleSince(userKey);
    if (since == null) return items;

    final filtered = _applyVisibleSinceFilter(items, since);

    // إصلاح تلقائي: الفلتر أخفى كل الإشعارات بعد إعادة تسجيل الدخول
    if (filtered.isEmpty && items.isNotEmpty) {
      await storage.resetVisibleSince(userKey);
      return items;
    }

    return filtered;
  }

  List<AppNotificationItem> _applyVisibleSinceFilter(
    List<AppNotificationItem> items,
    DateTime since,
  ) {
    return items.where((item) {
      final createdAt = item.createdAt;
      if (createdAt == null) return false;
      return !createdAt.isBefore(since);
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refreshInBackground() async {
    final previous = state.value;
    try {
      final fresh = await _fetch();
      state = AsyncData(fresh);
    } catch (_) {
      if (previous != null) {
        state = AsyncData(previous);
      }
    }
  }

  Future<void> markAllAsRead() async {
    final userKey = _currentNotificationUserKey();
    if (userKey.isNotEmpty) {
      await ref.read(notificationsStorageProvider).markAllRead(userKey);
    }

    final current = state.value;
    if (current == null) return;

    state = AsyncData([
      for (final notification in current)
        notification.copyWith(isRead: true),
    ]);
  }

  AppNotificationModel _mapItem(AppNotificationItem item) {
    final createdAt = (item.createdAt ?? DateTime.now()).toLocal();
    final userKey = _currentNotificationUserKey();
    final storage = ref.read(notificationsStorageProvider);
    final isRead = userKey.isEmpty
        ? true
        : storage.isRead(userKey: userKey, createdAt: item.createdAt);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day = DateTime(createdAt.year, createdAt.month, createdAt.day);

    final NotificationGroup group;
    if (day == today) {
      group = NotificationGroup.today;
    } else if (day == yesterday) {
      group = NotificationGroup.yesterday;
    } else {
      group = NotificationGroup.older;
    }

    final timeLabel = _formatTimeLabel(createdAt, group);

    return AppNotificationModel(
      id: item.id.isEmpty ? timeLabel : item.id,
      group: group,
      title: item.title,
      description: item.body.isEmpty ? item.title : item.body,
      timeLabel: timeLabel,
      isRead: isRead,
      itemId: item.itemId,
      productName: item.productName,
      productImageUrl: item.productImageUrl,
    );
  }

  String _formatTimeLabel(DateTime createdAt, NotificationGroup group) {
    if (group != NotificationGroup.today) {
      return _formatDateLabel(createdAt);
    }

    final diff = DateTime.now().difference(createdAt);
    if (diff.isNegative || diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقائق';
    if (diff.inHours < 24) {
      return diff.inHours == 1 ? 'منذ ساعة' : 'منذ ${diff.inHours} ساعات';
    }

    return _formatDateLabel(createdAt);
  }

  String _formatDateLabel(DateTime date) {
    return '${date.day} - ${date.month} - ${date.year}';
  }
}

final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? const [];
  return notifications.any((notification) => !notification.isRead);
});
