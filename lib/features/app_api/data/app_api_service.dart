import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response_parser.dart';
import '../../../core/network/app_api_client.dart';
import '../../../core/network/app_api_config.dart';
import '../../../core/network/app_api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/data/models/auth_models.dart';
import '../models/app_info_model.dart';
import '../models/slider_item_model.dart';

final appApiServiceProvider = Provider<AppApiService>((ref) {
  return AppApiService(ref.watch(appApiDioProvider));
});

/// خدمة الباكند الخاص — art-inspiration.com
class AppApiService {
  AppApiService(this._dio);

  final Dio _dio;

  Future<List<SliderItemModel>> fetchSlider() async {
    final response = await safeRequest(
      () => _dio.get<Map<String, dynamic>>(AppApiEndpoints.slider),
    );
    final root = ApiResponseParser.asMap(response.data);
    final data = root['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map((item) => SliderItemModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.imageUrl.isNotEmpty)
        .toList();
  }

  Future<AuthSession> login({
    required String phone,
    required String password,
  }) async {
    final response = await safeRequest(
      () => _dio.get<Map<String, dynamic>>(
        AppApiEndpoints.customerLogin,
        queryParameters: {
          'phone': phone.trim(),
          'password': password,
        },
      ),
    );

    return _parseCustomerAuth(response.data);
  }

  Future<AuthSession> register({
    required String name,
    required String phone,
    required String password,
    required String city,
    required String cosmeticName,
  }) async {
    final form = FormData.fromMap({
      'name': name.trim(),
      'phone': phone.trim(),
      'password': password,
      'city': city.trim(),
      'cosmetic_name': cosmeticName.trim(),
    });

    final response = await safeRequest(
      () => _dio.post<Map<String, dynamic>>(
        AppApiEndpoints.customerAdd,
        data: form,
      ),
    );

    try {
      return _parseCustomerAuth(response.data);
    } on ApiException {
      // بعض الاستجابات لا ترجع token — نسجّل الدخول مباشرة
      return login(phone: phone, password: password);
    }
  }

  Future<AuthUser> fetchMyAccount() async {
    final response = await safeRequest(
      () => _dio.get<Map<String, dynamic>>(AppApiEndpoints.myAccount),
    );
    final root = ApiResponseParser.asMap(response.data);
    final data = root['data'];
    if (data is! Map) {
      throw const ApiException(message: 'تعذر جلب بيانات الحساب');
    }
    return AuthUser.fromJson(Map<String, dynamic>.from(data));
  }

  Future<AuthUser> editAccount({
    required String name,
    required String phone,
    required String password,
    required String city,
    required String cosmeticName,
  }) async {
    final form = FormData.fromMap({
      'name': name.trim(),
      'phone': phone.trim(),
      'password': password,
      'city': city.trim(),
      'cosmetic_name': cosmeticName.trim(),
    });

    final response = await safeRequest(
      () => _dio.post<Map<String, dynamic>>(
        AppApiEndpoints.customerEdit,
        data: form,
      ),
    );

    final root = ApiResponseParser.asMap(response.data);
    final data = root['data'];
    if (data is Map) {
      return AuthUser.fromJson(Map<String, dynamic>.from(data));
    }

    return fetchMyAccount();
  }

  Future<List<AppNotificationItem>> fetchNotifications({
    int itemsPerPage = 20,
  }) async {
    final response = await safeRequest(
      () => _dio.get<Map<String, dynamic>>(
        AppApiEndpoints.notifications,
        queryParameters: {
          'lang': AppApiConfig.lang,
          'itemsPerPage': itemsPerPage,
        },
      ),
    );

    final root = ApiResponseParser.asMap(response.data);
    final data = root['data'];
    if (data is Map) {
      final items = data['data'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map(
              (item) => AppNotificationItem.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
    }

    return const [];
  }

  Future<AppInfoModel> fetchInfo() async {
    final response = await safeRequest(
      () => _dio.get<Map<String, dynamic>>(
        AppApiEndpoints.info,
        queryParameters: {'lang': AppApiConfig.lang},
      ),
    );
    return AppInfoModel.fromJson(ApiResponseParser.asMap(response.data));
  }

  Future<String> fetchPrivacyPolicy() async {
    final response = await safeRequest(
      () => _dio.get<Map<String, dynamic>>(
        AppApiEndpoints.privacyPolicy,
        queryParameters: {'lang': AppApiConfig.lang},
      ),
    );
    final root = ApiResponseParser.asMap(response.data);
    final data = root['data'];
    if (data is String) return data;
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) {
        return (first['content'] ?? first['text'] ?? first['body'] ?? '')
            .toString();
      }
      return first.toString();
    }
    return '';
  }

  Future<void> deleteAccount() async {
    await safeRequest(
      () => _dio.get<Map<String, dynamic>>(AppApiEndpoints.deleteAccount),
    );
  }

  AuthSession _parseCustomerAuth(Map<String, dynamic>? data) {
    final root = ApiResponseParser.asMap(data);
    final status = root['status'];
    final error = root['error']?.toString();

    if (status == 401 || (error != null && error.isNotEmpty)) {
      throw ApiException(
        message: error ?? 'بيانات الدخول غير صحيحة',
        statusCode: 401,
        type: ApiExceptionType.unauthorized,
      );
    }

    final userNode = root['data'];
    if (userNode is! Map) {
      throw ApiException(
        message: ApiResponseParser.messageFrom(root, fallback: 'فشل العملية'),
      );
    }

    final userMap = Map<String, dynamic>.from(userNode);
    final token = (userMap['token'] ?? '').toString();
    if (token.isEmpty) {
      throw const ApiException(message: 'لم يُرجع الخادم توكن صالح');
    }

    return AuthSession(
      tokens: AuthTokens(accessToken: token),
      user: AuthUser.fromJson(userMap),
    );
  }
}

/// عنصر إشعار من الباكند
class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime? createdAt;

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'إشعار').toString(),
      body: (json['body'] ?? json['message'] ?? json['description'] ?? '')
          .toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
