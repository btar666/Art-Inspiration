/// إعدادات الاتصال بـ أمان ERP API
///
/// الدليل: https://aman-erp.com/app/api-docs
/// Base: https://aman-erp.com/api/v1
abstract final class ApiConfig {
  static const baseUrl = 'https://aman-erp.com/api/v1';
  static const erpWebLoginUrl = 'https://aman-erp.com/app/login';
  static const apiDocsUrl = 'https://aman-erp.com/app/api-docs';

  /// مفتاح API من Postman (بلا انتهاء صلاحية حسب دليل أمان ERP).
  static const apiToken =
      'amanerp_cTbmF4tHrBdVaLTqtBo2GWSzbPmdYPuAHRwIx4iZH6OR0ofm';

  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);

  static const productsPerPage = 50;
  static const maxRetryAttempts = 2;
  static const retryDelay = Duration(milliseconds: 600);
}
