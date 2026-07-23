import 'models/catalog_stats.dart';

/// بناء بيانات الكتالوج من قوائم أمان ERP
abstract final class ErpCatalogMetadata {
  static CatalogMetadata fromLookups({
    required List<String> categoryNames,
    required List<String> brandNames,
    required int totalProducts,
    int productsWithImages = 0,
    int productsWithoutBrand = 0,
  }) {
    final categories = <String>{'الكل', ...categoryNames};
    final brands = {...brandNames};

    final sortedCategories = categories.toList()
      ..sort((a, b) {
        if (a == 'الكل') return -1;
        if (b == 'الكل') return 1;
        return a.compareTo(b);
      });
    final sortedBrands = brands.toList()..sort();

    return CatalogMetadata(
      categories: sortedCategories,
      brands: sortedBrands,
      stats: CatalogStats(
        totalProducts: totalProducts,
        brandCount: sortedBrands.length,
        categoryCount: sortedCategories.where((c) => c != 'الكل').length,
        productsWithImages: productsWithImages,
        productsWithoutBrand: productsWithoutBrand,
      ),
    );
  }
}

class CatalogMetadata {
  const CatalogMetadata({
    required this.categories,
    required this.brands,
    required this.stats,
  });

  final List<String> categories;
  final List<String> brands;
  final CatalogStats stats;
}
