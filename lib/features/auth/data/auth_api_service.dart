import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../app_api/data/app_api_service.dart';
import 'models/auth_models.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(appApiServiceProvider));
});

/// مصادقة الزبون عبر الباكند الخاص — art-inspiration.com
class AuthApiService {
  AuthApiService(this._appApi);

  final AppApiService _appApi;

  Future<AuthSession> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    final identifier = (phone ?? email ?? '').trim();
    if (identifier.isEmpty) {
      throw const ApiException(message: 'أدخل رقم الهاتف');
    }

    return _appApi.login(phone: identifier, password: password);
  }

  Future<AuthSession> register({
    required String name,
    required String phone,
    required String password,
    required String shopName,
    required String governorate,
    required String address,
  }) {
    final trimmed = name.trim();
    return _appApi.register(
      name: trimmed.isEmpty ? shopName : trimmed,
      phone: phone,
      password: password,
      city: governorate,
      cosmeticName: shopName,
      address: address,
    );
  }

  Future<AuthTokens> refreshToken(String token) async {
    return AuthTokens(accessToken: token);
  }

  Future<AuthUser> fetchProfile() => _appApi.fetchMyAccount();

  Future<AuthUser> updateProfile({
    required String name,
    required String phone,
    required String password,
    required String city,
    required String cosmeticName,
    required String address,
  }) =>
      _appApi.editAccount(
        name: name,
        phone: phone,
        password: password,
        city: city,
        cosmeticName: cosmeticName,
        address: address,
      );

  Future<void> deleteAccount() => _appApi.deleteAccount();
}
