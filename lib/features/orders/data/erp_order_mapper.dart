import 'models/order_model.dart';
import 'models/order_status.dart';

/// تحويل فواتير sales_invoices من أمان ERP
abstract final class ErpOrderMapper {
  static List<OrderModel> fromRecords(List<Map<String, dynamic>> records) {
    return records.map(fromRecord).whereType<OrderModel>().toList();
  }

  static OrderModel? fromRecord(Map<String, dynamic> record) {
    final id = (record['id'] ?? '').toString();
    if (id.isEmpty) return null;

    final number = (record['number'] ?? '').toString().trim();
    final price = _parsePrice(record['total'] ?? record['subtotal']);
    final statusRaw = (record['status'] ?? '').toString();

    return OrderModel(
      id: id,
      orderName: number.isEmpty ? 'فاتورة #$id' : number,
      address: '—',
      price: price,
      status: _mapStatus(statusRaw),
    );
  }

  static OrderDetailModel? detailFromRecord(Map<String, dynamic> record) {
    final base = fromRecord(record);
    if (base == null) return null;

    final items = _lineItems(record['items']);
    final notes = (record['notes'] ?? '').toString().trim();

    return OrderDetailModel(
      id: base.id,
      orderName: base.orderName,
      address: notes.isEmpty ? base.address : notes,
      price: base.price,
      status: base.status,
      customerName: '—',
      phone: '—',
      deliveryAddress: notes.isEmpty ? base.address : notes,
      orderDate: _parseDate(record['date'] ?? record['created_at']),
      items: items,
      deliveryPrice: 0,
    );
  }

  static List<OrderLineItem> _lineItems(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final name = (map['name'] ?? '').toString().trim();
          if (name.isEmpty) return null;

          return OrderLineItem(
            productName: name,
            quantity: _parsePrice(map['quantity']).clamp(1, 999999),
            price: _parsePrice(map['unit_price'] ?? map['total']),
          );
        })
        .whereType<OrderLineItem>()
        .toList();
  }

  static OrderStatus _mapStatus(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('paid') || value.contains('complete')) {
      return OrderStatus.delivered;
    }
    if (value.contains('partial') || value.contains('deliver')) {
      return OrderStatus.delivering;
    }
    if (value.contains('cancel')) {
      return OrderStatus.cancelled;
    }
    return OrderStatus.reviewing;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static int _parsePrice(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned)?.round() ?? 0;
    }
    return 0;
  }
}
