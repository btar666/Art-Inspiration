import 'api_config.dart';

/// إعدادات مؤقتة لجلسة أمان ERP في وضع التطوير.
///
/// عطّل [enabled] عند الاعتماد على شاشة Login فقط.
abstract final class ErpDevConfig {
  static const enabled = true;

  /// حساب لوحة أمان ERP (للرجوع اليدوي عبر الويب).
  static const email = 'thoalfo8ar.s@gmail.com';
  static const password = 'jabpav-vihci3-pokcaT';

  /// مفتاح API من كولكشن Postman — يُستخدم لكل طلبات /api/v1.
  static const accessToken = ApiConfig.apiToken;

  static const refreshToken = '';

  static const userId = '46';
  static const userName = 'ذوالفقار سمير';
  static const userEmail = 'thoalfo8ar.s@gmail.com';
  static const userPhone = '';
}
