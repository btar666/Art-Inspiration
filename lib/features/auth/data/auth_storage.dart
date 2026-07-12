import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/onboarding_storage.dart';
import 'models/auth_models.dart';

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage(ref.watch(sharedPreferencesProvider));
});

/// تخزين محلي للتوكنات وبيانات المستخدم
class AuthStorage {
  AuthStorage(this._prefs);

  final SharedPreferences _prefs;

  String? get accessToken => _prefs.getString(AppConstants.authAccessTokenKey);
  String? get refreshToken => _prefs.getString(AppConstants.authRefreshTokenKey);

  AuthUser? get user {
    final raw = _prefs.getString(AppConstants.authUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  Future<void> saveSession(AuthSession session) async {
    await saveTokens(session.tokens);
    if (session.user != null) {
      await _prefs.setString(
        AppConstants.authUserKey,
        jsonEncode(session.user!.toJson()),
      );
    }
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    await _prefs.setString(AppConstants.authAccessTokenKey, tokens.accessToken);
    if (tokens.refreshToken != null) {
      await _prefs.setString(
        AppConstants.authRefreshTokenKey,
        tokens.refreshToken!,
      );
    }
  }

  Future<void> clear() async {
    await _prefs.remove(AppConstants.authAccessTokenKey);
    await _prefs.remove(AppConstants.authRefreshTokenKey);
    await _prefs.remove(AppConstants.authUserKey);
  }
}
