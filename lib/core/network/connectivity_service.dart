import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'api_config.dart';
import 'app_api_config.dart';

/// نتيجة فحص الاتصال
enum ConnectivityCheckResult {
  ok,
  noConnection,
}

/// فحص اتصال الجهاز والوصول للسيرفر
class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
    InternetConnectionChecker? connectionChecker,
    Dio? dio,
  })  : _connectivity = connectivity ?? Connectivity(),
        _connectionChecker =
            connectionChecker ?? InternetConnectionChecker.createInstance(),
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                headers: const {'Accept': 'application/json'},
              ),
            );

  static const connectionMessage = 'تحقق من اتصالك ب الانترنت';

  final Connectivity _connectivity;
  final InternetConnectionChecker _connectionChecker;
  final Dio _dio;

  Future<ConnectivityCheckResult> check() async {
    final hasDeviceLink = await _hasDeviceConnectivity();
    if (hasDeviceLink == false) {
      return ConnectivityCheckResult.noConnection;
    }

    final hasInternet = await _hasInternetAccess();
    if (hasInternet == false) {
      return ConnectivityCheckResult.noConnection;
    }

    final serverOk = await _pingBackends();
    return serverOk
        ? ConnectivityCheckResult.ok
        : ConnectivityCheckResult.noConnection;
  }

  /// `null` = تعذّر الفحص (مثلاً MissingPluginException) — نتابع للخطوة التالية
  Future<bool?> _hasDeviceConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.isEmpty ||
          results.every((result) => result == ConnectivityResult.none)) {
        return false;
      }
      return true;
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool?> _hasInternetAccess() async {
    try {
      return await _connectionChecker.hasConnection;
    } on MissingPluginException {
      return null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isAppReachable() async {
    final result = await check();
    return result == ConnectivityCheckResult.ok;
  }

  Future<bool> _pingBackends() async {
    const endpoints = [
      ApiConfig.baseUrl,
      AppApiConfig.baseUrl,
    ];

    for (final endpoint in endpoints) {
      if (await _probeEndpoint(endpoint)) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _probeEndpoint(String url) async {
    try {
      final response = await _dio.head(
        url,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          followRedirects: true,
        ),
      );
      return response.statusCode != null;
    } on DioException {
      try {
        final response = await _dio.get(
          url,
          options: Options(
            validateStatus: (status) => status != null && status < 500,
            followRedirects: true,
          ),
        );
        return response.statusCode != null;
      } catch (_) {
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// ينتظر اتصالاً صالحاً — يعرض دايلوج إعادة المحاولة عند الفشل
Future<bool> ensureAppConnectivity(
  WidgetRef ref,
  Future<bool> Function() showRetryDialog,
) async {
  while (true) {
    if (await ref.read(connectivityServiceProvider).isAppReachable()) {
      return true;
    }

    final retry = await showRetryDialog();
    if (!retry) return false;
  }
}
