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

  factory ApiException.network() => const ApiException(
        message: 'تحقق من اتصال الإنترنت',
        type: ApiExceptionType.network,
      );

  factory ApiException.timeout() => const ApiException(
        message: 'انتهت مهلة الاتصال — حاول مجدداً',
        type: ApiExceptionType.timeout,
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
