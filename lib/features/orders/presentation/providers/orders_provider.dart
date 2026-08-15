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
    final page = await ref.read(ordersRepositoryProvider).fetchOrdersPage(1);
    _scheduleImageEnrichment(page.orders);
    return page;
  }

  void _scheduleImageEnrichment(List<OrderModel> orders) {
    ref.read(ordersRepositoryProvider).enrichMissingOrderImages(orders).then(
      (enriched) {
        final current = state.value;
        if (current == null) return;
        final merged = _mergeOrderImages(current.orders, enriched);
        if (_ordersEqual(current.orders, merged)) return;
        state = AsyncData(current.copyWith(orders: merged));
      },
    );
  }

  List<OrderModel> _mergeOrderImages(
    List<OrderModel> existing,
    List<OrderModel> enriched,
  ) {
    final byId = {for (final order in enriched) order.id: order};
    return existing
        .map((order) {
          final updated = byId[order.id];
          if (updated == null) return order;
          if (_samePreviewImages(order, updated)) return order;
          return order.copyWith(
            imageUrl: updated.imageUrl,
            imageUrls: updated.imageUrls,
            productIds: updated.productIds,
          );
        })
        .toList();
  }

  bool _ordersEqual(List<OrderModel> a, List<OrderModel> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || !_samePreviewImages(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }

  bool _samePreviewImages(OrderModel a, OrderModel b) {
    final aUrls = a.previewImageUrls;
    final bUrls = b.previewImageUrls;
    if (aUrls.length != bUrls.length) return false;
    for (var i = 0; i < aUrls.length; i++) {
      if (aUrls[i] != bUrls[i]) return false;
    }
    return true;
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
    final orders = result.value?.orders;
    if (orders != null) {
      _scheduleImageEnrichment(orders);
    }
  }

  /// تحديث صامت في الخلفية — بدون مؤشر تحميل كامل
  Future<void> refreshInBackground() async {
    final previous = state.value;
    if (previous == null) return;

    try {
      final fresh =
          await ref.read(ordersRepositoryProvider).fetchOrdersPage(1);
      final mergedState = _mergeBackgroundRefresh(previous, fresh);
      state = AsyncData(mergedState);
      _scheduleImageEnrichment(mergedState.orders);
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
      _scheduleImageEnrichment(updated.orders);
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

/// صورة معاينة الفاتورة — يجلب مباشرة من API الفاتورة
final orderPreviewImageProvider =
    FutureProvider.family<String?, String>((ref, orderId) async {
  ref.watch(authNotifierProvider);
  return ref.read(ordersRepositoryProvider).resolveInvoicePreviewImage(orderId);
});
