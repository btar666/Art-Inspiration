import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/onboarding_storage.dart';
import 'models/catalog_snapshot.dart';
import 'models/catalog_stats.dart';
import 'models/product_model.dart';
import 'models/store_settings.dart';

final catalogOfflineStorageProvider = Provider<CatalogOfflineStorage>((ref) {
  return CatalogOfflineStorage(ref.watch(sharedPreferencesProvider));
});

/// كاش offline للكتalog
class CatalogOfflineStorage {
  CatalogOfflineStorage(this._prefs);

  final SharedPreferences _prefs;

  Future<void> save(CatalogSnapshot snapshot) async {
    final payload = jsonEncode({
      'version': AppConstants.catalogOfflineCacheVersion,
      'savedAt': DateTime.now().toIso8601String(),
      'products': snapshot.products.map((p) => p.toJson()).toList(),
      'categories': snapshot.categories,
      'brands': snapshot.brands,
      'categoryImages': snapshot.categoryImages,
      'stats': {
        'totalProducts': snapshot.stats.totalProducts,
        'brandCount': snapshot.stats.brandCount,
        'categoryCount': snapshot.stats.categoryCount,
        'productsWithImages': snapshot.stats.productsWithImages,
        'productsWithoutBrand': snapshot.stats.productsWithoutBrand,
      },
      'storeSettings': {
        'currencyCode': snapshot.storeSettings.currencyCode,
        'currencySymbol': snapshot.storeSettings.currencySymbol,
        'currencyArabicName': snapshot.storeSettings.currencyArabicName,
        'categories': snapshot.storeSettings.categories,
        'brands': snapshot.storeSettings.brands,
      },
      'currentPage': snapshot.currentPage,
      'lastPage': snapshot.lastPage,
      'activeCategory': snapshot.activeCategory,
    });
    await _prefs.setString(AppConstants.catalogOfflineCacheKey, payload);
  }

  CatalogSnapshot? load() {
    final raw = _prefs.getString(AppConstants.catalogOfflineCacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['version'] != AppConstants.catalogOfflineCacheVersion) {
        return null;
      }
      final products = (map['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final categories = (map['categories'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      final brands = (map['brands'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [];

      final categoryImagesRaw = map['categoryImages'];
      final categoryImages = <String, String>{};
      if (categoryImagesRaw is Map) {
        categoryImagesRaw.forEach((key, value) {
          final url = value?.toString().trim() ?? '';
          if (url.isNotEmpty) {
            categoryImages[key.toString()] = url;
          }
        });
      }

      final statsMap = map['stats'] as Map<String, dynamic>?;
      final stats = CatalogStats(
        totalProducts: statsMap?['totalProducts'] as int? ?? products.length,
        brandCount: statsMap?['brandCount'] as int? ?? brands.length,
        categoryCount: statsMap?['categoryCount'] as int? ?? 0,
        productsWithImages: statsMap?['productsWithImages'] as int? ?? 0,
        productsWithoutBrand: statsMap?['productsWithoutBrand'] as int? ?? 0,
      );

      final settingsMap = map['storeSettings'] as Map<String, dynamic>?;
      final storeSettings = StoreSettings(
        currencyCode: settingsMap?['currencyCode'] as String? ?? 'IQD',
        currencySymbol: settingsMap?['currencySymbol'] as String? ?? 'د.ع',
        currencyArabicName:
            settingsMap?['currencyArabicName'] as String? ?? 'الدينار العراقي',
        categories: (settingsMap?['categories'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        brands: (settingsMap?['brands'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

      return CatalogSnapshot(
        products: products,
        categories: categories,
        brands: brands,
        categoryImages: categoryImages,
        stats: stats,
        storeSettings: storeSettings,
        source: CatalogDataSource.offline,
        currentPage: map['currentPage'] as int? ?? 1,
        lastPage: map['lastPage'] as int? ?? 1,
        activeCategory: map['activeCategory'] as String? ?? 'الكل',
        warningMessage: 'عرض بيانات محفوظة — تحقق من الاتصال',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => _prefs.remove(AppConstants.catalogOfflineCacheKey);
}
