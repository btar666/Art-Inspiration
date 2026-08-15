import 'models/order_model.dart';
import 'models/order_status.dart';
import '../../../core/network/erp_media_url.dart';

/// تحويل فواتير sales_invoices من أمان ERP
abstract final class ErpOrderMapper {
  static List<OrderModel> fromRecords(List<Map<String, dynamic>> records) {
    return records.map(fromRecord).whereType<OrderModel>().toList();
  }

  static OrderModel? fromRecord(Map<String, dynamic> record) {
    final id = (record['id'] ?? '').toString();
    if (id.isEmpty) return null;

    final number = _firstNonEmpty([
      record['number'],
      record['invoice_number'],
      record['reference'],
    ]);
    final price = _parsePrice(record['total'] ?? record['subtotal']);
    final statusRaw = (record['status'] ?? '').toString();
    final address = _deliveryAddress(record);
    final imageUrls = previewImagesFromRecord(record);
    final productIds = productIdsFromRecord(record);

    return OrderModel(
      id: id,
      orderName: number.isEmpty ? 'فاتورة #$id' : number,
      address: address,
      price: price,
      status: _mapStatus(statusRaw),
      orderDate: _parseDate(
        record['date'] ??
            record['invoice_date'] ??
            record['issued_at'] ??
            record['created_at'],
      ),
      imageUrl: imageUrls.isEmpty ? null : imageUrls.first,
      imageUrls: imageUrls,
      productIds: productIds,
    );
  }

  static OrderDetailModel? detailFromRecord(Map<String, dynamic> record) {
    final base = fromRecord(record);
    if (base == null) return null;

    final items = _lineItems(_invoiceLines(record));
    final notes = _firstNonEmpty([record['notes'], record['description']]);
    final notesFields = _parseCheckoutNotes(notes);
    final customerName = _firstNonEmpty([
      _customerName(record),
      notesFields.customerName,
    ]);
    final phone = _firstNonEmpty([
      _customerPhone(record),
      notesFields.phone,
    ]);
    final deliveryAddress = _firstNonEmpty([
      notesFields.address,
      _deliveryAddress(record, ''),
    ]);
    final previewImage = base.imageUrl ?? _firstLineItemImageFromItems(items);
    final itemUrls = OrderModel.uniqueImageUrls(items.map((e) => e.imageUrl));
    final itemIds = OrderModel.uniqueIds(items.map((e) => e.productId));

    return OrderDetailModel(
      id: base.id,
      orderName: base.orderName,
      address: deliveryAddress,
      price: base.price,
      status: base.status,
      imageUrl: previewImage,
      imageUrls: itemUrls.isNotEmpty ? itemUrls : base.imageUrls,
      productIds: itemIds.isNotEmpty ? itemIds : base.productIds,
      imageBgColor: base.imageBgColor,
      customerName: customerName.isEmpty ? '—' : customerName,
      phone: phone.isEmpty ? '—' : phone,
      altPhone: _altPhone(record) ?? notesFields.altPhone,
      deliveryAddress: deliveryAddress,
      orderDate: base.orderDate ?? DateTime.now(),
      items: items,
      deliveryPrice: 0,
      deliveryMethodLabel: _firstNonEmpty([
        notesFields.deliveryMethod,
        if (deliveryAddress == OrderDetailModel.pickupAtCompanyLabel)
          OrderDetailModel.pickupAtCompanyLabel,
      ]),
    );
  }

  /// أول صورة منتج من سجل الفاتورة — للقائمة والمعاينة
  static String? previewImageFromRecord(Map<String, dynamic> record) {
    final urls = previewImagesFromRecord(record);
    return urls.isEmpty ? null : urls.first;
  }

  /// حتى 4 صور من بنود الفاتورة
  static List<String> previewImagesFromRecord(Map<String, dynamic> record) {
    final fromLines = _lineItemImageUrls(_invoiceLines(record));
    if (fromLines.isNotEmpty) return fromLines;

    final product = _asMap(record['product'])
        ?? _asMap(record['inventory_product']);
    if (product != null) {
      final url = ErpMediaUrl.resolve(record: record, main: product);
      if (url != null && url.isNotEmpty) return [url];
    }

    return const [];
  }

