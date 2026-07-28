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
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String shopName,
    required String governorate,
  }) async {
    final name = '$firstName $lastName'.trim();
    return _appApi.register(
      name: name.isEmpty ? shopName : name,
      phone: phone,
      password: password,
      city: governorate,
      cosmeticName: shopName,
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
  }) =>
      _appApi.editAccount(
        name: name,
        phone: phone,
        password: password,
        city: city,
        cosmeticName: cosmeticName,
      );

  Future<void> deleteAccount() => _appApi.deleteAccount();
}
