import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/aman_rest_api.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_storage.dart';
import 'catalog_offline_storage.dart';
import 'erp_catalog_metadata.dart';
import 'erp_product_mapper.dart';
import 'home_mock_data.dart';
import 'models/catalog_snapshot.dart';
import 'models/catalog_stats.dart';
import 'models/product_model.dart';
import 'models/store_settings.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(
    api: ref.watch(amanRestApiProvider),
    authStorage: ref.watch(authStorageProvider),
    offlineStorage: ref.watch(catalogOfflineStorageProvider),
  );
});

class _ProductsPageResult {
  const _ProductsPageResult({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.totalProducts,
  });

  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final int totalProducts;
}

class _LookupMaps {
  const _LookupMaps({
    required this.categoryNames,
    required this.brandNames,
    required this.categoryIdByName,
    required this.brandIdByName,
  });

  final Map<int, String> categoryNames;
  final Map<int, String> brandNames;
  final Map<String, int> categoryIdByName;
  final Map<String, int> brandIdByName;
}

/// مستودع المنتجات عبر أمان ERP REST
class ProductsRepository {
  ProductsRepository({
    required AmanRestApi api,
    required AuthStorage authStorage,
    required CatalogOfflineStorage offlineStorage,
  })  : _api = api,
        _authStorage = authStorage,
        _offlineStorage = offlineStorage;

  final AmanRestApi _api;
  final AuthStorage _authStorage;
  final CatalogOfflineStorage _offlineStorage;

  CatalogSnapshot? _memoryCache;
  DateTime? _cachedAt;
  _LookupMaps? _lookups;

  static const _cacheTtl = Duration(minutes: 10);

  bool get _hasToken {
    final token = _authStorage.accessToken;
    return (token != null && token.isNotEmpty) || ApiConfig.apiToken.isNotEmpty;
  }

  CatalogSnapshot _mockSnapshot({String? warning}) => CatalogSnapshot(
        products: HomeMockData.products,
        categories: HomeMockData.categories,
        brands: const [],
        stats: const CatalogStats(),
        storeSettings: const StoreSettings(),
        source: CatalogDataSource.mock,
        warningMessage: warning,
      );

  bool _isMemoryCacheValid() {
    if (_memoryCache == null || _cachedAt == null) return false;
    return DateTime.now().difference(_cachedAt!) < _cacheTtl;
  }

  Future<void> clearCache() async {
    _memoryCache = null;
    _cachedAt = null;
    _lookups = null;
    await _offlineStorage.clear();
  }

  Future<CatalogSnapshot> fetchCatalog({bool forceRefresh = false}) async {
    if (!forceRefresh && _isMemoryCacheValid()) {
      return _memoryCache!.copyWith(source: CatalogDataSource.cache);
    }

    if (!_hasToken) {
      return _offlineStorage.load() ?? _mockSnapshot();
    }

    try {
      final lookups = await _fetchLookups();
      _lookups = lookups;

      final pageResult = await _fetchProductsPage(1, lookups);
      final metadata = ErpCatalogMetadata.fromLookups(
        categoryNames: lookups.categoryNames.values.toList(),
        brandNames: lookups.brandNames.values.toList(),
        totalProducts: pageResult.totalProducts,
        productsWithImages:
            pageResult.products.where((p) => p.imageUrl != null).length,
        productsWithoutBrand:
            pageResult.products.where((p) => p.brandName.isEmpty).length,
      );

      final snapshot = _buildSnapshot(
        products: pageResult.products,
        categories: metadata.categories,
        brands: metadata.brands,
        stats: metadata.stats,
        source: CatalogDataSource.api,
        currentPage: pageResult.currentPage,
        lastPage: pageResult.lastPage,
        warning: pageResult.products.isEmpty
            ? 'لا توجد منتجات — عرض بيانات تجريبية'
            : null,
      );

      await _persistSnapshot(snapshot);
      return snapshot;
    } on ApiException catch (error) {
      return _fallbackSnapshot(error.message);
    }
  }

  Future<CatalogSnapshot> loadMoreProducts(CatalogSnapshot current) async {
    if (!_hasToken || !current.hasMore || current.isLoadingMore) {
      return current;
    }

    try {
      final lookups = _lookups ?? await _fetchLookups();
      _lookups = lookups;

      final nextPage = current.currentPage + 1;
      final pageResult = await _fetchProductsPage(nextPage, lookups);
      final merged = _mergeProducts(current.products, pageResult.products);

      final snapshot = current.copyWith(
        products: merged,
        currentPage: pageResult.currentPage,
        lastPage: pageResult.lastPage,
        isLoadingMore: false,
        source: CatalogDataSource.api,
        clearWarning: true,
      );

      await _persistSnapshot(snapshot);
      return snapshot;
    } on ApiException catch (error) {
      return current.copyWith(
        isLoadingMore: false,
        warningMessage: error.message,
      );
    }
  }

