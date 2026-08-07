import '../models/product_model.dart';
import 'catalog_stats.dart';
import 'store_settings.dart';

/// مصدر بيانات الكتalog
enum CatalogDataSource {
  api,
  cache,
  offline,
  mock,
}

/// لقطة موحّدة للمنتجات والفئات
class CatalogSnapshot {
  const CatalogSnapshot({
    required this.products,
    required this.categories,
    required this.brands,
    required this.source,
    this.stats = const CatalogStats(),
    this.storeSettings = const StoreSettings(),
    this.warningMessage,
    this.activeCategory = 'الكل',
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
  });

  final List<ProductModel> products;
  final List<String> categories;
  final List<String> brands;
  final CatalogStats stats;
  final StoreSettings storeSettings;
  final CatalogDataSource source;
  final String? warningMessage;
  final String activeCategory;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;

  bool get hasWarning => warningMessage != null && warningMessage!.isNotEmpty;
  bool get hasMore => currentPage < lastPage;

  /// أقسام حقيقية من ERP (بدون «الكل»)
  List<String> get sectionNames =>
      categories.where((c) => c != 'الكل').toList();

  CatalogSnapshot copyWith({
    List<ProductModel>? products,
    List<String>? categories,
    List<String>? brands,
    CatalogStats? stats,
    StoreSettings? storeSettings,
    CatalogDataSource? source,
    String? warningMessage,
    bool clearWarning = false,
    String? activeCategory,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return CatalogSnapshot(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      stats: stats ?? this.stats,
      storeSettings: storeSettings ?? this.storeSettings,
      source: source ?? this.source,
      warningMessage: clearWarning ? null : (warningMessage ?? this.warningMessage),
      activeCategory: activeCategory ?? this.activeCategory,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
