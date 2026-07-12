/// إعدادات الاتصال بـ Dan ERP API
abstract final class ApiConfig {
  static const baseUrl = 'https://api.dan-erp.com';
  static const erpWebLoginUrl = 'https://dan-erp.com/login';
  static const clientId = 'tenant_thoalfo8ar_s_gmail_com_0002eb9d';

  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);

  static const productsPerPage = 20;
  static const maxRetryAttempts = 2;
  static const retryDelay = Duration(milliseconds: 600);
}
