import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/advanced_filter_api.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/models/advanced_filter_models.dart';
import '../../auth/data/auth_storage.dart';
import '../../checkout/data/checkout_provider.dart';
import 'create_invoice_api.dart';
import 'erp_invoice_request_builder.dart';
import 'erp_order_mapper.dart';
import 'models/order_model.dart';
import 'models/order_status.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(
    api: ref.watch(advancedFilterApiProvider),
    createInvoiceApi: ref.watch(createInvoiceApiProvider),
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
    required CreateInvoiceApi createInvoiceApi,
    required AuthStorage authStorage,
  })  : _api = api,
        _createInvoiceApi = createInvoiceApi,
        _authStorage = authStorage;

  final AdvancedFilterApi _api;
  final CreateInvoiceApi _createInvoiceApi;
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

  /// إنشاء فاتورة مبيعات من مسودة الدفع
  Future<OrderDetailModel> createInvoice(CheckoutDraft draft) async {
    if (!_authStorage.isLoggedIn) {
      throw const ApiException(
        message: 'سجّل الدخول أولاً لإتمام الطلب',
        statusCode: 401,
        type: ApiExceptionType.unauthorized,
      );
    }

    if (draft.selectedAddress == null || draft.items.isEmpty) {
      throw const ApiException(message: 'بيانات الطلب غير مكتملة');
    }

    for (final item in draft.items) {
      final stock = item.product.stockQuantity;
      if (stock != null && item.quantity > stock) {
        throw ApiException(
          message:
              'الكمية تتجاوز المخزون المتاح للمنتج «${item.product.name}». المتاح: $stock',
          statusCode: 422,
        );
      }
    }

    final body = ErpInvoiceRequestBuilder.build(
      draft: draft,
      user: _authStorage.user,
    );

    final created = await _createInvoiceApi.create(body);
    final address = draft.selectedAddress!;
    final firstItem = draft.items.first.product;
    final elementNumber = created.elementNumber.isNotEmpty
        ? created.elementNumber
        : body['elementNumber']?.toString() ?? '';

    return OrderDetailModel(
      id: created.id,
      orderName: elementNumber.isEmpty
          ? 'طلب ${draft.totalQuantity} منتج'
          : elementNumber,
      address: address.fullAddress,
      price: draft.subtotal,
      status: OrderStatus.reviewing,
      imageUrl: firstItem.imageUrl,
      imageBgColor: firstItem.imageBgColor,
      customerName: draft.customerName,
      phone: draft.phone,
      altPhone: draft.secondPhone.isEmpty ? null : draft.secondPhone,
      deliveryAddress: address.fullAddress,
      orderDate: DateTime.now(),
      deliveryPrice: 0,
      items: draft.items
          .map(
            (item) => OrderLineItem(
              productName: item.product.name,
              quantity: item.quantity,
              price: item.product.price,
              imageUrl: item.product.imageUrl,
              imageBgColor: item.product.imageBgColor,
            ),
          )
          .toList(),
    );
  }
}
