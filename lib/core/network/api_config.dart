/// إعدادات الاتصال بـ أمان ERP API
///
/// الدليل: https://aman-erp.com/app/api-docs
/// Base: https://aman-erp.com/api/v1
abstract final class ApiConfig {
  static const baseUrl = 'https://aman-erp.com/api/v1';
  static const erpWebLoginUrl = 'https://aman-erp.com/app/login';
  static const apiDocsUrl = 'https://aman-erp.com/app/api-docs';

  /// يُمرَّر عند البناء: --dart-define-from-file=dart_defines.json
  static const apiToken = String.fromEnvironment('AMAN_API_TOKEN');

  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);

  static const productsPerPage = 50;
  static const maxRetryAttempts = 2;
  static const retryDelay = Duration(milliseconds: 600);
}
