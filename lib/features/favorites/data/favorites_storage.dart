import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';
import '../../../core/storage/user_scoped_keys.dart';
import '../../home/data/models/product_model.dart';

/// تخزين المفضلات محلياً — مفصول لكل حساب
class FavoritesStorage {
  FavoritesStorage(this._prefs);

  final SharedPreferences _prefs;

  List<ProductModel> loadProducts(String userKey) {
    final raw = UserScopedPrefs.readString(
      _prefs,
      baseKey: AppConstants.favoritesKey,
      userKey: userKey,
    );
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

  Future<void> saveProducts(
    String userKey,
    List<ProductModel> products,
  ) async {
    final encoded = jsonEncode(products.map((e) => e.toJson()).toList());
    await UserScopedPrefs.writeString(
      _prefs,
      baseKey: AppConstants.favoritesKey,
      userKey: userKey,
      value: encoded,
    );
  }

  Future<void> clear(String userKey) => UserScopedPrefs.remove(
        _prefs,
        baseKey: AppConstants.favoritesKey,
        userKey: userKey,
      );
}

final favoritesStorageProvider = Provider<FavoritesStorage>((ref) {
  return FavoritesStorage(ref.watch(sharedPreferencesProvider));
});