  /// حتى 4 معرّفات منتج من بنود الفاتورة
  static List<String> productIdsFromRecord(Map<String, dynamic> record) {
    final raw = _invoiceLines(record);
    if (raw is! List) return const [];

    final ids = <String>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final id = _productIdFromLine(Map<String, dynamic>.from(item));
      if (id == null || id.isEmpty || ids.contains(id)) continue;
      ids.add(id);
      if (ids.length >= OrderModel.maxPreviewImages) break;
    }
    return ids;
  }

  /// أول product_id من بنود الفاتورة — للجلب من /products
  static String? firstProductIdFromRecord(Map<String, dynamic> record) {
    final raw = _invoiceLines(record);
    if (raw is! List) return null;

    for (final item in raw) {
      if (item is! Map) continue;
      final id = _productIdFromLine(Map<String, dynamic>.from(item));
      if (id != null) return id;
    }

    return null;
  }

  static dynamic _invoiceLines(Map<String, dynamic> record) {
    return record['items'] ??
        record['lines'] ??
        record['invoice_items'] ??
        record['sales_invoice_items'] ??
        record['invoice_lines'] ??
        record['details'];
  }

  static List<OrderLineItem> _lineItems(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final name = _firstNonEmpty([
            map['name'],
            map['product_name'],
            map['title'],
          ]);
          if (name.isEmpty) return null;

          return OrderLineItem(
            productId: _productIdFromLine(map),
            productName: name,
            quantity: _parsePrice(map['quantity']).clamp(1, 999999),
            price: _parsePrice(map['unit_price'] ?? map['total']),
            imageUrl: _lineItemImageUrl(map),
          );
        })
        .whereType<OrderLineItem>()
        .toList();
  }

  static String? _productIdFromLine(Map<String, dynamic> map) {
    final direct = (map['product_id'] ?? map['productId'] ?? '')
        .toString()
        .trim();
    if (direct.isNotEmpty) return direct;

    final nested = _asMap(map['product']) ??
        _asMap(map['inventory_product']) ??
        _asMap(map['inventoryProduct']);
    final nestedId = nested?['id']?.toString().trim() ?? '';
    return nestedId.isEmpty ? null : nestedId;
  }

  static String? _lineItemImageUrl(Map<String, dynamic> map) {
    final product = _asMap(map['product']) ??
        _asMap(map['inventory_product']) ??
        _asMap(map['inventoryProduct']);
    return ErpMediaUrl.resolve(
      record: map,
      main: product ?? map,
    );
  }

  static List<String> _lineItemImageUrls(dynamic raw) {
    if (raw is! List) return const [];

    final urls = <String>[];
    final seen = <String>{};
    for (final item in raw) {
      if (item is! Map) continue;
      final url = _lineItemImageUrl(Map<String, dynamic>.from(item));
      if (url == null || url.isEmpty || !seen.add(url)) continue;
      urls.add(url);
      if (urls.length >= OrderModel.maxPreviewImages) break;
    }
    return urls;
  }

  static String? _firstLineItemImageFromItems(List<OrderLineItem> items) {
    for (final item in items) {
      final url = item.imageUrl;
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  static String _customerName(Map<String, dynamic> record) {
    final party = _asMap(record['party']) ?? _asMap(record['customer']);
    return _firstNonEmpty([
      party?['name'],
      party?['full_name'],
      record['party_name'],
      record['customer_name'],
      record['client_name'],
    ]);
  }

  static String _customerPhone(Map<String, dynamic> record) {
    final party = _asMap(record['party']) ?? _asMap(record['customer']);
    return _firstNonEmpty([
      party?['phone'],
      party?['mobile'],
      party?['phone_number'],
      record['party_phone'],
      record['customer_phone'],
      record['phone'],
      record['mobile'],
    ]);
  }

  static String? _altPhone(Map<String, dynamic> record) {
    final party = _asMap(record['party']) ?? _asMap(record['customer']);
    final alt = _firstNonEmpty([
      party?['alt_phone'],
      party?['second_phone'],
      record['alt_phone'],
      record['second_phone'],
    ]);
    return alt.isEmpty ? null : alt;
  }

  static String _deliveryAddress(
    Map<String, dynamic> record, [
    String notes = '',
  ]) {
    final party = _asMap(record['party']) ?? _asMap(record['customer']);
    final address = _firstNonEmpty([
      party?['address'],
      party?['full_address'],
      record['delivery_address'],
      record['address'],
      notes,
    ]);
    return address.isEmpty ? '—' : address;
  }

  /// استخراج بيانات الزبون من حقل notes عند إنشاء الفاتورة من التطبيق
  static _CheckoutNotesFields _parseCheckoutNotes(String notes) {
    if (notes.isEmpty) return const _CheckoutNotesFields();

    String? readField(String label) {
      final pattern = RegExp('$label\\s*:\\s*([^|]+)', caseSensitive: false);
      final match = pattern.firstMatch(notes);
      return match?.group(1)?.trim();
    }

    return _CheckoutNotesFields(
      customerName: readField('الزبون'),
      altPhone: readField('هاتف بديل'),
      phone: readField('هاتف'),
      address: readField('عنوان'),
      deliveryMethod: readField('طريقة الاستلام'),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty && text != '—') return text;
    }
    return '';
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ??
          DateTime.tryParse(value.replaceAll('/', '-'));
    }
    return null;
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

class _CheckoutNotesFields {
  const _CheckoutNotesFields({
    this.customerName,
    this.phone,
    this.altPhone,
    this.address,
    this.deliveryMethod,
  });

  final String? customerName;
  final String? phone;
  final String? altPhone;
  final String? address;
  final String? deliveryMethod;
}
