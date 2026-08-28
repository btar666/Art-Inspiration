import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_storage.dart';

/// مفتاح كاش الحساب النشط — يُزرع من التخزين عند الإقلاع ويُحدَّث عند الدخول/الخروج
final activeUserCacheKeyProvider = StateProvider<String>((ref) {
  final storage = ref.watch(authStorageProvider);
  if (!storage.isLoggedIn) return '';
  return storage.user?.notificationUserKey.trim() ?? '';
});
