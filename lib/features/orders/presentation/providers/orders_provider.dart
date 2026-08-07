import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/order_model.dart';
import '../../data/models/orders_list_state.dart';
import '../../data/orders_repository.dart';

final ordersListProvider =
    AsyncNotifierProvider<OrdersListNotifier, OrdersListState>(
  OrdersListNotifier.new,
);

class OrdersListNotifier extends AsyncNotifier<OrdersListState> {
  bool _isLoadingMore = false;

  @override
  Future<OrdersListState> build() async {
    ref.watch(authNotifierProvider);
    return ref.read(ordersRepositoryProvider).fetchOrdersPage(1);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(ordersRepositoryProvider).fetchOrdersPage(1),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final updated =
          await ref.read(ordersRepositoryProvider).loadMoreOrders(current);
      state = AsyncData(updated);
    } finally {
      _isLoadingMore = false;
    }
  }
}

/// توافق مع الكود القديم
final erpOrdersProvider = FutureProvider<OrdersFetchResult>((ref) async {
  ref.watch(authNotifierProvider);
  return ref.read(ordersRepositoryProvider).fetchOrders();
});

final erpOrdersListProvider = Provider<AsyncValue<List<OrderModel>>>((ref) {
  return ref.watch(ordersListProvider).whenData((s) => s.orders);
});

final erpOrdersTotalProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(ordersListProvider).whenData((s) => s.total);
});

final erpOrderDetailProvider =
    FutureProvider.family<OrderDetailModel?, String>((ref, orderId) async {
  ref.watch(authNotifierProvider);
  return ref.read(ordersRepositoryProvider).fetchOrderDetail(orderId);
});
