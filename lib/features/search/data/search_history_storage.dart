import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';
import '../../../core/storage/user_scoped_keys.dart';

/// تخزين سجل البحث محلياً — مفصول لكل حساب
class SearchHistoryStorage {
  SearchHistoryStorage(this._prefs);

  final SharedPreferences _prefs;

  List<String> load(String userKey) {
    final raw = UserScopedPrefs.readString(
      _prefs,
      baseKey: AppConstants.searchHistoryKey,
      userKey: userKey,
    );
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => e.toString())
          .take(AppConstants.maxSearchHistoryItems)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(String userKey, List<String> history) async {
    await UserScopedPrefs.writeString(
      _prefs,
      baseKey: AppConstants.searchHistoryKey,
      userKey: userKey,
      value: jsonEncode(
        history.take(AppConstants.maxSearchHistoryItems).toList(),
      ),
    );
  }

  Future<void> clear(String userKey) => UserScopedPrefs.remove(
        _prefs,
        baseKey: AppConstants.searchHistoryKey,
        userKey: userKey,
      );
}

final searchHistoryStorageProvider = Provider<SearchHistoryStorage>((ref) {
  return SearchHistoryStorage(ref.watch(sharedPreferencesProvider));
});
