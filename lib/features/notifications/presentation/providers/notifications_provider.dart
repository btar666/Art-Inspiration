import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_model.dart';
import '../../data/notifications_mock_data.dart';

/// حالة قائمة الإشعارات
class NotificationsNotifier extends StateNotifier<List<AppNotificationModel>> {
  NotificationsNotifier() : super(List.of(NotificationsMockData.items));

  void markAllAsRead() {
    state = [
      for (final notification in state) notification.copyWith(isRead: true),
    ];
  }
}

/// مزوّد الإشعارات
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotificationModel>>(
  (ref) => NotificationsNotifier(),
);

/// هل يوجد إشعار غير مقروء
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(notificationsProvider).any((notification) => !notification.isRead);
});
