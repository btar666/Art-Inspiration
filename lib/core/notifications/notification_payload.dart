/// استخراج معرف المنتج من بيانات إشعار FCM / الباكند
abstract final class NotificationPayload {
  static String? itemIdFrom(Map<String, dynamic> data) {
    dynamic raw = data['item_id'] ?? data['itemId'];

    if (raw == null && data['data'] is Map) {
      final nested = Map<String, dynamic>.from(data['data'] as Map);
      raw = nested['item_id'] ?? nested['itemId'];
    }

    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty || text == '0' || text == 'null') return null;
    return text;
  }
}
