import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/advanced_filter_api.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/models/advanced_filter_models.dart';
import '../../auth/data/auth_storage.dart';
import 'catalog_offline_storage.dart';
import 'erp_catalog_metadata.dart';
import 'erp_product_mapper.dart';
import 'erp_settings_mapper.dart';
import 'models/catalog_stats.dart';
import 'models/store_settings.dart';
import 'home_mock_data.dart';
import 'models/catalog_snapshot.dart';
import 'models/product_model.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(
    api: ref.watch(advancedFilterApiProvider),
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

/// مستودع المنتجات — كاش ذاكرة + offline + pagination
class ProductsRepository {
  ProductsRepository({
    required AdvancedFilterApi api,
    required AuthStorage authStorage,
    required CatalogOfflineStorage offlineStorage,
  })  : _api = api,
        _authStorage = authStorage,
        _offlineStorage = offlineStorage;

  final AdvancedFilterApi _api;
  final AuthStorage _authStorage;
  final CatalogOfflineStorage _offlineStorage;

  CatalogSnapshot? _memoryCache;
  DateTime? _cachedAt;

  static const _cacheTtl = Duration(minutes: 10);

  bool get _isLoggedIn => _authStorage.isLoggedIn;

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
    await _offlineStorage.clear();
  }

  Future<CatalogSnapshot> fetchCatalog({bool forceRefresh = false}) async {
    if (!forceRefresh && _isMemoryCacheValid()) {
      return _memoryCache!.copyWith(source: CatalogDataSource.cache);
    }

    if (!_isLoggedIn) {
      return _offlineStorage.load() ?? _mockSnapshot();
    }

    try {
      final results = await Future.wait([
        _fetchProductsPage(1),
        _fetchCatalogMetadata(),
        _fetchStoreSettings(),
      ]);

      final pageResult = results[0] as _ProductsPageResult;
      final metadata = results[1] as CatalogMetadata;
      final storeSettings = results[2] as StoreSettings;

      final snapshot = _buildSnapshot(
        products: pageResult.products,
        categories: metadata.categories,
        brands: metadata.brands,
        stats: CatalogStats(
          totalProducts: pageResult.totalProducts,
          brandCount: metadata.stats.brandCount,
          categoryCount: metadata.stats.categoryCount,
          productsWithImages: metadata.stats.productsWithImages,
          productsWithoutBrand: metadata.stats.productsWithoutBrand,
        ),
        storeSettings: storeSettings,
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
    if (!_isLoggedIn || !current.hasMore || current.isLoadingMore) {
      return current;
    }

    try {
      final nextPage = current.currentPage + 1;
      final pageResult = await _fetchProductsPage(nextPage);
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
    final useMockCategories =
        categories.length <= 1 && categories.every((c) => c == 'الكل');

    return CatalogSnapshot(
      products: useMockProducts ? HomeMockData.products : products,
      categories: useMockCategories ? HomeMockData.categories : categories,
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

  Future<_ProductsPageResult> _fetchProductsPage(int page) async {
    final result = await _api.fetch(
      request: AdvancedFilterRequest(
        tableName: ErpTables.products,
        filters: const [],
        sorts: const [
          AdvancedFilterSort(field: 'id', direction: 'desc'),
        ],
        perPage: ApiConfig.productsPerPage,
        page: page,
      ),
    );

    return _ProductsPageResult(
      products: ErpProductMapper.fromRecords(result.items),
      currentPage: result.currentPage,
      lastPage: result.lastPage,
      totalProducts: result.total,
    );
  }

  Future<CatalogMetadata> _fetchCatalogMetadata() async {
    final result = await _api.fetch(
      request: const AdvancedFilterRequest(
        tableName: ErpTables.products,
        filters: [],
        sorts: [
          AdvancedFilterSort(field: 'id', direction: 'desc'),
        ],
        perPage: 1500,
        page: 1,
      ),
    );

    return ErpCatalogMetadata.fromProductRecords(
      result.items,
      totalProducts: result.total,
    );
  }

  Future<StoreSettings> _fetchStoreSettings() async {
    try {
      final result = await _api.fetch(
        request: const AdvancedFilterRequest(
          tableName: ErpTables.settings,
          filters: [],
          sorts: [],
          perPage: 1,
          page: 1,
        ),
      );
      return ErpSettingsMapper.fromRecords(result.items);
    } on ApiException {
      return const StoreSettings();
    }
  }
}
