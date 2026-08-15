import 'package:flutter/material.dart';

import 'order_status.dart';

/// عنصر منتج داخل الطلب
class OrderLineItem {
  const OrderLineItem({
    this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.imageBgColor = const Color(0xFFE9E4F5),
  });

  final String? productId;
  final String productName;
  final int quantity;
  final int price;
  final String? imageUrl;
  final Color imageBgColor;

  String get formattedPrice => _formatPrice(price);

  OrderLineItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    int? price,
    String? imageUrl,
    Color? imageBgColor,
  }) {
    return OrderLineItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBgColor: imageBgColor ?? this.imageBgColor,
    );
  }

  static String _formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$formatted د.ع';
  }
}

/// نموذج الطلب — قائمة الفواتير
class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderName,
    required this.address,
    required this.price,
    required this.status,
    this.orderDate,
    this.imageUrl,
    this.imageUrls = const [],
    this.productIds = const [],
    this.imageBgColor = const Color(0xFFE9E4F5),
  });

  static const int maxPreviewImages = 4;

  final String id;
  final String orderName;
  final String address;
  final int price;
  final OrderStatus status;
  final DateTime? orderDate;
  final String? imageUrl;
  final List<String> imageUrls;
  final List<String> productIds;
  final Color imageBgColor;

  /// صور المعاينة للبطاقة — حتى 4
  List<String> get previewImageUrls {
    if (imageUrls.isNotEmpty) {
      return uniqueImageUrls(imageUrls);
    }
    final single = imageUrl?.trim();
    if (single != null && single.isNotEmpty) return [single];
    return const [];
  }

  static List<String> uniqueImageUrls(Iterable<String?> raw) {
    final seen = <String>{};
    final urls = <String>[];
    for (final value in raw) {
      final url = value?.trim() ?? '';
      if (url.isEmpty || !seen.add(url)) continue;
      urls.add(url);
      if (urls.length >= maxPreviewImages) break;
    }
    return urls;
  }

  static List<String> uniqueIds(Iterable<String?> raw) {
    final seen = <String>{};
    final ids = <String>[];
    for (final value in raw) {
      final id = value?.trim() ?? '';
      if (id.isEmpty || !seen.add(id)) continue;
      ids.add(id);
      if (ids.length >= maxPreviewImages) break;
    }
    return ids;
  }

  String get formattedPrice => OrderLineItem._formatPrice(price);

  String get formattedOrderDate {
    final date = orderDate;
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  OrderModel copyWith({
    String? imageUrl,
    List<String>? imageUrls,
    List<String>? productIds,
    Color? imageBgColor,
  }) {
    final urls = imageUrls ?? this.imageUrls;
    return OrderModel(
      id: id,
      orderName: orderName,
      address: address,
      price: price,
      status: status,
      orderDate: orderDate,
      imageUrl: imageUrl ?? (urls.isNotEmpty ? urls.first : this.imageUrl),
      imageUrls: urls,
      productIds: productIds ?? this.productIds,
      imageBgColor: imageBgColor ?? this.imageBgColor,
    );
  }
}

/// تفاصيل الطلب الكاملة
class OrderDetailModel extends OrderModel {
  const OrderDetailModel({
    required super.id,
    required super.orderName,
    required super.address,
    required super.price,
    required super.status,
    required DateTime orderDate,
    super.imageUrl,
    super.imageUrls,
    super.productIds,
    super.imageBgColor,
    required this.customerName,
    required this.phone,
    required this.deliveryAddress,
    required this.items,
    this.altPhone,
    this.deliveryPrice = 0,
    this.deliveryMethodLabel = '',
  }) : super(orderDate: orderDate);

  static const pickupAtCompanyLabel = 'استلام في الشركة';
  static const deliveryLabel = 'توصيل';

  final String customerName;
  final String phone;
  final String? altPhone;
  final String deliveryAddress;
  final List<OrderLineItem> items;
  final int deliveryPrice;
  final String deliveryMethodLabel;

  String get displayDeliveryMethodLabel {
    final trimmed = deliveryMethodLabel.trim();
    if (trimmed.isNotEmpty) return trimmed;

    final address = deliveryAddress.trim();
    if (address == pickupAtCompanyLabel) return pickupAtCompanyLabel;
    return deliveryLabel;
  }

  bool get isPickupAtCompany =>
      displayDeliveryMethodLabel == pickupAtCompanyLabel;

  DateTime get detailOrderDate => orderDate ?? DateTime.now();

  int get totalPrice => price;

  String get formattedTotalPrice => formattedPrice;

  @override
  String get formattedOrderDate {
    final date = detailOrderDate;
    return '${date.year} - ${date.month} - ${date.day}';
  }

  /// أول صورة متوفرة — للمعاينة في قائمة الفواتير
  String? get previewImageUrl {
    final urls = previewImageUrls;
    return urls.isEmpty ? null : urls.first;
  }

  @override
  List<String> get previewImageUrls {
    final fromItems = OrderModel.uniqueImageUrls(items.map((e) => e.imageUrl));
    if (fromItems.isNotEmpty) return fromItems;
    return super.previewImageUrls;
  }
}
