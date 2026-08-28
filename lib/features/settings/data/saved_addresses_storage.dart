import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';
import '../../../core/storage/user_scoped_keys.dart';
import 'models/delivery_address_model.dart';

/// تخزين عناوين التوصيل محلياً — مفصول لكل حساب
class SavedAddressesStorage {
  SavedAddressesStorage(this._prefs);

  final SharedPreferences _prefs;

  List<DeliveryAddressModel> loadAddresses(String userKey) {
    final raw = UserScopedPrefs.readString(
      _prefs,
      baseKey: AppConstants.savedAddressesKey,
      userKey: userKey,
    );
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => DeliveryAddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAddresses(
    String userKey,
    List<DeliveryAddressModel> addresses,
  ) async {
    final encoded = jsonEncode(addresses.map((e) => e.toJson()).toList());
    await UserScopedPrefs.writeString(
      _prefs,
      baseKey: AppConstants.savedAddressesKey,
      userKey: userKey,
      value: encoded,
    );
  }

  Future<void> clear(String userKey) => UserScopedPrefs.remove(
        _prefs,
        baseKey: AppConstants.savedAddressesKey,
        userKey: userKey,
      );
}

final savedAddressesStorageProvider = Provider<SavedAddressesStorage>((ref) {
  return SavedAddressesStorage(ref.watch(sharedPreferencesProvider));
});
