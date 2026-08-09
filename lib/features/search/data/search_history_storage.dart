import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';

/// تخزين سجل البحث محلياً على الجهاز
class SearchHistoryStorage {
  SearchHistoryStorage(this._prefs);

  final SharedPreferences _prefs;

  List<String> load() {
    final raw = _prefs.getString(AppConstants.searchHistoryKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<String> history) async {
    await _prefs.setString(
      AppConstants.searchHistoryKey,
      jsonEncode(history),
    );
  }

  Future<void> clear() => _prefs.remove(AppConstants.searchHistoryKey);
}

final searchHistoryStorageProvider = Provider<SearchHistoryStorage>((ref) {
  return SearchHistoryStorage(ref.watch(sharedPreferencesProvider));
});
