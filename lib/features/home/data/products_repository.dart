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
import 'models/taxonomy_cache_entry.dart';
import 'taxonomy_cache_storage.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(
    api: ref.watch(amanRestApiProvider),
    authStorage: ref.watch(authStorageProvider),
    offlineStorage: ref.watch(catalogOfflineStorageProvider),
    taxonomyStorage: ref.watch(taxonomyCacheStorageProvider),
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
    this.categoryImages = const {},
    this.brandImages = const {},
  });

  final Map<int, String> categoryNames;
  final Map<int, String> brandNames;
  final Map<String, int> categoryIdByName;
  final Map<String, int> brandIdByName;
  final Map<String, String>? categoryImages;
  final Map<String, String>? brandImages;
}

class _CategoryProductsCache {
  const _CategoryProductsCache({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.cachedAt,
  });

  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final DateTime cachedAt;
}

/// مستودع المنتجات عبر أمان ERP REST
class ProductsRepository {
  ProductsRepository({
    required AmanRestApi api,
    required AuthStorage authStorage,
    required CatalogOfflineStorage offlineStorage,
    required TaxonomyCacheStorage taxonomyStorage,
  })  : _api = api,
        _authStorage = authStorage,
        _offlineStorage = offlineStorage,
        _taxonomyStorage = taxonomyStorage;

  final AmanRestApi _api;
  final AuthStorage _authStorage;
  final CatalogOfflineStorage _offlineStorage;
  final TaxonomyCacheStorage _taxonomyStorage;

  CatalogSnapshot? _memoryCache;
  DateTime? _cachedAt;
  _LookupMaps? _lookups;
  Future<CatalogSnapshot?>? _taxonomySyncFuture;
  final Map<String, _CategoryProductsCache> _categoryProductsCache = {};

  static const _cacheTtl = Duration(minutes: 10);

  bool get _hasToken {
    final token = _authStorage.accessToken;
    return (token != null && token.isNotEmpty) || ApiConfig.apiToken.isNotEmpty;
  }

  CatalogSnapshot _mockSnapshot({String? warning}) {
    final metadata = ErpCatalogMetadata.fromProducts(HomeMockData.products);

    return CatalogSnapshot(
      products: HomeMockData.products,
      categories: metadata.categories,
      brands: metadata.brands,
      stats: metadata.stats,
      storeSettings: const StoreSettings(),
      source: CatalogDataSource.mock,
      warningMessage: warning,
    );
  }

  bool _isMemoryCacheValid() {
    if (_memoryCache == null || _cachedAt == null) return false;
    return DateTime.now().difference(_cachedAt!) < _cacheTtl;
  }

  Future<void> clearCache() async {
    _memoryCache = null;
    _cachedAt = null;
    _lookups = null;
    _taxonomySyncFuture = null;
    _categoryProductsCache.clear();
    await _offlineStorage.clear();
    await _taxonomyStorage.clear();
  }

  /// إبطال كاش المنتجات في الذاكرة — يحتفظ بـ lookups و taxonomy
  void invalidateProductsMemoryCache() {
    _memoryCache = null;
    _cachedAt = null;
  }

  /// إبطال كاش الذاكرة بالكامل — يُستخدم عند تغيير الحساب
  void invalidateMemoryCache() {
    invalidateProductsMemoryCache();
    _lookups = null;
    _taxonomySyncFuture = null;
    _categoryProductsCache.clear();
  }

