import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_api_service.dart';
import '../../features/auth/data/auth_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'api_response_parser.dart';
import 'retry_interceptor.dart';
import 'token_refresh_coordinator.dart';

final tokenRefreshCoordinatorProvider =
    Provider<TokenRefreshCoordinator>((ref) => TokenRefreshCoordinator());

/// Dio للمصادقة فقط — retry للشبكة
final baseDioProvider = Provider<Dio>((ref) {
  final dio = _createDio();
  dio.interceptors.add(RetryInterceptor(dio: dio));
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

/// Dio للطلبات المحمية — Bearer + refresh + logging
final dioProvider = Provider<Dio>((ref) {
  final authStorage = ref.watch(authStorageProvider);
  final authApi = ref.read(authApiServiceProvider);
  final coordinator = ref.watch(tokenRefreshCoordinatorProvider);

  final dio = _createDio();
  dio.interceptors.add(RetryInterceptor(dio: dio));
  dio.interceptors.add(
    _AuthInterceptor(
      authStorage: authStorage,
      authApi: authApi,
      dio: dio,
      coordinator: coordinator,
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
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
        'x-client': ApiConfig.clientId,
      },
    ),
  );
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({
    required this.authStorage,
    required this.authApi,
    required this.dio,
    required this.coordinator,
  });

  final AuthStorage authStorage;
  final AuthApiService authApi;
  final Dio dio;
  final TokenRefreshCoordinator coordinator;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = authStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final isUnauthorized = response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (!isUnauthorized || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = authStorage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      final tokens = await coordinator.run(
        () => authApi.refreshToken(refreshToken),
      );
      await authStorage.saveTokens(tokens);

      final request = err.requestOptions;
      request.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      request.extra['retried'] = true;

      final retryResponse = await dio.fetch<dynamic>(request);
      handler.resolve(retryResponse);
    } catch (_) {
      await authStorage.clear();
      handler.next(err);
    }
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
  final lower = message.toLowerCase();
  if (lower.contains('invalid credentials') || statusCode == 402) {
    return 'بيانات الدخول غير صحيحة — تحقق من البريد وكلمة المرور';
  }
  if (lower.contains('token has expired') || lower.contains('token expired')) {
    return 'انتهت الجلسة — سجّل الدخول مجدداً';
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
