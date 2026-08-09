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
import '../../../core/network/erp_media_url.dart';
import 'models/order_model.dart';
import 'models/orders_list_state.dart';
import 'models/order_status.dart';
import 'order_image_cache_storage.dart';

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
    imageCache: ref.watch(orderImageCacheStorageProvider),
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
    required OrderImageCacheStorage imageCache,
  })  : _api = api,
        _createInvoiceApi = createInvoiceApi,
        _authStorage = authStorage,
        _partyResolver = partyResolver,
        _imageCache = imageCache;

  final AmanRestApi _api;
  final CreateInvoiceApi _createInvoiceApi;
  final AuthStorage _authStorage;
  final ErpPartyResolver _partyResolver;
  final OrderImageCacheStorage _imageCache;
  final Map<String, String> _productImageMemory = {};
  final Map<String, Map<String, dynamic>> _invoiceRecordCache = {};

  static const _imageFetchBatchSize = 3;

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

    _cacheInvoiceRecords(result.items);
    final orders = _applyCachedImages(ErpOrderMapper.fromRecords(result.items));

    return OrdersFetchResult(
      orders: orders,
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

  /// صورة معاينة من الفاتورة مباشرة — كاش ثم API ثم منتج
  Future<String?> resolveInvoicePreviewImage(String orderId) async {
    if (orderId.isEmpty) return null;

    final cached = _imageCache.load(orderId);
    if (cached != null && cached.isNotEmpty) return cached;

    if (!_hasToken) return null;

    try {
      final record = await _api.getById(ApiEndpoints.salesInvoice(orderId));
      var url = ErpOrderMapper.previewImageFromRecord(record);

      if (url == null) {
        final productId = ErpOrderMapper.firstProductIdFromRecord(record);
        if (productId != null) {
          url = await _productImageUrl(productId);
        }
      }

      if (url != null && url.isNotEmpty) {
        await _imageCache.save(orderId, url);
      }

      return url;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _productImageUrl(String productId) async {
    final cached = _productImageMemory[productId];
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final record = await _api.getById(ApiEndpoints.product(productId));
      final url = ErpMediaUrl.resolve(record: record, main: record);
      if (url != null && url.isNotEmpty) {
        _productImageMemory[productId] = url;
      }
      return url;
    } catch (_) {
      return null;
    }
  }

  /// يجلب صور المعاينة من تفاصيل الفاتورة إن لم تتوفر في القائمة
  Future<List<OrderModel>> enrichMissingOrderImages(
    List<OrderModel> orders,
  ) async {
    if (!_hasToken || orders.isEmpty) return orders;

    final withCache = _applyCachedImages(orders);
    final missingIds = withCache
        .where((order) => order.imageUrl == null || order.imageUrl!.isEmpty)
        .map((order) => order.id)
        .toList();

    if (missingIds.isEmpty) return withCache;

    final updates = <String, String>{};

    for (var i = 0; i < missingIds.length; i += _imageFetchBatchSize) {
      final batch = missingIds.skip(i).take(_imageFetchBatchSize);
      await Future.wait(
        batch.map((orderId) async {
          final url = await resolveInvoicePreviewImage(orderId);
          if (url != null && url.isNotEmpty) {
            updates[orderId] = url;
          }
        }),
      );
    }

    if (updates.isEmpty) return withCache;

    return withCache
        .map(
          (order) => updates.containsKey(order.id)
              ? order.copyWith(imageUrl: updates[order.id])
              : order,
        )
        .toList();
  }

  Future<OrderDetailModel?> fetchOrderDetail(String orderId) async {
    final cached = _invoiceRecordCache[orderId];
    if (cached != null) {
      return _buildDetailFromRecord(orderId, cached);
    }

    if (!_hasToken) {
      throw const ApiException(
        message: 'مفتاح API غير متوفر — راجع إعدادات أمان ERP',
        statusCode: 401,
        type: ApiExceptionType.unauthorized,
      );
    }

    final record = await _api.getById(ApiEndpoints.salesInvoice(orderId));
    _cacheInvoiceRecord(record);
    return _buildDetailFromRecord(orderId, record);
  }

  void _cacheInvoiceRecords(List<Map<String, dynamic>> records) {
    for (final record in records) {
      _cacheInvoiceRecord(record);
    }
  }

  void _cacheInvoiceRecord(Map<String, dynamic> record) {
    final id = (record['id'] ?? '').toString();
    if (id.isEmpty) return;
    _invoiceRecordCache[id] = record;
  }

  Future<OrderDetailModel?> _buildDetailFromRecord(
    String orderId,
    Map<String, dynamic> record,
  ) async {
    final detail = ErpOrderMapper.detailFromRecord(record);
    if (detail == null) return null;

    var preview = detail.previewImageUrl;
    if (preview == null) {
      final productId = ErpOrderMapper.firstProductIdFromRecord(record);
      if (productId != null) {
        preview = await _productImageUrl(productId);
      }
    }

    if (preview != null && preview.isNotEmpty) {
      await _imageCache.save(orderId, preview);
    }

    final items = preview != null && preview.isNotEmpty
        ? _mergeLineItemImages(detail.items, preview)
        : detail.items;

    return OrderDetailModel(
      id: detail.id,
      orderName: detail.orderName,
      address: detail.address,
      price: detail.price,
      status: detail.status,
      imageUrl: preview ?? detail.imageUrl,
      imageBgColor: detail.imageBgColor,
      customerName: detail.customerName,
      phone: detail.phone,
      altPhone: detail.altPhone,
      deliveryAddress: detail.deliveryAddress,
      orderDate: detail.detailOrderDate,
      items: items,
      deliveryPrice: detail.deliveryPrice,
      deliveryMethodLabel: detail.deliveryMethodLabel,
    );
  }

  List<OrderLineItem> _mergeLineItemImages(
    List<OrderLineItem> items,
    String previewUrl,
  ) {
    if (items.isEmpty) return items;
    final first = items.first;
    if (first.imageUrl != null && first.imageUrl!.isNotEmpty) return items;

    return [
      OrderLineItem(
        productId: first.productId,
        productName: first.productName,
        quantity: first.quantity,
        price: first.price,
        imageUrl: previewUrl,
        imageBgColor: first.imageBgColor,
      ),
      ...items.skip(1),
    ];
  }

  List<OrderModel> _applyCachedImages(List<OrderModel> orders) {
    return orders
        .map((order) {
          if (order.imageUrl != null && order.imageUrl!.isNotEmpty) {
            return order;
          }
          final cached = _imageCache.load(order.id);
          if (cached == null) return order;
          return order.copyWith(imageUrl: cached);
        })
        .toList();
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

    if (draft.items.isEmpty) {
      throw const ApiException(message: 'بيانات الطلب غير مكتملة');
    }

    if (draft.requiresAddress && draft.selectedAddress == null) {
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
    final addressLabel = draft.deliveryAddressLabel;
    final firstItem = draft.items.first.product;
    final number = created.elementNumber.isNotEmpty
        ? created.elementNumber
        : 'طلب ${draft.totalQuantity} منتج';

    final order = OrderDetailModel(
      id: created.id,
      orderName: number,
      address: addressLabel,
      price: draft.subtotal,
      status: OrderStatus.reviewing,
      imageUrl: firstItem.imageUrl,
      imageBgColor: firstItem.imageBgColor,
      customerName: draft.customerName,
      phone: draft.phone,
      altPhone: draft.secondPhone.isEmpty ? null : draft.secondPhone,
      deliveryAddress: addressLabel,
      orderDate: DateTime.now(),
      deliveryPrice: 0,
      deliveryMethodLabel: draft.deliveryMethod.label,
      items: draft.items
          .map(
            (item) => OrderLineItem(
              productId: item.product.id,
              productName: item.product.name,
              quantity: item.quantity,
              price: item.product.price,
              imageUrl: item.product.imageUrl,
              imageBgColor: item.product.imageBgColor,
            ),
          )
          .toList(),
    );

    final preview = order.previewImageUrl;
    if (preview != null && preview.isNotEmpty) {
      await _imageCache.save(created.id, preview);
    }

    return order;
  }
}
