import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/advanced_filter_api.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/models/advanced_filter_models.dart';
import '../../auth/data/auth_storage.dart';
import 'erp_order_mapper.dart';
import 'models/order_model.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(
    api: ref.watch(advancedFilterApiProvider),
    authStorage: ref.watch(authStorageProvider),
  );
});

class OrdersFetchResult {
  const OrdersFetchResult({
    required this.orders,
    required this.total,
  });

  final List<OrderModel> orders;
  final int total;
}

/// مستودع فواتير ERP — sales_invoices
class OrdersRepository {
  OrdersRepository({
    required AdvancedFilterApi api,
    required AuthStorage authStorage,
  })  : _api = api,
        _authStorage = authStorage;

  final AdvancedFilterApi _api;
  final AuthStorage _authStorage;

  Future<OrdersFetchResult> fetchOrders() async {
    if (!_authStorage.isLoggedIn) {
      return const OrdersFetchResult(orders: [], total: 0);
    }

    try {
      final result = await _api.fetch(
        request: const AdvancedFilterRequest(
          tableName: ErpTables.salesInvoices,
          filters: [],
          sorts: [
            AdvancedFilterSort(field: 'id', direction: 'desc'),
          ],
          perPage: 50,
          page: 1,
        ),
      );

      return OrdersFetchResult(
        orders: ErpOrderMapper.fromRecords(result.items),
        total: result.total,
      );
    } on ApiException {
      return const OrdersFetchResult(orders: [], total: 0);
    }
  }

  Future<OrderDetailModel?> fetchOrderDetail(String orderId) async {
    if (!_authStorage.isLoggedIn) return null;

    try {
      final result = await _api.fetch(
        request: AdvancedFilterRequest(
          tableName: ErpTables.salesInvoices,
          filters: [
            AdvancedFilterClause(
              field: 'id',
              operator: '=',
              value: orderId,
            ),
          ],
          sorts: const [],
          perPage: 1,
          page: 1,
        ),
      );

      if (result.items.isEmpty) return null;
      return ErpOrderMapper.detailFromRecord(result.items.first);
    } on ApiException {
      return null;
    }
  }
}
