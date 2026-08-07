import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/aman_rest_api.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_storage.dart';
import '../../checkout/data/checkout_provider.dart';
import 'create_invoice_api.dart';
import 'erp_invoice_request_builder.dart';
import 'erp_order_mapper.dart';
import 'erp_party_resolver.dart';
import 'models/order_model.dart';
import 'models/orders_list_state.dart';
import 'models/order_status.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final api = ref.watch(amanRestApiProvider);
  final authStorage = ref.watch(authStorageProvider);
  return OrdersRepository(
    api: api,
    createInvoiceApi: ref.watch(createInvoiceApiProvider),
    authStorage: authStorage,
    partyResolver: ErpPartyResolver(
      api: api,
      authStorage: authStorage,
    ),
  );
});

class OrdersFetchResult {
  const OrdersFetchResult({
    required this.orders,
    required this.total,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  final List<OrderModel> orders;
  final int total;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}

/// مستودع فواتير أمان ERP — sales_invoices
class OrdersRepository {
  OrdersRepository({
    required AmanRestApi api,
    required CreateInvoiceApi createInvoiceApi,
    required AuthStorage authStorage,
    required ErpPartyResolver partyResolver,
  })  : _api = api,
        _createInvoiceApi = createInvoiceApi,
        _authStorage = authStorage,
        _partyResolver = partyResolver;

  final AmanRestApi _api;
  final CreateInvoiceApi _createInvoiceApi;
  final AuthStorage _authStorage;
  final ErpPartyResolver _partyResolver;

  bool get _hasToken {
    final token = _authStorage.accessToken;
    return (token != null && token.isNotEmpty) || ApiConfig.apiToken.isNotEmpty;
  }

  Future<OrdersFetchResult> fetchOrders({int page = 1}) async {
    if (!_hasToken) {
      throw const ApiException(
        message: 'مفتاح API غير متوفر — راجع إعدادات أمان ERP',
        statusCode: 401,
        type: ApiExceptionType.unauthorized,
      );
    }

    final int partyId;
    try {
      partyId = await _partyResolver.resolve(
        phone: _authStorage.user?.phone,
        name: _authStorage.user?.name,
        createIfMissing: false,
      );
    } on ApiException {
      // لم يُنشأ طلب بعد — لا فواتير لهذا الحساب
      return const OrdersFetchResult(orders: [], total: 0);
    }

    final result = await _api.list(
      path: ApiEndpoints.salesInvoices,
      page: page,
      perPage: 50,
      query: {'party_id': partyId},
    );

    return OrdersFetchResult(
      orders: ErpOrderMapper.fromRecords(result.items),
      total: result.total,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
    );
  }

  Future<OrdersListState> fetchOrdersPage(int page) async {
    final result = await fetchOrders(page: page);
    return OrdersListState(
      orders: result.orders,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
      total: result.total,
    );
  }

  Future<OrdersListState> loadMoreOrders(OrdersListState current) async {
    if (!current.hasMore || current.isLoadingMore) return current;

    final nextPage = current.currentPage + 1;
    final result = await fetchOrders(page: nextPage);

    final ids = current.orders.map((o) => o.id).toSet();
    final merged = [...current.orders];
    for (final order in result.orders) {
      if (!ids.contains(order.id)) {
        merged.add(order);
        ids.add(order.id);
      }
    }

    return current.copyWith(
      orders: merged,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
      total: result.total,
      isLoadingMore: false,
    );
  }

  Future<OrderDetailModel?> fetchOrderDetail(String orderId) async {
    if (!_hasToken) {
      throw const ApiException(
        message: 'مفتاح API غير متوفر — راجع إعدادات أمان ERP',
        statusCode: 401,
        type: ApiExceptionType.unauthorized,
      );
    }

    final record = await _api.getById(ApiEndpoints.salesInvoice(orderId));
    return ErpOrderMapper.detailFromRecord(record);
  }

  /// إنشاء فاتورة مبيعات من مسودة الدفع
  Future<OrderDetailModel> createInvoice(CheckoutDraft draft) async {
    if (!_hasToken) {
      throw const ApiException(
        message: 'مفتاح API غير متوفر — راجع إعدادات أمان ERP',
        statusCode: 401,
        type: ApiExceptionType.unauthorized,
      );
    }

    if (draft.selectedAddress == null || draft.items.isEmpty) {
      throw const ApiException(message: 'بيانات الطلب غير مكتملة');
    }

    final partyId = await _partyResolver.resolve(
      phone: draft.phone.isNotEmpty ? draft.phone : _authStorage.user?.phone,
      name: draft.customerName.isNotEmpty
          ? draft.customerName
          : _authStorage.user?.name,
    );

    final body = ErpInvoiceRequestBuilder.build(
      draft: draft,
      partyId: partyId,
    );
    final created = await _createInvoiceApi.create(body);
    final address = draft.selectedAddress!;
    final firstItem = draft.items.first.product;
    final number = created.elementNumber.isNotEmpty
        ? created.elementNumber
        : 'طلب ${draft.totalQuantity} منتج';

    return OrderDetailModel(
      id: created.id,
      orderName: number,
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
