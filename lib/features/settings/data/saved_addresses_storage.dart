import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';
import 'models/delivery_address_model.dart';

/// تخزين عناوين التوصيل محلياً
class SavedAddressesStorage {
  SavedAddressesStorage(this._prefs);

  final SharedPreferences _prefs;

  List<DeliveryAddressModel> loadAddresses() {
    final raw = _prefs.getString(AppConstants.savedAddressesKey);
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

  Future<void> saveAddresses(List<DeliveryAddressModel> addresses) async {
    final encoded = jsonEncode(addresses.map((e) => e.toJson()).toList());
    await _prefs.setString(AppConstants.savedAddressesKey, encoded);
  }

  Future<void> clear() => _prefs.remove(AppConstants.savedAddressesKey);
}

final savedAddressesStorageProvider = Provider<SavedAddressesStorage>((ref) {
  return SavedAddressesStorage(ref.watch(sharedPreferencesProvider));
});
