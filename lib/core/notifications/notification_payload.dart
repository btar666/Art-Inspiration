/// استخراج معرف المنتج من بيانات إشعار FCM / الباكند
abstract final class NotificationPayload {
  static String? itemIdFrom(Map<String, dynamic> data) {
    final nested = data['data'];
    final nestedMap = nested is Map ? Map<String, dynamic>.from(nested) : null;

    for (final source in [data, if (nestedMap != null) nestedMap]) {
      for (final key in const [
        'item_id',
        'itemId',
        'product_id',
        'productId',
        'id_item',
        'idItem',
      ]) {
        final parsed = _asId(source[key]);
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  static String? _asId(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text == '0' || text == 'null') return null;
    return text;
  }
}
