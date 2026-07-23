import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_storage.dart';
import '../../features/auth/data/models/auth_models.dart';
import 'api_config.dart';
import 'api_endpoints.dart';
import 'api_response_parser.dart';
import 'erp_dev_config.dart';

/// تهيئة جلسة أمان ERP للتطوير — تُستدعى عند بدء التطبيق.
abstract final class ErpDevSession {
  static bool get isActive => ErpDevConfig.enabled;

  /// بعد Onboarding انتقل مباشرة للرئيسية بدل Login.
  static bool get skipLoginToHome =>
      isActive && ErpDevConfig.accessToken.isNotEmpty;

  static Future<void> bootstrap(SharedPreferences prefs) async {
    if (!isActive || ErpDevConfig.accessToken.isEmpty) return;

    final storage = AuthStorage(prefs);
    var user = AuthUser(
      id: ErpDevConfig.userId,
      name: ErpDevConfig.userName,
      email: ErpDevConfig.userEmail,
      phone: ErpDevConfig.userPhone.isEmpty ? null : ErpDevConfig.userPhone,
    );

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${ErpDevConfig.accessToken}',
          },
        ),
      );

      final response = await dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      final root = ApiResponseParser.asMap(response.data);
      final data = root['data'];
      if (data is Map) {
        final userNode = data['user'];
        if (userNode is Map) {
          user = AuthUser.fromJson(Map<String, dynamic>.from(userNode));
        }
      }
    } catch (_) {
      // نكمل بالبيانات الافتراضية إن فشل /me
    }

    await storage.saveSession(
      AuthSession(
        tokens: const AuthTokens(
          accessToken: ErpDevConfig.accessToken,
          refreshToken: null,
        ),
        user: user,
      ),
    );
  }

  static Future<void> apply(SharedPreferences prefs) => bootstrap(prefs);
}
