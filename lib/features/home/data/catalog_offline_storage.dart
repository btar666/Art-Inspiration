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

/// كاش offline للكتalog — منتجات لكل قسم/براند + taxonomy مشترك
class CatalogOfflineStorage {
  CatalogOfflineStorage(this._prefs);

  final SharedPreferences _prefs;

  Future<void> save(CatalogSnapshot snapshot) async {
    final root = _readRoot() ?? <String, dynamic>{};
    final byCategory = Map<String, dynamic>.from(
      root['byCategory'] as Map<String, dynamic>? ?? {},
    );

    byCategory[snapshot.activeCategory] = _encodeCategoryEntry(
      snapshot.products,
      currentPage: snapshot.currentPage,
      lastPage: snapshot.lastPage,
    );

    final payload = jsonEncode({
      'version': AppConstants.catalogOfflineCacheVersion,
      'savedAt': DateTime.now().toIso8601String(),
      'categories': snapshot.categories,
      'brands': snapshot.brands,
      'categoryImages': snapshot.categoryImages ?? const {},
      'brandImages': snapshot.brandImages ?? const {},
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
      'byCategory': byCategory,
    });

    await _prefs.setString(AppConstants.catalogOfflineCacheKey, payload);
  }

  /// لقطة «الكل» — للعرض الفوري عند فتح التطبيق
  CatalogSnapshot? loadDefault() => loadForCategory('الكل');

  CatalogSnapshot? loadForCategory(String category) {
    final root = _readRoot();
    if (root == null) return null;

    final byCategory = root['byCategory'] as Map<String, dynamic>?;
    if (byCategory == null) return null;

    final entry = byCategory[category] as Map<String, dynamic>?;
    if (entry == null) return null;

    return _snapshotFromRoot(root, category, entry);
  }

  Map<String, dynamic>? _readRoot() {
    final raw = _prefs.getString(AppConstants.catalogOfflineCacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final version = map['version'];

      if (version == AppConstants.catalogOfflineCacheVersion) {
        return map;
      }

      // ترقية من الإصدار 7 — منتجات واحدة تحت activeCategory
      if (version == 7) {
        final activeCategory = map['activeCategory'] as String? ?? 'الكل';
        return {
          'version': AppConstants.catalogOfflineCacheVersion,
          'savedAt': map['savedAt'],
          'categories': map['categories'],
          'brands': map['brands'],
          'categoryImages': map['categoryImages'],
          'brandImages': map['brandImages'],
          'stats': map['stats'],
          'storeSettings': map['storeSettings'],
          'byCategory': {
            activeCategory: {
              'products': map['products'],
              'currentPage': map['currentPage'] ?? 1,
              'lastPage': map['lastPage'] ?? 1,
              'savedAt': map['savedAt'],
            },
          },
        };
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  CatalogSnapshot? _snapshotFromRoot(
    Map<String, dynamic> root,
    String category,
    Map<String, dynamic> entry,
  ) {
    try {
      final products = (entry['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final categoryImagesRaw = root['categoryImages'];
      final categoryImages = <String, String>{};
      if (categoryImagesRaw is Map) {
        categoryImagesRaw.forEach((key, value) {
          final url = value?.toString().trim() ?? '';
          if (url.isNotEmpty) {
            categoryImages[key.toString()] = url;
          }
        });
      }

      final brandImagesRaw = root['brandImages'];
      final brandImages = <String, String>{};
      if (brandImagesRaw is Map) {
        brandImagesRaw.forEach((key, value) {
          final url = value?.toString().trim() ?? '';
          if (url.isNotEmpty) {
            brandImages[key.toString()] = url;
          }
        });
      }

      final statsMap = root['stats'] as Map<String, dynamic>?;
      final stats = CatalogStats(
        totalProducts: statsMap?['totalProducts'] as int? ?? products.length,
        brandCount: statsMap?['brandCount'] as int? ?? 0,
        categoryCount: statsMap?['categoryCount'] as int? ?? 0,
        productsWithImages: statsMap?['productsWithImages'] as int? ?? 0,
        productsWithoutBrand: statsMap?['productsWithoutBrand'] as int? ?? 0,
      );

      final settingsMap = root['storeSettings'] as Map<String, dynamic>?;
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

      final categories = (root['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['الكل'];
      final brands = (root['brands'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [];

      return CatalogSnapshot(
        products: products,
        categories: categories,
        brands: brands,
        categoryImages: categoryImages,
        brandImages: brandImages,
        stats: stats,
        storeSettings: storeSettings,
        source: CatalogDataSource.offline,
        currentPage: entry['currentPage'] as int? ?? 1,
        lastPage: entry['lastPage'] as int? ?? 1,
        activeCategory: category,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _encodeCategoryEntry(
    List<ProductModel> products, {
    required int currentPage,
    required int lastPage,
  }) {
    return {
      'products': products.map((p) => p.toJson()).toList(),
      'currentPage': currentPage,
      'lastPage': lastPage,
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> clear() => _prefs.remove(AppConstants.catalogOfflineCacheKey);
}
