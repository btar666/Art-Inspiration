import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';
import '../../../core/storage/user_scoped_keys.dart';
import 'models/cart_item_model.dart';

/// تخزين السلة محلياً — مفصول لكل حساب
class CartStorage {
  CartStorage(this._prefs);

  final SharedPreferences _prefs;

  List<CartItemModel> loadItems(String userKey) {
    final raw = UserScopedPrefs.readString(
      _prefs,
      baseKey: AppConstants.cartItemsKey,
      userKey: userKey,
    );
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveItems(String userKey, List<CartItemModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await UserScopedPrefs.writeString(
      _prefs,
      baseKey: AppConstants.cartItemsKey,
      userKey: userKey,
      value: encoded,
    );
  }

  Future<void> clear(String userKey) => UserScopedPrefs.remove(
        _prefs,
        baseKey: AppConstants.cartItemsKey,
        userKey: userKey,
      );
}

final cartStorageProvider = Provider<CartStorage>((ref) {
  return CartStorage(ref.watch(sharedPreferencesProvider));
});
