import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_storage.dart';
import '../../features/auth/data/models/auth_models.dart';
import 'api_config.dart';
import 'api_endpoints.dart';
import 'api_response_parser.dart';
import 'erp_dev_config.dart';

/// تهيئة جلسة Dan ERP للتطوير — تُستدعى عند بدء التطبيق.
abstract final class ErpDevSession {
  static bool get isActive => ErpDevConfig.enabled;

  /// بعد Onboarding انتقل مباشرة للرئيسية بدل Login.
  static bool get skipLoginToHome =>
      isActive &&
      (ErpDevConfig.accessToken.isNotEmpty ||
          (ErpDevConfig.email.isNotEmpty && ErpDevConfig.password.isNotEmpty));

  static Future<void> bootstrap(SharedPreferences prefs) async {
    if (!isActive) return;

    final storage = AuthStorage(prefs);

    if (ErpDevConfig.accessToken.isNotEmpty) {
      await storage.saveSession(
        AuthSession(
          tokens: AuthTokens(
            accessToken: ErpDevConfig.accessToken,
            refreshToken: ErpDevConfig.refreshToken.isEmpty
                ? null
                : ErpDevConfig.refreshToken,
          ),
          user: AuthUser(
            id: ErpDevConfig.userId,
            name: ErpDevConfig.userName,
            email: ErpDevConfig.userEmail,
            phone: ErpDevConfig.userPhone,
          ),
        ),
      );
      return;
    }

    if (ErpDevConfig.email.isEmpty || ErpDevConfig.password.isEmpty) return;

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'x-client': ApiConfig.clientId,
          },
        ),
      );

      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'email': ErpDevConfig.email,
          'password': ErpDevConfig.password,
        },
      );

      final root = ApiResponseParser.asMap(response.data);
      final tokens = AuthTokens.fromJson(root);
      if (tokens.accessToken.isEmpty) return;

      AuthUser? user;
      final userNode = root['user'];
      if (userNode is Map) {
        user = AuthUser.fromJson(Map<String, dynamic>.from(userNode));
      }

      await storage.saveSession(
        AuthSession(
          tokens: tokens,
          user: user ??
              AuthUser(
                id: ErpDevConfig.userId,
                name: ErpDevConfig.userName,
                email: ErpDevConfig.userEmail,
                phone: ErpDevConfig.userPhone,
              ),
        ),
      );
    } catch (_) {
      // فشل الدخول التلقائي — يبقى المستخدم على شاشة Login
    }
  }

  static Future<void> apply(SharedPreferences prefs) => bootstrap(prefs);
}
