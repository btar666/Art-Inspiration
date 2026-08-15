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

  /// صور معاينة من الفاتورة مباشرة — كاش ثم API ثم منتجات
  Future<String?> resolveInvoicePreviewImage(String orderId) async {
    final urls = await resolveInvoicePreviewImages(orderId);
    return urls.isEmpty ? null : urls.first;
  }

  Future<List<String>> resolveInvoicePreviewImages(String orderId) async {
    if (orderId.isEmpty) return const [];

    final cached = _imageCache.loadAll(orderId);
    if (cached.length >= OrderModel.maxPreviewImages) return cached;

    if (!_hasToken) return cached;

    try {
      final record = await _api.getById(ApiEndpoints.salesInvoice(orderId));
      final urls = await _imagesFromInvoiceRecord(record, existing: cached);
      if (urls.isNotEmpty) {
        await _imageCache.saveAll(orderId, urls);
      }
      return urls;
    } catch (_) {
      return cached;
    }
  }

  Future<List<String>> _imagesFromInvoiceRecord(
    Map<String, dynamic> record, {
    List<String> existing = const [],
  }) async {
    final urls = [...existing];
    final seen = urls.toSet();

    void add(String? url) {
      final trimmed = url?.trim() ?? '';
      if (trimmed.isEmpty || !seen.add(trimmed)) return;
      if (urls.length >= OrderModel.maxPreviewImages) return;
      urls.add(trimmed);
    }

    for (final url in ErpOrderMapper.previewImagesFromRecord(record)) {
      add(url);
    }

    for (final productId in ErpOrderMapper.productIdsFromRecord(record)) {
      if (urls.length >= OrderModel.maxPreviewImages) break;
      add(await _productImageUrl(productId));
    }

    return OrderModel.uniqueImageUrls(urls);
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
    final missing = withCache.where(_needsMorePreviewImages).toList();

    if (missing.isEmpty) return withCache;

    final updates = <String, List<String>>{};

    for (var i = 0; i < missing.length; i += _imageFetchBatchSize) {
      final batch = missing.skip(i).take(_imageFetchBatchSize);
      await Future.wait(
        batch.map((order) async {
          final urls = await _resolveOrderPreviewImages(order);
          if (urls.isNotEmpty) {
            updates[order.id] = urls;
          }
        }),
      );
    }

    if (updates.isEmpty) return withCache;

    return withCache
        .map(
          (order) => updates.containsKey(order.id)
              ? order.copyWith(
                  imageUrls: updates[order.id],
                  imageUrl: updates[order.id]!.first,
                )
              : order,
        )
        .toList();
  }

  bool _needsMorePreviewImages(OrderModel order) {
    final have = order.previewImageUrls.length;
    if (have >= OrderModel.maxPreviewImages) return false;
    final want = order.productIds.isEmpty
        ? (have == 0 ? 1 : have)
        : order.productIds.length.clamp(1, OrderModel.maxPreviewImages);
    return have < want;
  }

  Future<List<String>> _resolveOrderPreviewImages(OrderModel order) async {
    final urls = [...order.previewImageUrls];
    final seen = urls.toSet();

    final fetched = await Future.wait(
      order.productIds
          .take(OrderModel.maxPreviewImages)
          .map(_productImageUrl),
    );
    for (final url in fetched) {
      if (urls.length >= OrderModel.maxPreviewImages) break;
      final trimmed = url?.trim() ?? '';
      if (trimmed.isEmpty || !seen.add(trimmed)) continue;
      urls.add(trimmed);
    }

    if (urls.length >= _wantedPreviewCount(order) ||
        (urls.isNotEmpty && order.productIds.isNotEmpty)) {
      await _imageCache.saveAll(order.id, urls);
      return urls;
    }

    return resolveInvoicePreviewImages(order.id);
  }

  int _wantedPreviewCount(OrderModel order) {
    if (order.productIds.isEmpty) return 1;
    return order.productIds.length.clamp(1, OrderModel.maxPreviewImages);
  }

  Future<OrderDetailModel?> fetchOrderDetail(String orderId) async {
    final cached = _invoiceRecordCache[orderId];
    if (cached != null && !_needsFullInvoiceRecord(cached)) {
      return _buildDetailFromRecord(orderId, cached);
    }

    if (!_hasToken) {
      throw const ApiException(
        message: 'مفتاح API غير متوفر — راجع إعدادات أمان ERP',
        statusCode: 401,
        type: ApiExceptionType.unauthorized,
      );
    }

    try {
      final record = await _api.getById(ApiEndpoints.salesInvoice(orderId));
      _cacheInvoiceRecord(record);
      return _buildDetailFromRecord(orderId, record);
    } catch (_) {
      if (cached != null) {
        return _buildDetailFromRecord(orderId, cached);
      }
      rethrow;
    }
  }

  bool _needsFullInvoiceRecord(Map<String, dynamic> record) {
    final detail = ErpOrderMapper.detailFromRecord(record);
    if (detail == null || detail.items.isEmpty) return true;
    return detail.items.any((item) {
      final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
      final hasProductId = item.productId != null && item.productId!.trim().isNotEmpty;
      return !hasImage && !hasProductId;
    });
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

    final items = await _enrichLineItemImages(detail.items);

    var preview = _firstItemImageUrl(items) ?? detail.previewImageUrl;
    if (preview == null) {
      final productId = ErpOrderMapper.firstProductIdFromRecord(record);
      if (productId != null) {
        preview = await _productImageUrl(productId);
      }
    }

    final previewUrls = OrderModel.uniqueImageUrls(items.map((e) => e.imageUrl));
    if (preview == null && previewUrls.isNotEmpty) {
      preview = previewUrls.first;
    }

    if (previewUrls.isNotEmpty) {
      await _imageCache.saveAll(orderId, previewUrls);
    } else if (preview != null && preview.isNotEmpty) {
      await _imageCache.save(orderId, preview);
    }

    return OrderDetailModel(
      id: detail.id,
      orderName: detail.orderName,
      address: detail.address,
      price: detail.price,
      status: detail.status,
      imageUrl: preview ?? detail.imageUrl,
      imageUrls: previewUrls.isNotEmpty ? previewUrls : detail.imageUrls,
      productIds: OrderModel.uniqueIds(items.map((e) => e.productId)),
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

  /// يجلب صورة كل بند من /products عند غيابها في الفاتورة
  Future<List<OrderLineItem>> _enrichLineItemImages(
    List<OrderLineItem> items,
  ) async {
    if (items.isEmpty) return items;

    final missingIndexes = <int>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;
      final productId = item.productId?.trim() ?? '';
      if (!hasImage && productId.isNotEmpty) {
        missingIndexes.add(i);
      }
    }
    if (missingIndexes.isEmpty) return items;

    final urls = List<String?>.filled(items.length, null);
    for (var i = 0; i < missingIndexes.length; i += _imageFetchBatchSize) {
      final batch = missingIndexes.skip(i).take(_imageFetchBatchSize);
      await Future.wait(
        batch.map((index) async {
          final productId = items[index].productId?.trim();
          if (productId == null || productId.isEmpty) return;
          urls[index] = await _productImageUrl(productId);
        }),
      );
    }

    return [
      for (var i = 0; i < items.length; i++)
        (urls[i] != null && urls[i]!.isNotEmpty)
            ? items[i].copyWith(imageUrl: urls[i])
            : items[i],
    ];
  }

  String? _firstItemImageUrl(List<OrderLineItem> items) {
    for (final item in items) {
      final url = item.imageUrl;
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  List<OrderModel> _applyCachedImages(List<OrderModel> orders) {
    return orders
        .map((order) {
          final cached = _imageCache.loadAll(order.id);
          if (cached.isEmpty) return order;
          final merged = OrderModel.uniqueImageUrls([
            ...order.previewImageUrls,
            ...cached,
          ]);
          if (merged.length <= order.previewImageUrls.length) return order;
          return order.copyWith(
            imageUrls: merged,
            imageUrl: merged.first,
          );
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

    final itemUrls = OrderModel.uniqueImageUrls(
      draft.items.map((item) => item.product.imageUrl),
    );
    final itemIds = OrderModel.uniqueIds(
      draft.items.map((item) => item.product.id),
    );

    final order = OrderDetailModel(
      id: created.id,
      orderName: number,
      address: addressLabel,
      price: draft.subtotal,
      status: OrderStatus.reviewing,
      imageUrl: itemUrls.isEmpty ? firstItem.imageUrl : itemUrls.first,
      imageUrls: itemUrls,
      productIds: itemIds,
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

    if (itemUrls.isNotEmpty) {
      await _imageCache.saveAll(created.id, itemUrls);
    }

    return order;
  }
}