  CatalogSnapshot _buildSnapshot({
    required List<ProductModel> products,
    required List<String> categories,
    required List<String> brands,
    CatalogStats stats = const CatalogStats(),
    StoreSettings storeSettings = const StoreSettings(),
    required CatalogDataSource source,
    required int currentPage,
    required int lastPage,
    String? warning,
  }) {
    final useMockProducts = products.isEmpty;
    final hasRealCategories = categories.any((c) => c != 'الكل');

    return CatalogSnapshot(
      products: useMockProducts ? HomeMockData.products : products,
      categories: hasRealCategories
          ? categories
          : (useMockProducts ? HomeMockData.categories : const ['الكل']),
      brands: brands,
      stats: stats,
      storeSettings: storeSettings,
      source: source,
      warningMessage: warning,
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }

  Future<void> _persistSnapshot(CatalogSnapshot snapshot) async {
    _memoryCache = snapshot;
    _cachedAt = DateTime.now();
    if (snapshot.source == CatalogDataSource.api) {
      await _offlineStorage.save(snapshot);
    }
  }

  CatalogSnapshot _fallbackSnapshot(String message) {
    if (_memoryCache != null) {
      return _memoryCache!.copyWith(
        source: CatalogDataSource.cache,
        warningMessage: message,
      );
    }

    final offline = _offlineStorage.load();
    if (offline != null) {
      return offline.copyWith(warningMessage: message);
    }

    return _mockSnapshot(warning: message);
  }

  List<ProductModel> _mergeProducts(
    List<ProductModel> existing,
    List<ProductModel> incoming,
  ) {
    final ids = existing.map((p) => p.id).toSet();
    final merged = [...existing];
    for (final product in incoming) {
      if (!ids.contains(product.id)) {
        merged.add(product);
        ids.add(product.id);
      }
    }
    return merged;
  }

  Future<_LookupMaps> _fetchLookups() async {
    final results = await Future.wait([
      _api.list(path: ApiEndpoints.categories, page: 1, perPage: 200),
      _api.list(path: ApiEndpoints.brands, page: 1, perPage: 200),
    ]);

    final categories = results[0];
    final brands = results[1];

    final categoryNames = <int, String>{};
    final categoryIdByName = <String, int>{};
    for (final row in categories.items) {
      final id = _asInt(row['id']);
      final name = row['name']?.toString().trim() ?? '';
      if (id == null || name.isEmpty) continue;
      if (row['is_active'] == false) continue;
      categoryNames[id] = name;
      categoryIdByName[name] = id;
    }

    final brandNames = <int, String>{};
    final brandIdByName = <String, int>{};
    for (final row in brands.items) {
      final id = _asInt(row['id']);
      final name = row['name']?.toString().trim() ?? '';
      if (id == null || name.isEmpty) continue;
      if (row['is_active'] == false) continue;
      brandNames[id] = name;
      brandIdByName[name] = id;
    }

    return _LookupMaps(
      categoryNames: categoryNames,
      brandNames: brandNames,
      categoryIdByName: categoryIdByName,
      brandIdByName: brandIdByName,
    );
  }

  Future<_ProductsPageResult> _fetchProductsPage(
    int page,
    _LookupMaps lookups,
  ) async {
    final result = await _api.list(
      path: ApiEndpoints.products,
      page: page,
      perPage: ApiConfig.productsPerPage,
      query: const {'is_active': true},
    );

    return _ProductsPageResult(
      products: ErpProductMapper.fromRecords(
        result.items,
        categoryNames: lookups.categoryNames,
        brandNames: lookups.brandNames,
      ),
      currentPage: result.currentPage,
      lastPage: result.lastPage,
      totalProducts: result.total,
    );
  }

  /// بحث عبر أمان ERP — يدعم `q` + تصنيف/ماركة
  Future<List<ProductModel>> searchProducts({
    required String query,
    String category = 'الكل',
    String brand = 'الكل',
    double minPrice = 0,
    double maxPrice = 500000,
  }) async {
    if (!_hasToken) {
      final q = query.trim().toLowerCase();
      return HomeMockData.products.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.categoryName.toLowerCase().contains(q) ||
            p.brandName.toLowerCase().contains(q);
      }).toList();
    }

    final lookups = _lookups ?? await _fetchLookups();
    _lookups = lookups;

    final params = <String, dynamic>{
      'is_active': true,
    };

    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      params['q'] = trimmed;
    }

    if (category != 'الكل') {
      final categoryId = lookups.categoryIdByName[category];
      if (categoryId != null) params['category_id'] = categoryId;
    }

    if (brand != 'الكل') {
      final brandId = lookups.brandIdByName[brand];
      if (brandId != null) params['brand_id'] = brandId;
    }

    final result = await _api.list(
      path: ApiEndpoints.products,
      page: 1,
      perPage: 100,
      query: params,
    );

    final products = ErpProductMapper.fromRecords(
      result.items,
      categoryNames: lookups.categoryNames,
      brandNames: lookups.brandNames,
    );

    return products.where((product) {
      return product.price >= minPrice.round() &&
          product.price <= maxPrice.round();
    }).toList();
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
