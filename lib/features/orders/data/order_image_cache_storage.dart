import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/onboarding_storage.dart';
import 'models/order_model.dart';

final orderImageCacheStorageProvider = Provider<OrderImageCacheStorage>((ref) {
  return OrderImageCacheStorage(ref.watch(sharedPreferencesProvider));
});

/// كاش صور معاينة الفواتير — من تفاصيل الطلب عند غيابها في القائمة
class OrderImageCacheStorage {
  OrderImageCacheStorage(this._prefs);

  final SharedPreferences _prefs;

  String? load(String orderId) {
    final urls = loadAll(orderId);
    return urls.isEmpty ? null : urls.first;
  }

  List<String> loadAll(String orderId) {
    final map = _readMap();
    final entry = map[orderId];
    if (entry is String && entry.isNotEmpty) return [entry];
    if (entry is List) {
      return OrderModel.uniqueImageUrls(entry.map((e) => e?.toString()));
    }
    return const [];
  }

  Future<void> save(String orderId, String imageUrl) async {
    await saveAll(orderId, [imageUrl]);
  }

  Future<void> saveAll(String orderId, List<String> imageUrls) async {
    final urls = OrderModel.uniqueImageUrls(imageUrls);
    if (orderId.isEmpty || urls.isEmpty) return;
    final map = _readMap();
    map[orderId] = urls;
    await _persist(map);
  }

  Future<void> clear() => _prefs.remove(AppConstants.orderImageCacheKey);

  Map<String, dynamic> _readMap() {
    final raw = _prefs.getString(AppConstants.orderImageCacheKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['version'] != AppConstants.orderImageCacheVersion) {
        return {};
      }
      final images = decoded['images'];
      if (images is Map) {
        return Map<String, dynamic>.from(images);
      }
    } catch (_) {}

    return {};
  }

  Future<void> _persist(Map<String, dynamic> images) async {
    await _prefs.setString(
      AppConstants.orderImageCacheKey,
      jsonEncode({
        'version': AppConstants.orderImageCacheVersion,
        'images': images,
      }),
    );
  }
}
