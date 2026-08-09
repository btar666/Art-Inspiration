import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/onboarding_storage.dart';

final notificationsStorageProvider = Provider<NotificationsStorage>((ref) {
  return NotificationsStorage(ref.watch(sharedPreferencesProvider));
});

/// تخزين نطاق الإشعارات المرئية وآخر وقت قراءة لكل مستخدم
class NotificationsStorage {
  NotificationsStorage(this._prefs);

  final SharedPreferences _prefs;

  static String _visibleSinceKey(String userId) =>
      'notifications_visible_since_$userId';

  static String _lastReadAtKey(String userId) =>
      'notifications_last_read_at_$userId';

  DateTime? visibleSince(String userId) =>
      _parseDate(_prefs.getString(_visibleSinceKey(userId)));

  DateTime? lastReadAt(String userId) =>
      _parseDate(_prefs.getString(_lastReadAtKey(userId)));

  /// يُستدعى عند بدء جلسة — يضبط نطاق الإشعارات إن لم يكن مُسجَّلاً مسبقاً
  Future<void> onUserSessionStarted(String userId) async {
    if (userId.isEmpty) return;
    if (_prefs.containsKey(_visibleSinceKey(userId))) {
      await _repairVisibleSince(userId);
      return;
    }

  // مفتاح غائب: المستخدم كان يرى الإشعارات بلا فلترة — لا نخفيها عند إعادة الدخول
    await _prefs.setString(
      _visibleSinceKey(userId),
      DateTime.fromMillisecondsSinceEpoch(0).toIso8601String(),
    );
  }

  /// يُصلح visibleSince إن ضُبط خطأً بعد إعادة تسجيل الدخول
  Future<void> _repairVisibleSince(String userId) async {
    final since = visibleSince(userId);
    if (since == null) return;

    final lastRead = lastReadAt(userId);
    if (lastRead != null && since.isAfter(lastRead)) {
      await _prefs.setString(
        _visibleSinceKey(userId),
        lastRead.toIso8601String(),
      );
    }
  }

  /// يُعيد نطاق الإشعارات لعرض كل الإشعارات من السيرفر
  Future<void> resetVisibleSince(String userId) async {
    if (userId.isEmpty) return;
    await _prefs.setString(
      _visibleSinceKey(userId),
      DateTime.fromMillisecondsSinceEpoch(0).toIso8601String(),
    );
  }

  Future<void> markAllRead(String userId) async {
    if (userId.isEmpty) return;
    await _prefs.setString(
      _lastReadAtKey(userId),
      DateTime.now().toIso8601String(),
    );
  }

  bool isRead({
    required String userKey,
    required DateTime? createdAt,
  }) {
    if (createdAt == null) return true;

    final createdLocal = createdAt.toLocal();
    final lastRead = lastReadAt(userKey)?.toLocal();
    if (lastRead == null) return false;

    return !createdLocal.isAfter(lastRead);
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
