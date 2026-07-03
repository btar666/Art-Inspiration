/// حالة الطلب
enum OrderStatus {
  delivering,
  delivered,
  cancelled;

  String get label => switch (this) {
        OrderStatus.delivering => 'قيد التوصيل',
        OrderStatus.delivered => 'تم التوصيل',
        OrderStatus.cancelled => 'ملغي',
      };
}
