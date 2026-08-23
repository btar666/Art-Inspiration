import 'connectivity_service.dart';

/// خطأ موحّد من الـ API
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.type = ApiExceptionType.unknown,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final ApiExceptionType type;

  /// أخطاء شبكة/سيرفر — تعرض دايلوج الاتصال
  bool get isConnectivityOrServerError {
    if (type == ApiExceptionType.unauthorized) return false;
    if (type == ApiExceptionType.network ||
        type == ApiExceptionType.timeout ||
        type == ApiExceptionType.server) {
      return true;
    }
    final code = statusCode;
    if (code != null && code >= 500) return true;
    return false;
  }

  factory ApiException.network() => ApiException(
        message: ConnectivityService.connectionMessage,
        type: ApiExceptionType.network,
      );

  factory ApiException.timeout() => ApiException(
        message: ConnectivityService.connectionMessage,
        type: ApiExceptionType.timeout,
      );

  factory ApiException.server({int? statusCode}) => ApiException(
        message: ConnectivityService.connectionMessage,
        statusCode: statusCode,
        type: ApiExceptionType.server,
      );

  factory ApiException.unauthorized() => const ApiException(
        message: 'انتهت الجلسة — سجّل الدخول مجدداً',
        statusCode: 401,
        code: 'UNAUTHORIZED',
        type: ApiExceptionType.unauthorized,
      );

  @override
  String toString() => message;
}

enum ApiExceptionType {
  network,
  timeout,
  unauthorized,
  server,
  unknown,
}
