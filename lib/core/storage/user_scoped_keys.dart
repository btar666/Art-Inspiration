import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// مفاتيح تخزين مربوطة بحساب المستخدم — حتى لا تختلط بيانات حسابين على نفس الجهاز
abstract final class UserScopedKeys {
  static String of(String baseKey, String userKey) {
    final id = userKey.trim();
    if (id.isEmpty) return '${baseKey}__guest';
    return '${baseKey}__u__$id';
  }
}

/// قراءة/كتابة مع ترحيل لمرة واحدة من المفتاح القديم غير المربوط بحساب
abstract final class UserScopedPrefs {
  static String? readString(
    SharedPreferences prefs, {
    required String baseKey,
    required String userKey,
  }) {
    final scopedKey = UserScopedKeys.of(baseKey, userKey);
    final scoped = prefs.getString(scopedKey);
    if (scoped != null && scoped.isNotEmpty) return scoped;

    // لا نرحّل الكاش القديم إلى جلسة ضيف
    if (userKey.trim().isEmpty) return null;

    final legacy = prefs.getString(baseKey);
    if (legacy == null || legacy.isEmpty) return null;

    prefs.setString(scopedKey, legacy);
    prefs.remove(baseKey);
    return legacy;
  }

  static Future<void> writeString(
    SharedPreferences prefs, {
    required String baseKey,
    required String userKey,
    required String value,
  }) {
    return prefs.setString(UserScopedKeys.of(baseKey, userKey), value);
  }

  static Future<void> remove(
    SharedPreferences prefs, {
    required String baseKey,
    required String userKey,
  }) {
    return prefs.remove(UserScopedKeys.of(baseKey, userKey));
  }

  /// مفاتيح الكاش الخاصة بالحساب (تُرحَّل من الشكل القديم عند أول دخول)
  static const accountCacheBaseKeys = [
    AppConstants.cartItemsKey,
    AppConstants.favoritesKey,
    AppConstants.savedAddressesKey,
    AppConstants.localOrdersKey,
    AppConstants.searchHistoryKey,
    checkoutCustomerNameKey,
    checkoutCustomerPhoneKey,
    checkoutCustomerSecondPhoneKey,
  ];

  static const checkoutCustomerNameKey = 'checkout_customer_name';
  static const checkoutCustomerPhoneKey = 'checkout_customer_phone';
  static const checkoutCustomerSecondPhoneKey = 'checkout_customer_second_phone';

  /// ترحيل كل المفاتيح القديمة دفعة واحدة عند بدء جلسة مستخدم
  static Future<void> migrateLegacyForUser(
    SharedPreferences prefs,
    String userKey,
  ) async {
    final id = userKey.trim();
    if (id.isEmpty) return;

    for (final base in accountCacheBaseKeys) {
      final scopedKey = UserScopedKeys.of(base, id);
      if (prefs.containsKey(scopedKey)) continue;
      final legacy = prefs.getString(base);
      if (legacy == null || legacy.isEmpty) continue;
      await prefs.setString(scopedKey, legacy);
      await prefs.remove(base);
    }
  }
}
