import 'dart:convert';

import 'api_exception.dart';

/// أدوات مساعدة لتحليل استجابات Dan ERP
abstract final class ApiResponseParser {
  static Map<String, dynamic> asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException(message: 'استجابة غير متوقعة من الخادم');
  }

  static String messageFrom(dynamic data, {String fallback = 'حدث خطأ'}) {
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    return fallback;
  }

  static List<Map<String, dynamic>> extractItems(dynamic data) {
    final root = asMap(data);

    final direct = root['data'];
    if (direct is List) {
      return direct.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }

    if (direct is Map) {
      final nested = direct['data'];
      if (nested is List) {
        return nested.whereType<Map>().map(Map<String, dynamic>.from).toList();
      }
    }

    final items = root['items'];
    if (items is List) {
      return items.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }

    return const [];
  }

  static Map<String, dynamic>? decodeJsonField(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }
}
