import 'package:flutter/foundation.dart';

/// إعدادات وضع التطوير — معطّلة في الإنتاج.
abstract final class ErpDevConfig {
  static const enabled = kDebugMode && false;

  static const accessToken = '';

  static const refreshToken = '';
}
