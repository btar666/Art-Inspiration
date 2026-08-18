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
    this.itemId,
    this.productName,
    this.productImageUrl,
  });

  final String id;
  final NotificationGroup group;
  final String title;
  final String description;
  final String timeLabel;
  final bool isRead;
  final String? itemId;
  final String? productName;
  final String? productImageUrl;

  bool get isHighlighted => !isRead;

  bool get hasProduct {
    final id = itemId?.trim() ?? '';
    return id.isNotEmpty && id != '0';
  }

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
      itemId: itemId,
      productName: productName,
      productImageUrl: productImageUrl,
    );
  }
}
