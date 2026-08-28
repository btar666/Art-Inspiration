import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';
import '../../../core/storage/user_cache_key_provider.dart';
import '../../../core/storage/user_scoped_keys.dart';
import '../../orders/data/models/order_model.dart';
import '../../orders/data/models/order_status.dart';

/// تخزين الطلبات محلياً — مفصول لكل حساب
class LocalOrdersStorage {
  LocalOrdersStorage(this._prefs);

  final SharedPreferences _prefs;

  List<OrderDetailModel> loadOrders(String userKey) {
    final raw = UserScopedPrefs.readString(
      _prefs,
      baseKey: AppConstants.localOrdersKey,
      userKey: userKey,
    );
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => orderDetailFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveOrders(
    String userKey,
    List<OrderDetailModel> orders,
  ) async {
    final encoded = jsonEncode(orders.map((e) => e.toJson()).toList());
    await UserScopedPrefs.writeString(
      _prefs,
      baseKey: AppConstants.localOrdersKey,
      userKey: userKey,
      value: encoded,
    );
  }
}

final localOrdersStorageProvider = Provider<LocalOrdersStorage>((ref) {
  return LocalOrdersStorage(ref.watch(sharedPreferencesProvider));
});

class LocalOrdersNotifier extends Notifier<List<OrderDetailModel>> {
  @override
  List<OrderDetailModel> build() {
    final userKey = ref.watch(activeUserCacheKeyProvider);
    return ref.read(localOrdersStorageProvider).loadOrders(userKey);
  }

  Future<void> _persist() => ref.read(localOrdersStorageProvider).saveOrders(
        ref.read(activeUserCacheKeyProvider),
        state,
      );

  Future<void> addOrder(OrderDetailModel order) async {
    state = [order, ...state];
    await _persist();
  }

  OrderDetailModel? orderById(String id) {
    try {
      return state.firstWhere((order) => order.id == id);
    } catch (_) {
      return null;
    }
  }
}

final localOrdersNotifierProvider =
    NotifierProvider<LocalOrdersNotifier, List<OrderDetailModel>>(
  LocalOrdersNotifier.new,
);

Map<String, dynamic> orderLineItemToJson(OrderLineItem item) => {
      'productId': item.productId,
      'productName': item.productName,
      'quantity': item.quantity,
      'price': item.price,
      'imageUrl': item.imageUrl,
      'imageBgColor': item.imageBgColor.toARGB32(),
    };

Map<String, dynamic> orderDetailToJson(OrderDetailModel order) => {
      'id': order.id,
      'orderName': order.orderName,
      'address': order.address,
      'price': order.price,
      'status': order.status.name,
      'imageUrl': order.imageUrl,
      'imageBgColor': order.imageBgColor.toARGB32(),
      'customerName': order.customerName,
      'phone': order.phone,
      'altPhone': order.altPhone,
      'deliveryAddress': order.deliveryAddress,
      'orderDate': order.detailOrderDate.toIso8601String(),
      'deliveryPrice': order.deliveryPrice,
      'deliveryMethodLabel': order.deliveryMethodLabel,
      'items': order.items.map(orderLineItemToJson).toList(),
    };

OrderDetailModel orderDetailFromJson(Map<String, dynamic> json) {
  final itemsJson = json['items'] as List<dynamic>? ?? [];
  return OrderDetailModel(
    id: json['id'] as String,
    orderName: json['orderName'] as String? ?? 'طلب جديد',
    address: json['address'] as String? ?? '',
    price: json['price'] as int? ?? 0,
    status: OrderStatus.values.byName(json['status'] as String? ?? 'reviewing'),
    imageUrl: json['imageUrl'] as String?,
    imageBgColor: Color(json['imageBgColor'] as int? ?? 0xFFE9E4F5),
    customerName: json['customerName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    altPhone: json['altPhone'] as String?,
    deliveryAddress: json['deliveryAddress'] as String? ?? '',
    orderDate:
        DateTime.tryParse(json['orderDate'] as String? ?? '') ?? DateTime.now(),
    deliveryPrice: json['deliveryPrice'] as int? ?? 0,
    deliveryMethodLabel: json['deliveryMethodLabel'] as String? ?? '',
    items: itemsJson
        .map(
          (e) => OrderLineItem(
            productId: e['productId'] as String?,
            productName: e['productName'] as String? ?? '',
            quantity: e['quantity'] as int? ?? 1,
            price: e['price'] as int? ?? 0,
            imageUrl: e['imageUrl'] as String?,
            imageBgColor: Color(e['imageBgColor'] as int? ?? 0xFFE9E4F5),
          ),
        )
        .toList(),
  );
}

extension OrderDetailModelJson on OrderDetailModel {
  Map<String, dynamic> toJson() => orderDetailToJson(this);
}
