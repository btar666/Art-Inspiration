import 'models/notification_model.dart';

/// بيانات تجريبية للإشعارات
abstract final class NotificationsMockData {
  static const items = [
    AppNotificationModel(
      id: '1',
      group: NotificationGroup.today,
      title: 'تمت مراجعة طلبك',
      description: 'تمت مراجعة طلبك بنجاح وسيتم التواصل معك قريباً',
      timeLabel: 'الآن',
      isRead: false,
    ),
    AppNotificationModel(
      id: '2',
      group: NotificationGroup.today,
      title: 'وصل التحديث الجديد!',
      description: 'تحقق من أحدث المنتجات والعروض المتوفرة الآن',
      timeLabel: 'منذ 10 دقائق',
      isRead: false,
    ),
    AppNotificationModel(
      id: '3',
      group: NotificationGroup.yesterday,
      title: 'تم شحن طلبك',
      description: 'طلبك في الطريق إليك وسيصل خلال يومين',
      timeLabel: 'أمس',
    ),
    AppNotificationModel(
      id: '4',
      group: NotificationGroup.yesterday,
      title: 'تحديث في حالة الطلب',
      description: 'تم تحديث حالة طلبك إلى قيد التجهيز',
      timeLabel: 'أمس',
    ),
    AppNotificationModel(
      id: '5',
      group: NotificationGroup.yesterday,
      title: 'تم إلغاء الطلب',
      description: 'تم إلغاء طلبك بناءً على طلبك',
      timeLabel: 'أمس',
    ),
    AppNotificationModel(
      id: '6',
      group: NotificationGroup.yesterday,
      title: 'عرض خاص لك',
      description: 'خصم 20% على منتجات العناية بالبشرة',
      timeLabel: 'أمس',
    ),
    AppNotificationModel(
      id: '7',
      group: NotificationGroup.yesterday,
      title: 'لم تتم معالجة طلبك بعد',
      description: 'طلبك قيد المراجعة وسنخبرك عند اكتمال المعالجة',
      timeLabel: 'أمس',
    ),
  ];

  static List<AppNotificationModel> forGroup(NotificationGroup group) {
    return items.where((item) => item.group == group).toList();
  }
}
