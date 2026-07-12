import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/order_model.dart';
import '../../data/orders_repository.dart';

final erpOrdersProvider = FutureProvider<OrdersFetchResult>((ref) async {
  ref.watch(authNotifierProvider);
  return ref.read(ordersRepositoryProvider).fetchOrders();
});

final erpOrdersListProvider = Provider<AsyncValue<List<OrderModel>>>((ref) {
  return ref.watch(erpOrdersProvider).whenData((r) => r.orders);
});

final erpOrdersTotalProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(erpOrdersProvider).whenData((r) => r.total);
});

final erpOrderDetailProvider =
    FutureProvider.family<OrderDetailModel?, String>((ref, orderId) async {
  ref.watch(authNotifierProvider);
  return ref.read(ordersRepositoryProvider).fetchOrderDetail(orderId);
});
