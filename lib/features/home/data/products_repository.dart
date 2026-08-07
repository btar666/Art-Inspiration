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
import 'models/product_page_result.dart';
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
        activeCategory: 'الكل',
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
      final pageResult = await _fetchProductsPage(
        nextPage,
        lookups,
        category: current.activeCategory,
      );
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

  /// جلب الصفحة الأولى لفئة محددة (تصفح من الخادم)
  Future<CatalogSnapshot> fetchProductsForCategory(
    String category,
    CatalogSnapshot current,
  ) async {
    if (category == current.activeCategory && current.products.isNotEmpty) {
      return current;
    }

    if (!_hasToken) {
      final products = category == 'الكل'
          ? HomeMockData.products
          : HomeMockData.products
              .where((p) => p.matchesCategoryOrBrand(category))
              .toList();
      return current.copyWith(
        products: products,
        activeCategory: category,
        currentPage: 1,
        lastPage: 1,
        stats: CatalogStats(totalProducts: products.length),
      );
    }

    try {
      final lookups = _lookups ?? await _fetchLookups();
      _lookups = lookups;

      final pageResult = await _fetchProductsPage(
        1,
        lookups,
        category: category,
      );

      final snapshot = current.copyWith(
        products: pageResult.products,
        activeCategory: category,
        currentPage: pageResult.currentPage,
        lastPage: pageResult.lastPage,
        isLoadingMore: false,
        source: CatalogDataSource.api,
        stats: CatalogStats(
          totalProducts: pageResult.totalProducts,
          brandCount: current.stats.brandCount,
          categoryCount: current.stats.categoryCount,
          productsWithImages: pageResult.products
              .where((p) => p.imageUrl != null)
              .length,
          productsWithoutBrand:
              pageResult.products.where((p) => p.brandName.isEmpty).length,
        ),
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
    String activeCategory = 'الكل',
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
      activeCategory: activeCategory,
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
    _LookupMaps lookups, {
    String category = 'الكل',
    String brand = 'الكل',
  }) async {
    final query = <String, dynamic>{'is_active': true};

    if (category != 'الكل') {
      final categoryId = lookups.categoryIdByName[category];
      if (categoryId != null) query['category_id'] = categoryId;
    }

    if (brand != 'الكل') {
      final brandId = lookups.brandIdByName[brand];
      if (brandId != null) query['brand_id'] = brandId;
    }

    final result = await _api.list(
      path: ApiEndpoints.products,
      page: page,
      perPage: ApiConfig.productsPerPage,
      query: query,
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

  ProductPageResult _toPageResult(_ProductsPageResult result) => ProductPageResult(
        products: result.products,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.totalProducts,
      );

  /// منتجات قسم أو براند — يحدد تلقائياً category_id أو brand_id
  Future<ProductPageResult> fetchSectionProductsPage(
    int page,
    String sectionName,
  ) async {
    if (!_hasToken) {
      final products = HomeMockData.products
          .where((p) => p.matchesCategoryOrBrand(sectionName))
          .toList();
      return ProductPageResult(
        products: products,
        currentPage: 1,
        lastPage: 1,
        total: products.length,
      );
    }

    final lookups = _lookups ?? await _fetchLookups();
    _lookups = lookups;

    if (lookups.categoryIdByName.containsKey(sectionName)) {
      return _toPageResult(
        await _fetchProductsPage(page, lookups, category: sectionName),
      );
    }

    if (lookups.brandIdByName.containsKey(sectionName)) {
      return _toPageResult(
        await _fetchProductsPage(page, lookups, brand: sectionName),
      );
    }

    return _toPageResult(
      await _fetchProductsPage(page, lookups),
    );
  }

  /// بحث مقسّم عبر أمان ERP — `q` + `category_id` + `brand_id` + `sku` + `barcode` + `is_active`
  Future<ProductPageResult> searchProductsPage({
    required int page,
    String query = '',
    String category = 'الكل',
    String brand = 'الكل',
    String sku = '',
    String barcode = '',
    bool onlyActive = true,
  }) async {
    if (!_hasToken) {
      return _mockSearchPage(
        query: query,
        category: category,
        brand: brand,
        sku: sku,
        barcode: barcode,
        onlyActive: onlyActive,
      );
    }

    final lookups = _lookups ?? await _fetchLookups();
    _lookups = lookups;

    final params = <String, dynamic>{};
    if (onlyActive) params['is_active'] = true;

    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      params['q'] = trimmedQuery;
    }

    final trimmedSku = sku.trim();
    if (trimmedSku.isNotEmpty) {
      params['sku'] = trimmedSku;
    }

    final trimmedBarcode = barcode.trim();
    if (trimmedBarcode.isNotEmpty) {
      params['barcode'] = trimmedBarcode;
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
      page: page,
      perPage: ApiConfig.productsPerPage,
      query: params,
    );

    final products = ErpProductMapper.fromRecords(
      result.items,
      categoryNames: lookups.categoryNames,
      brandNames: lookups.brandNames,
    );

    return ProductPageResult(
      products: products,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
      total: result.total,
    );
  }

  ProductPageResult _mockSearchPage({
    required String query,
    required String category,
    required String brand,
    required String sku,
    required String barcode,
    required bool onlyActive,
  }) {
    final q = query.trim().toLowerCase();
    final skuFilter = sku.trim().toLowerCase();
    final barcodeFilter = barcode.trim().toLowerCase();

    final products = HomeMockData.products.where((p) {
      if (onlyActive && !p.isActive) return false;
      if (category != 'الكل' && !p.matchesCategoryOrBrand(category)) {
        return false;
      }
      if (brand != 'الكل' && !p.matchesCategoryOrBrand(brand)) return false;
      if (skuFilter.isNotEmpty &&
          !(p.sku?.toLowerCase() == skuFilter)) {
        return false;
      }
      if (barcodeFilter.isNotEmpty &&
          !(p.barcode?.toLowerCase() == barcodeFilter)) {
        return false;
      }
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          (p.sku?.toLowerCase().contains(q) ?? false) ||
          (p.barcode?.toLowerCase().contains(q) ?? false) ||
          p.categoryName.toLowerCase().contains(q) ||
          p.brandName.toLowerCase().contains(q);
    }).toList();

    return ProductPageResult(
      products: products,
      currentPage: 1,
      lastPage: 1,
      total: products.length,
    );
  }

  /// بحث عبر أمان ERP — الصفحة الأولى فقط
  Future<List<ProductModel>> searchProducts({
    String query = '',
    String category = 'الكل',
    String brand = 'الكل',
    String sku = '',
    String barcode = '',
    bool onlyActive = true,
  }) async {
    final result = await searchProductsPage(
      page: 1,
      query: query,
      category: category,
      brand: brand,
      sku: sku,
      barcode: barcode,
      onlyActive: onlyActive,
    );
    return result.products;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
