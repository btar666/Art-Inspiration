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
      final errorsText = _firstValidationError(data['errors']);
      if (errorsText != null) return errorsText;

      final message = data['message'] ?? data['error'];
      final localized = _localizedText(message);
      if (localized != null) return localized;
    }
    return fallback;
  }

  /// Dan ERP: message قد يكون نصاً أو {"ar":"...","en":"..."}
  static String? _localizedText(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    if (value is Map) {
      final ar = value['ar']?.toString().trim() ?? '';
      if (ar.isNotEmpty) return ar;
      final en = value['en']?.toString().trim() ?? '';
      if (en.isNotEmpty) return en;
    }
    return null;
  }

  /// أول رسالة تحقق من errors (مثل items.0.stock)
  static String? _firstValidationError(dynamic errors) {
    if (errors is! Map || errors.isEmpty) return null;

    for (final value in errors.values) {
      final text = _localizedText(value);
      if (text != null) return text;

      if (value is List && value.isNotEmpty) {
        final first = _localizedText(value.first) ?? value.first.toString();
        if (first.trim().isNotEmpty) return first.trim();
      }
    }
    return null;
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
