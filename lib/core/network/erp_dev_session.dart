import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_storage.dart';
import '../../features/auth/data/models/auth_models.dart';
import 'erp_dev_config.dart';

/// تهيئة جلسة Dan ERP للتطوير — تُستدعى عند بدء التطبيق.
abstract final class ErpDevSession {
  static bool get isActive =>
      ErpDevConfig.enabled && ErpDevConfig.accessToken.isNotEmpty;

  /// بعد Onboarding انتقل مباشرة للرئيسية بدل Login.
  static bool get skipLoginToHome => isActive;

  static Future<void> bootstrap(SharedPreferences prefs) async {
    if (!isActive) return;

    final storage = AuthStorage(prefs);
    await storage.saveSession(
      AuthSession(
        tokens: AuthTokens(
          accessToken: ErpDevConfig.accessToken,
          refreshToken: ErpDevConfig.refreshToken.isEmpty
              ? null
              : ErpDevConfig.refreshToken,
        ),
        user: const AuthUser(
          id: ErpDevConfig.userId,
          name: ErpDevConfig.userName,
          email: ErpDevConfig.userEmail,
        ),
      ),
    );
  }

  static Future<void> apply(SharedPreferences prefs) => bootstrap(prefs);
}
