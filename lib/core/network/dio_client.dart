import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'api_response_parser.dart';
import 'retry_interceptor.dart';

/// Dio بدون Bearer — نادر الاستخدام مع أمان ERP
final baseDioProvider = Provider<Dio>((ref) {
  final dio = _createDio();
  dio.interceptors.add(RetryInterceptor(dio: dio));
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

/// Dio لطلبات أمان ERP — Bearer API key
final dioProvider = Provider<Dio>((ref) {
  final authStorage = ref.watch(authStorageProvider);

  final dio = _createDio();
  dio.interceptors.add(RetryInterceptor(dio: dio));
  dio.interceptors.add(_AmanAuthInterceptor(authStorage: authStorage));

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: false,
      ),
    );
  }

  ref.onDispose(() => dio.close(force: true));
  return dio;
});

Dio _createDio() {
  return Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
}

class _AmanAuthInterceptor extends Interceptor {
  _AmanAuthInterceptor({required this.authStorage});

  final AuthStorage authStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final stored = authStorage.accessToken;
    final token = (stored != null && stored.isNotEmpty)
        ? stored
        : ApiConfig.apiToken;
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

ApiException mapDioError(DioException error) {
  final response = error.response;
  final data = response?.data;

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return ApiException.timeout();
  }

  if (error.type == DioExceptionType.connectionError) {
    return ApiException.network();
  }

  final message = ApiResponseParser.messageFrom(
    data,
    fallback: error.message ?? 'فشل الاتصال بالخادم',
  );

  String? code;
  if (data is Map && data['code'] is String) {
    code = data['code'] as String;
  }

  return ApiException(
    message: _localizedMessage(message, response?.statusCode),
    statusCode: response?.statusCode,
    code: code,
  );
}

String _localizedMessage(String message, int? statusCode) {
  if (statusCode == 401) {
    return 'مفتاح API غير صالح — راجع إعدادات أمان ERP';
  }
  if (statusCode == 402) {
    return 'انتهى الاشتراك أو الفترة التجريبية في أمان ERP';
  }
  if (statusCode == 403) {
    return 'لا تملك صلاحية هذه العملية';
  }
  if (statusCode == 429) {
    return 'تم تجاوز حد الطلبات — حاول بعد قليل';
  }
  return message;
}

Future<Response<T>> safeRequest<T>(
  Future<Response<T>> Function() request,
) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw mapDioError(error);
  }
}
