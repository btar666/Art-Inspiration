import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';
import 'models/taxonomy_cache_entry.dart';

final taxonomyCacheStorageProvider = Provider<TaxonomyCacheStorage>((ref) {
  return TaxonomyCacheStorage(ref.watch(sharedPreferencesProvider));
});

/// تخزين taxonomy (أقسام/براندات) — صلاحية 24 ساعة
class TaxonomyCacheStorage {
  TaxonomyCacheStorage(this._prefs);

  final SharedPreferences _prefs;

  Future<void> save(TaxonomyCacheEntry entry) async {
    final payload = jsonEncode({
      'version': AppConstants.taxonomyCacheVersion,
      ...entry.toJson(),
    });
    await _prefs.setString(AppConstants.taxonomyCacheKey, payload);
  }

  TaxonomyCacheEntry? load() {
    final raw = _prefs.getString(AppConstants.taxonomyCacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['version'] != AppConstants.taxonomyCacheVersion) return null;
      return TaxonomyCacheEntry.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => _prefs.remove(AppConstants.taxonomyCacheKey);
}
