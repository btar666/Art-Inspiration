import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';
import '../../home/data/models/product_model.dart';

/// تخزين المفضلات محلياً
class FavoritesStorage {
  FavoritesStorage(this._prefs);

  final SharedPreferences _prefs;

  List<ProductModel> loadProducts() {
    final raw = _prefs.getString(AppConstants.favoritesKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProducts(List<ProductModel> products) async {
    final encoded = jsonEncode(products.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.favoritesKey, encoded);
  }

  Future<void> clear() => _prefs.remove(AppConstants.favoritesKey);
}

final favoritesStorageProvider = Provider<FavoritesStorage>((ref) {
  return FavoritesStorage(ref.watch(sharedPreferencesProvider));
});
