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
    final previous = state.value;

    final result = await AsyncValue.guard(() async {
      final page = await ref.read(ordersRepositoryProvider).fetchOrdersPage(1);
      return page;
    });

    if (result.hasError && previous != null) {
      state = AsyncData(previous);
      return;
    }

    state = result;
  }

  /// تحديث صامت في الخلفية — بدون مؤشر تحميل كامل
  Future<void> refreshInBackground() async {
    final previous = state.value;
    if (previous == null) return;

    try {
      final fresh =
          await ref.read(ordersRepositoryProvider).fetchOrdersPage(1);
      state = AsyncData(_mergeBackgroundRefresh(previous, fresh));
    } catch (_) {
      // الإبقاء على البيانات الحالية عند فشل التحديث الصامت
    }
  }

  OrdersListState _mergeBackgroundRefresh(
    OrdersListState previous,
    OrdersListState fresh,
  ) {
    if (previous.currentPage <= 1) return fresh;

    final existingIds = previous.orders.map((o) => o.id).toSet();
    final newOrders =
        fresh.orders.where((o) => !existingIds.contains(o.id)).toList();

    if (newOrders.isEmpty &&
        fresh.total == previous.total &&
        fresh.lastPage == previous.lastPage) {
      return previous;
    }

    return previous.copyWith(
      orders: [...newOrders, ...previous.orders],
      total: fresh.total,
      lastPage: fresh.lastPage,
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
