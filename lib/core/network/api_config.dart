import 'api_secrets.dart';

/// إعدادات الاتصال بـ أمان ERP API
///
/// الدليل: https://aman-erp.com/app/api-docs
/// Base: https://aman-erp.com/api/v1
abstract final class ApiConfig {
  static const baseUrl = 'https://aman-erp.com/api/v1';
  static const erpWebLoginUrl = 'https://aman-erp.com/app/login';
  static const apiDocsUrl = 'https://aman-erp.com/app/api-docs';

  /// الأولوية: --dart-define=AMAN_API_TOKEN ثم api_secrets.dart (من dart_defines.json)
  static String get apiToken {
    const fromBuild = String.fromEnvironment('AMAN_API_TOKEN');
    if (fromBuild.isNotEmpty) return fromBuild;
    return ApiSecrets.amanApiToken;
  }

  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);

  static const productsPerPage = 50;
  static const maxRetryAttempts = 2;
  static const retryDelay = Duration(milliseconds: 600);
}
