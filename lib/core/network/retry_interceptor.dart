import 'package:dio/dio.dart';

import 'api_config.dart';

/// إعادة المحاولة التلقائية لأخطاء الشبكة المؤقتة
class RetryInterceptor extends Interceptor {
  RetryInterceptor({Dio? dio}) : _dio = dio;

  final Dio? _dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);
    final attempt = (err.requestOptions.extra['retry_attempt'] as int?) ?? 0;

    if (!shouldRetry || attempt >= ApiConfig.maxRetryAttempts) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(ApiConfig.retryDelay);

    final options = err.requestOptions;
    options.extra['retry_attempt'] = attempt + 1;

    try {
      final client = _dio ?? Dio(options.baseUrl.isNotEmpty
          ? BaseOptions(baseUrl: options.baseUrl)
          : null);
      final response = await client.fetch<dynamic>(options);
      handler.resolve(response);
    } catch (error) {
      if (error is DioException) {
        handler.next(error);
      } else {
        handler.next(err);
      }
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
