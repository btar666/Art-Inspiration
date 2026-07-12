import '../../../core/network/api_response_parser.dart';
import 'models/order_model.dart';
import 'models/order_status.dart';

/// تحويل فواتير sales_invoices إلى OrderModel
abstract final class ErpOrderMapper {
  static List<OrderModel> fromRecords(List<Map<String, dynamic>> records) {
    return records.map(fromRecord).whereType<OrderModel>().toList();
  }

  static OrderModel? fromRecord(Map<String, dynamic> record) {
    final id = (record['id'] ?? '').toString();
    if (id.isEmpty) return null;

    final main = ApiResponseParser.decodeJsonField(record['main']) ?? {};
    final elementNumber = _firstNonEmpty([
      main['elementNumber'],
      record['elementNumber'],
    ]);

    final price = _parsePrice(record['totalAmount'] ?? main['amount']);
    final address = _firstNonEmpty([
      main['shippingAddressAr'],
      main['shippingAddress'],
      _customerField(main, 'address'),
      _customerField(main, 'city'),
    ]);

    final statusRaw = _firstNonEmpty([
      record['status'],
      main['status'],
    ]);

    return OrderModel(
      id: id,
      orderName: elementNumber.isEmpty ? 'فاتورة #$id' : elementNumber,
      address: address.isEmpty ? '—' : address,
      price: price,
      status: _mapStatus(statusRaw),
    );
  }

  static OrderDetailModel? detailFromRecord(Map<String, dynamic> record) {
    final base = fromRecord(record);
    if (base == null) return null;

    final main = ApiResponseParser.decodeJsonField(record['main']) ?? {};
    final customer = main['customer'];
    final customerMap = customer is Map
        ? Map<String, dynamic>.from(customer)
        : <String, dynamic>{};

    final customerName = _firstNonEmpty([
      customerMap['name'],
      '${customerMap['firstName'] ?? ''} ${customerMap['lastName'] ?? ''}',
      main['customerName'],
    ]);

    final phone = _firstNonEmpty([
      customerMap['phone'],
      _customerField(main, 'phone'),
    ]);

    final issueDate = _parseDate(record['issueDate'] ?? main['issueDate']);
    final items = _lineItems(main['items']);

    return OrderDetailModel(
      id: base.id,
      orderName: base.orderName,
      address: base.address,
      price: base.price,
      status: base.status,
      customerName: customerName.isEmpty ? '—' : customerName.trim(),
      phone: phone.isEmpty ? '—' : phone,
      deliveryAddress: base.address,
      orderDate: issueDate,
      items: items,
      deliveryPrice: _parsePrice(main['shippingCost']),
    );
  }

  static List<OrderLineItem> _lineItems(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final name = _firstNonEmpty([map['productName'], map['name']]);
          if (name.isEmpty) return null;

          return OrderLineItem(
            productName: name,
            quantity: _parsePrice(map['quantity']),
            price: _parsePrice(map['unitPrice'] ?? map['total']),
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

  static String _customerField(Map<String, dynamic> main, String key) {
    final customer = main['customer'];
    if (customer is Map) {
      return customer[key]?.toString().trim() ?? '';
    }
    return '';
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

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}
