import 'package:shared_preferences/shared_preferences.dart';

import 'erp_dev_config.dart';

/// إعدادات تطوير — الكتالوج يعمل بمفتاح أمان ERP الثابت.
/// تسجيل دخول الزبون يتم عبر art-inspiration.com (لا نحقن توكن Aman هنا).
abstract final class ErpDevSession {
  static bool get isActive => ErpDevConfig.enabled;

  /// لا تتخطَّ Login تلقائياً — الزبون يحتاج حساب التطبيق.
  static bool get skipLoginToHome => false;

  static Future<void> bootstrap(SharedPreferences prefs) async {
    // أمان ERP يستخدم ApiConfig.apiToken مباشرة — بدون تخزين في AuthStorage
  }

  static Future<void> apply(SharedPreferences prefs) => bootstrap(prefs);
}
