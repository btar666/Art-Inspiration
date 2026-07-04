/// حالة الطلب
enum OrderStatus {
  reviewing,
  delivering,
  delivered,
  cancelled;

  String get label => switch (this) {
        OrderStatus.reviewing => 'قيد المراجعة',
        OrderStatus.delivering => 'قيد التوصيل',
        OrderStatus.delivered => 'تم التوصيل',
        OrderStatus.cancelled => 'ملغي',
      };
}
