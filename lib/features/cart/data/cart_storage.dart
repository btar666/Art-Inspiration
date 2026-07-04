import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';
import 'models/cart_item_model.dart';

/// تخزين السلة محلياً
class CartStorage {
  CartStorage(this._prefs);

  final SharedPreferences _prefs;

  List<CartItemModel> loadItems() {
    final raw = _prefs.getString(AppConstants.cartItemsKey);
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

  Future<void> saveItems(List<CartItemModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.cartItemsKey, encoded);
  }

  Future<void> clear() => _prefs.remove(AppConstants.cartItemsKey);
}

final cartStorageProvider = Provider<CartStorage>((ref) {
  return CartStorage(ref.watch(sharedPreferencesProvider));
});