  _CategoryProductsCache? _getValidCategoryCache(String key) {
    final entry = _categoryProductsCache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.cachedAt) >= _cacheTtl) {
      _categoryProductsCache.remove(key);
      return null;
    }
    return entry;
  }

  void _saveCategoryProductsCache(
    String key,
    List<ProductModel> products, {
    required int currentPage,
    required int lastPage,
  }) {
    _categoryProductsCache[key] = _CategoryProductsCache(
      products: products,
      currentPage: currentPage,
      lastPage: lastPage,
      cachedAt: DateTime.now(),
    );
  }

  void _hydrateCategoryCacheFromOffline(String key) {
    final offline = _offlineStorage.loadForCategory(key);
    if (offline == null) return;
    _saveCategoryProductsCache(
      key,
      offline.products,
      currentPage: offline.currentPage,
      lastPage: offline.lastPage,
    );
  }

  /// عرض فوري لـ «الكل» عند فتح التطبيق
  CatalogSnapshot? peekDefaultCatalog() {
    final allCache = _getValidCategoryCache('الكل');
    final taxonomySource =
        _isMemoryCacheValid() ? _memoryCache : _offlineStorage.loadDefault();

    if (allCache != null && taxonomySource != null) {
      return taxonomySource.copyWith(
        products: allCache.products,
        activeCategory: 'الكل',
        currentPage: allCache.currentPage,
        lastPage: allCache.lastPage,
        source: CatalogDataSource.cache,
        clearWarning: true,
      );
    }

    if (_isMemoryCacheValid() && _memoryCache!.activeCategory == 'الكل') {
      return _memoryCache!.copyWith(source: CatalogDataSource.cache);
    }

    final offline = _offlineStorage.loadDefault();
    if (offline != null) {
      _memoryCache = offline;
      _cachedAt = DateTime.now();
      _saveCategoryProductsCache(
        'الكل',
        offline.products,
        currentPage: offline.currentPage,
        lastPage: offline.lastPage,
      );
      return offline;
    }

    return null;
  }

  /// عرض فوري لقسم/براند عند العودة إليه
  CatalogSnapshot? peekCategoryCatalog(
    String category,
    CatalogSnapshot current,
  ) {
    if (category == current.activeCategory && current.products.isNotEmpty) {
      return current;
    }

    final cached = _getValidCategoryCache(category);
    if (cached != null) {
      return current.copyWith(
        products: cached.products,
        activeCategory: category,
        currentPage: cached.currentPage,
        lastPage: cached.lastPage,
        isLoadingMore: false,
        source: CatalogDataSource.cache,
        clearWarning: true,
      );
    }

    _hydrateCategoryCacheFromOffline(category);
    final fromOffline = _getValidCategoryCache(category);
    if (fromOffline != null) {
      return current.copyWith(
        products: fromOffline.products,
        activeCategory: category,
        currentPage: fromOffline.currentPage,
        lastPage: fromOffline.lastPage,
        isLoadingMore: false,
        source: CatalogDataSource.offline,
      );
    }

    return null;
  }

  /// عرض فوري لصفحة قسم الاكسبلور
  ProductPageResult? peekSectionProductsPage(String sectionName) {
    final cached = _getValidCategoryCache(sectionName);
    if (cached != null) {
      return ProductPageResult(
        products: cached.products,
        currentPage: cached.currentPage,
        lastPage: cached.lastPage,
        total: cached.products.length,
      );
    }

    _hydrateCategoryCacheFromOffline(sectionName);
    final fromOffline = _getValidCategoryCache(sectionName);
    if (fromOffline != null) {
      return ProductPageResult(
        products: fromOffline.products,
        currentPage: fromOffline.currentPage,
        lastPage: fromOffline.lastPage,
        total: fromOffline.products.length,
      );
    }

    return null;
  }

  /// تحديث بالخلفية — بدون blocking للواجهة
  Future<CatalogSnapshot?> syncCatalogInBackground(CatalogSnapshot current) async {
    if (!_hasToken) return null;

    try {
      return await refreshCatalog(current);
    } on ApiException {
      return null;
    }
  }

  CatalogMetadata _metadataFromTaxonomy(
    TaxonomyCacheEntry? taxonomy,
    _ProductsPageResult pageResult,
  ) {
    if (taxonomy != null && taxonomy.isValid) {
      return ErpCatalogMetadata.fromLookups(
        categoryNames: taxonomy.categoryNames,
        brandNames: taxonomy.brandNames,
        totalProducts: taxonomy.inStockCount,
        productsWithImages:
            pageResult.products.where((p) => p.imageUrl != null).length,
        productsWithoutBrand:
            pageResult.products.where((p) => p.brandName.isEmpty).length,
      );
    }

    return ErpCatalogMetadata.fromProducts(
      pageResult.products,
      totalProducts: pageResult.products.length,
    );
  }

  Future<CatalogSnapshot> fetchCatalog({bool forceRefresh = false}) async {
    if (forceRefresh) {
      invalidateProductsMemoryCache();
    }

    if (!forceRefresh && _isMemoryCacheValid()) {
      return _memoryCache!.copyWith(source: CatalogDataSource.cache);
    }

    if (!_hasToken) {
      return _offlineStorage.loadDefault() ?? _mockSnapshot();
    }

    try {
      final lookups = await _fetchLookups();
      _lookups = lookups;

      final pageResult = await _fetchProductsPage(1, lookups);
      final taxonomy = _taxonomyStorage.load();
      final metadata = _metadataFromTaxonomy(taxonomy, pageResult);

      final snapshot = _buildSnapshot(
        products: pageResult.products,
        categories: metadata.categories,
        brands: metadata.brands,
        stats: metadata.stats,
        source: CatalogDataSource.api,
        currentPage: pageResult.currentPage,
        lastPage: pageResult.lastPage,
        activeCategory: 'الكل',
        categoryImages: lookups.categoryImages ?? const {},
        brandImages: lookups.brandImages ?? const {},
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

  /// تحديث السياق الحالي — يعيد جلب الصفحات المحمّلة ويحدّث المنتجات من API
  Future<CatalogSnapshot> refreshCatalog(CatalogSnapshot current) async {
    if (!_hasToken) {
      return _offlineStorage.loadForCategory(current.activeCategory) ??
          _offlineStorage.loadDefault() ??
          _mockSnapshot();
    }

    try {
      final lookups = await _fetchLookups();
      _lookups = lookups;

      final pagesToRefresh = current.currentPage.clamp(1, current.lastPage);
      final pageResult = await _fetchProductsPagesUpTo(
        pagesToRefresh,
        lookups,
        category: current.activeCategory,
      );

      final taxonomy = _taxonomyStorage.load();
      final metadata = _metadataFromTaxonomy(taxonomy, pageResult);

      final snapshot = current.copyWith(
        products: pageResult.products,
        categories: metadata.categories,
        brands: metadata.brands,
        stats: metadata.stats,
        source: CatalogDataSource.api,
        currentPage: pageResult.currentPage,
        lastPage: pageResult.lastPage,
        categoryImages: lookups.categoryImages ?? const {},
        brandImages: lookups.brandImages ?? const {},
        clearWarning: true,
      );

      await _persistSnapshot(snapshot);
      return snapshot;
    } on ApiException catch (error) {
      return _fallbackSnapshot(error.message);
    }
  }

  /// تحديث منتجات قسم/براند — يعيد جلب الصفحات المحمّلة ويحدّث من API
  Future<ProductPageResult> refreshSectionProducts(
    String sectionName, {
    required int loadedPageCount,
    required int lastPage,
  }) async {
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

    try {
      final lookups = await _fetchLookups();
      _lookups = lookups;

      var category = 'الكل';
      var brand = 'الكل';
      if (lookups.categoryIdByName.containsKey(sectionName)) {
        category = sectionName;
      } else if (lookups.brandIdByName.containsKey(sectionName)) {
        brand = sectionName;
      }

      final pagesToRefresh = loadedPageCount.clamp(1, lastPage);
      final pageResult = await _fetchProductsPagesUpTo(
        pagesToRefresh,
        lookups,
        category: category,
        brand: brand,
      );

      return _toPageResult(pageResult);
    } on ApiException {
      rethrow;
    }
  }

  /// يمسح المنتجات غير النافذة ويحدّث أقسام/براندات — بالخلفية إن الكاش منتهي
  Future<CatalogSnapshot?> syncTaxonomyIfStale({bool force = false}) {
    final inFlight = _taxonomySyncFuture;
    if (inFlight != null) return inFlight;

    final cached = _taxonomyStorage.load();
    if (!force && cached != null && cached.isValid) {
      return Future.value(null);
    }

    final future = _runTaxonomySync();
    _taxonomySyncFuture = future;
    return future.whenComplete(() => _taxonomySyncFuture = null);
  }

  Future<CatalogSnapshot?> _runTaxonomySync() async {
    if (!_hasToken) return null;

    try {
      final lookups = _lookups ?? await _fetchLookups();
      _lookups = lookups;

      final entry = TaxonomyCacheEntry(
        categoryNames: lookups.categoryNames.values.toList(),
        brandNames: lookups.brandNames.values.toList(),
        inStockCount: _memoryCache?.stats.totalProducts ?? 0,
        savedAt: DateTime.now(),
      );
      await _taxonomyStorage.save(entry);

      final current = _memoryCache;
      if (current == null) return null;

      final metadata = ErpCatalogMetadata.fromLookups(
        categoryNames: entry.categoryNames,
        brandNames: entry.brandNames,
        totalProducts: entry.inStockCount,
        productsWithImages: current.stats.productsWithImages,
        productsWithoutBrand: current.stats.productsWithoutBrand,
      );

      final updated = current.copyWith(
        categories: metadata.categories,
        brands: metadata.brands,
        stats: metadata.stats,
        source: CatalogDataSource.api,
        clearWarning: true,
      );

      await _persistSnapshot(updated);
      return updated;
    } on ApiException catch (error) {
      if (_memoryCache != null) {
        final warned = _memoryCache!.copyWith(
          warningMessage: error.message,
          source: CatalogDataSource.cache,
        );
        _memoryCache = warned;
        return warned;
      }
      return null;
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

    final cached = _getValidCategoryCache(category);
    if (cached != null) {
      return current.copyWith(
        products: cached.products,
        activeCategory: category,
        currentPage: cached.currentPage,
        lastPage: cached.lastPage,
        isLoadingMore: false,
        source: CatalogDataSource.cache,
        clearWarning: true,
      );
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
    Map<String, String> categoryImages = const {},
    Map<String, String> brandImages = const {},
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
      categoryImages: categoryImages,
      brandImages: brandImages,
    );
  }

  Future<void> _persistSnapshot(CatalogSnapshot snapshot) async {
    _memoryCache = snapshot;
    _cachedAt = DateTime.now();
    _saveCategoryProductsCache(
      snapshot.activeCategory,
      snapshot.products,
      currentPage: snapshot.currentPage,
      lastPage: snapshot.lastPage,
    );
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

    final offline = _offlineStorage.loadDefault();
    if (offline != null) {
      return offline.copyWith(warningMessage: message);
    }

    return _mockSnapshot(warning: message);
  }

  List<ProductModel> _mergeProducts(
    List<ProductModel> existing,
    List<ProductModel> incoming,
  ) {
    final byId = {for (final p in existing) p.id: p};
    for (final product in incoming) {
      byId[product.id] = product;
    }

    final merged = <ProductModel>[];
    final seen = <String>{};

    for (final product in existing) {
      final updated = byId[product.id];
      if (updated == null) continue;
      merged.add(updated);
      seen.add(updated.id);
    }

    for (final product in incoming) {
      if (!seen.contains(product.id)) {
        merged.add(product);
        seen.add(product.id);
      }
    }

    return merged;
  }

  /// يجلب صفحات 1..upToPage ويعيد قائمة محدّثة من API (مصدر الحقيقة)
  Future<_ProductsPageResult> _fetchProductsPagesUpTo(
    int upToPage,
    _LookupMaps lookups, {
    String category = 'الكل',
    String brand = 'الكل',
  }) async {
    final allProducts = <ProductModel>[];
    var lastPage = 1;
    var totalProducts = 0;

    final targetPage = upToPage.clamp(1, 9999);

    for (var page = 1; page <= targetPage; page++) {
      final result = await _fetchProductsPage(
        page,
        lookups,
        category: category,
        brand: brand,
      );
      lastPage = result.lastPage;
      totalProducts = result.totalProducts;

      for (final product in result.products) {
        allProducts.add(product);
      }

      if (page >= lastPage) break;
    }

    final effectivePage = targetPage.clamp(1, lastPage);

    return _ProductsPageResult(
      products: allProducts,
      currentPage: effectivePage,
      lastPage: lastPage,
      totalProducts: totalProducts,
    );
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
    final categoryImages = <String, String>{};
    for (final row in categories.items) {
      final id = _asInt(row['id']);
      final name = row['name']?.toString().trim() ?? '';
      if (id == null || name.isEmpty) continue;
      categoryNames[id] = name;
      categoryIdByName[name] = id;
      final image = _normalizeCategoryImage(row['image']);
      if (image != null) {
        categoryImages[name] = image;
      }
    }

    final brandNames = <int, String>{};
    final brandIdByName = <String, int>{};
    final brandImages = <String, String>{};
    for (final row in brands.items) {
      final id = _asInt(row['id']);
      final name = row['name']?.toString().trim() ?? '';
      if (id == null || name.isEmpty) continue;
      brandNames[id] = name;
      brandIdByName[name] = id;
      final image = _normalizeBrandImage(
        row['image'] ?? row['logo'] ?? row['photo'],
      );
      if (image != null) {
        brandImages[name] = image;
      }
    }

    return _LookupMaps(
      categoryNames: categoryNames,
      brandNames: brandNames,
      categoryIdByName: categoryIdByName,
      brandIdByName: brandIdByName,
      categoryImages: categoryImages,
      brandImages: brandImages,
    );
  }

  String? _normalizeCategoryImage(dynamic raw) {
    var text = raw?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') return null;
    if (text.startsWith('http://')) {
      text = 'https://${text.substring(7)}';
    }
    if (text.startsWith('https://')) return text;
    if (text.startsWith('/')) {
      return 'https://aman-erp.com$text';
    }
    return 'https://aman-erp.com/storage/categories/$text';
  }

  String? _normalizeBrandImage(dynamic raw) {
    var text = raw?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') return null;
    if (text.startsWith('http://')) {
      text = 'https://${text.substring(7)}';
    }
    if (text.startsWith('https://')) return text;
    if (text.startsWith('/')) {
      return 'https://aman-erp.com$text';
    }
    return 'https://aman-erp.com/storage/brands/$text';
  }

  Future<_ProductsPageResult> _fetchProductsPage(
    int page,
    _LookupMaps lookups, {
    String category = 'الكل',
    String brand = 'الكل',
  }) async {
    final query = <String, dynamic>{};

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
      final pageResult = _toPageResult(
        await _fetchProductsPage(page, lookups, category: sectionName),
      );
      _cacheSectionPageIfNeeded(sectionName, page, pageResult);
      return pageResult;
    }

    if (lookups.brandIdByName.containsKey(sectionName)) {
      final pageResult = _toPageResult(
        await _fetchProductsPage(page, lookups, brand: sectionName),
      );
      _cacheSectionPageIfNeeded(sectionName, page, pageResult);
      return pageResult;
    }

    final pageResult = _toPageResult(
      await _fetchProductsPage(page, lookups),
    );
    _cacheSectionPageIfNeeded(sectionName, page, pageResult);
    return pageResult;
  }

  void _cacheSectionPageIfNeeded(
    String sectionName,
    int page,
    ProductPageResult result,
  ) {
    if (page != 1) return;
    _saveCategoryProductsCache(
      sectionName,
      result.products,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
    );
  }

  void cacheSectionProducts(
    String sectionName,
    List<ProductModel> products, {
    required int currentPage,
    required int lastPage,
  }) {
    _saveCategoryProductsCache(
      sectionName,
      products,
      currentPage: currentPage,
      lastPage: lastPage,
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
    bool onlyActive = false,
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
    bool onlyActive = false,
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

  /// البحث عن منتج واحد بالباركود عبر API
  Future<ProductModel?> findProductByBarcode(String barcode) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return null;

    final result = await searchProductsPage(
      page: 1,
      barcode: trimmed,
    );
    if (result.products.isEmpty) return null;
    return result.products.first;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
