import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// يحفظ آخر item_id من FCM حتى لو ضُغط الإشعار الذي بلا بيانات
abstract final class PendingProductStore {
  static const _ttl = Duration(minutes: 15);

  static Future<void> save(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.pendingNotificationProductIdKey, itemId);
    await prefs.setInt(
      AppConstants.pendingNotificationProductAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<String?> peek() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(AppConstants.pendingNotificationProductIdKey);
    final at = prefs.getInt(AppConstants.pendingNotificationProductAtKey) ?? 0;
    if (id == null || id.isEmpty) return null;
    final age = DateTime.now().millisecondsSinceEpoch - at;
    if (age > _ttl.inMilliseconds) return null;
    return id;
  }

  static Future<String?> take() async {
    final id = await peek();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.pendingNotificationProductIdKey);
    await prefs.remove(AppConstants.pendingNotificationProductAtKey);
    return id;
  }
}
