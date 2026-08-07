import 'package:flutter/material.dart';

import 'order_status.dart';

/// عنصر منتج داخل الطلب
class OrderLineItem {
  const OrderLineItem({
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.imageBgColor = const Color(0xFFE9E4F5),
  });

  final String productName;
  final int quantity;
  final int price;
  final String? imageUrl;
  final Color imageBgColor;

  String get formattedPrice => _formatPrice(price);

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
    this.imageBgColor = const Color(0xFFE9E4F5),
  });

  final String id;
  final String orderName;
  final String address;
  final int price;
  final OrderStatus status;
  final DateTime? orderDate;
  final String? imageUrl;
  final Color imageBgColor;

  String get formattedPrice => OrderLineItem._formatPrice(price);

  String get formattedOrderDate {
    final date = orderDate;
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
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
    super.imageBgColor,
    required this.customerName,
    required this.phone,
    required this.deliveryAddress,
    required this.items,
    this.altPhone,
    this.deliveryPrice = 0,
  }) : super(orderDate: orderDate);

  final String customerName;
  final String phone;
  final String? altPhone;
  final String deliveryAddress;
  final List<OrderLineItem> items;
  final int deliveryPrice;

  DateTime get detailOrderDate => orderDate ?? DateTime.now();

  int get totalPrice => price + deliveryPrice;

  String get formattedTotalPrice => OrderLineItem._formatPrice(totalPrice);

  String get formattedDeliveryPrice =>
      deliveryPrice == 0 ? 'مجاني' : OrderLineItem._formatPrice(deliveryPrice);

  @override
  String get formattedOrderDate {
    final date = detailOrderDate;
    return '${date.year} - ${date.month} - ${date.day}';
  }
}
