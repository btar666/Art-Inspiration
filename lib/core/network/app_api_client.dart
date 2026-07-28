import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_storage.dart';
import 'app_api_config.dart';
import 'retry_interceptor.dart';

/// Dio للباكند الخاص — يستخدم header `token` للزبون
final appApiDioProvider = Provider<Dio>((ref) {
  final authStorage = ref.watch(authStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppApiConfig.baseUrl,
      connectTimeout: AppApiConfig.connectTimeout,
      receiveTimeout: AppApiConfig.receiveTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(RetryInterceptor(dio: dio));
  dio.interceptors.add(
    _AppTokenInterceptor(authStorage: authStorage),
  );

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

class _AppTokenInterceptor extends Interceptor {
  _AppTokenInterceptor({required this.authStorage});

  final AuthStorage authStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = authStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['token'] = token;
    }
    handler.next(options);
  }
}
