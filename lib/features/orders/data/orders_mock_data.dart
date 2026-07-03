import 'package:flutter/material.dart';

import 'models/order_model.dart';
import 'models/order_status.dart';

/// بيانات تجريبية لصفحة الفواتير
abstract final class OrdersMockData {
  static const _lineItem = OrderLineItem(
    productName: 'مصفف شعر',
    quantity: 1,
    price: 26000,
    imageBgColor: Color(0xFFE9E4F5),
  );

  static const orders = [
    OrderModel(
      id: '1',
      orderName: 'أسم الطلب',
      address: 'العنوان',
      price: 26000,
      status: OrderStatus.delivering,
    ),
    OrderModel(
      id: '2',
      orderName: 'أسم الطلب',
      address: 'العنوان',
      price: 26000,
      status: OrderStatus.delivered,
      imageBgColor: Color(0xFFE4EAF8),
    ),
    OrderModel(
      id: '3',
      orderName: 'أسم الطلب',
      address: 'العنوان',
      price: 26000,
      status: OrderStatus.cancelled,
    ),
    OrderModel(
      id: '4',
      orderName: 'أسم الطلب',
      address: 'العنوان',
      price: 26000,
      status: OrderStatus.delivered,
      imageBgColor: Color(0xFFF0E8F5),
    ),
  ];

  static OrderDetailModel detailFor(String id) {
    final order = orders.firstWhere(
      (o) => o.id == id,
      orElse: () => orders.first,
    );

    return OrderDetailModel(
      id: order.id,
      orderName: order.orderName,
      address: order.address,
      price: order.price,
      status: order.status,
      imageUrl: order.imageUrl,
      imageBgColor: order.imageBgColor,
      customerName: 'نونة الحنونة',
      phone: '0700 000 000',
      altPhone: null,
      deliveryAddress: 'بابل - شارع 40',
      orderDate: DateTime(2026, 2, 6),
      items: const [_lineItem, _lineItem],
      deliveryPrice: 0,
    );
  }
}
