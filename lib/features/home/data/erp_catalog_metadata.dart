import '../../../core/network/api_response_parser.dart';
import 'erp_product_fields.dart';
import 'models/catalog_stats.dart';

/// استخراج الأقسام والبراندات من سجلات المنتجات
abstract final class ErpCatalogMetadata {
  static CatalogMetadata fromProductRecords(
    List<Map<String, dynamic>> records, {
    int totalProducts = 0,
    List<String> settingsCategories = const [],
    List<String> settingsBrands = const [],
  }) {
    final categories = <String>{'الكل', ...settingsCategories};
    final brands = <String>{...settingsBrands};
    var productsWithImages = 0;
    var productsWithoutBrand = 0;

    for (final record in records) {
      final main = ApiResponseParser.decodeJsonField(record['main']) ?? {};

      categories.addAll(ErpProductFields.categoryValues(main));

      final brand = ErpProductFields.brandValue(main);
      if (brand.isNotEmpty) {
        brands.add(brand);
      } else {
        productsWithoutBrand++;
      }

      final imageName = _firstNonEmpty([
        main['imageName'],
        record['imageName'],
      ]);
      if (imageName.isNotEmpty) productsWithImages++;
    }

    final sortedCategories = categories.toList()
      ..sort((a, b) {
        if (a == 'الكل') return -1;
        if (b == 'الكل') return 1;
        return a.compareTo(b);
      });
    final sortedBrands = brands.toList()..sort();

    final categoryCount =
        sortedCategories.where((c) => c != 'الكل').length;

    return CatalogMetadata(
      categories: sortedCategories,
      brands: sortedBrands,
      stats: CatalogStats(
        totalProducts: totalProducts > 0 ? totalProducts : records.length,
        brandCount: sortedBrands.length,
        categoryCount: categoryCount,
        productsWithImages: productsWithImages,
        productsWithoutBrand: productsWithoutBrand,
      ),
    );
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
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
