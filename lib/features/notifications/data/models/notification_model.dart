/// مجموعة الإشعارات حسب التاريخ
enum NotificationGroup {
  today('اليوم'),
  yesterday('أمس'),
  older('سابق');

  const NotificationGroup(this.label);

  final String label;
}

/// نموذج إشعار
class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.group,
    required this.title,
    required this.description,
    required this.timeLabel,
    this.isRead = true,
  });

  final String id;
  final NotificationGroup group;
  final String title;
  final String description;
  final String timeLabel;
  final bool isRead;

  bool get isHighlighted => !isRead;

  AppNotificationModel copyWith({
    bool? isRead,
  }) {
    return AppNotificationModel(
      id: id,
      group: group,
      title: title,
      description: description,
      timeLabel: timeLabel,
      isRead: isRead ?? this.isRead,
    );
  }
}
