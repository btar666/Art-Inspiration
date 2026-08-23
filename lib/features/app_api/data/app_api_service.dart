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
        .where((item) => item.mediaUrl.isNotEmpty)
        .toList();
  }

  /// معرفات الأقسام المميزة في الرئيسية — من art-inspiration.com
  Future<List<int>> fetchFeaturedCategoryIds() async {
    return _fetchFeaturedIds(AppApiEndpoints.categories);
  }

  /// معرفات البراندات المميزة في الرئيسية — من art-inspiration.com
  Future<List<int>> fetchFeaturedBrandIds() async {
    return _fetchFeaturedIds(AppApiEndpoints.brands);
  }

  Future<List<int>> _fetchFeaturedIds(String path) async {
    final response = await safeRequest(
      () => _dio.get<Map<String, dynamic>>(path),
    );
    final root = ApiResponseParser.asMap(response.data);
    final data = root['data'];
    if (data is! List) return const [];

    final ids = <int>[];
    for (final item in data) {
      final id = _asFeaturedId(item);
      if (id != null) ids.add(id);
    }
    return ids;
  }

  int? _asFeaturedId(dynamic item) {
    if (item is int) return item;
    if (item is num) return item.toInt();
    if (item is String) return int.tryParse(item.trim());
    if (item is Map) {
      final raw = item['id'] ?? item['erp_id'] ?? item['category_id'] ??
          item['brand_id'];
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      if (raw is String) return int.tryParse(raw.trim());
    }
    return null;
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
    this.itemId,
    this.productName,
    this.productImageUrl,
  });

  final String id;
  final String title;
  final String body;
  final DateTime? createdAt;
  final String? itemId;
  final String? productName;
  final String? productImageUrl;

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'إشعار').toString(),
      body: (json['body'] ?? json['message'] ?? json['description'] ?? '')
          .toString(),
      createdAt: _parseCreatedAt(
        json['created_at'] ?? json['createdAt'] ?? json['date'],
      ),
      itemId: _parseItemId(json['item_id'] ?? json['itemId']),
      productName: _nonEmpty(json['product_name'] ?? json['productName']),
      productImageUrl: _nonEmpty(
        json['product_image'] ?? json['productImage'],
      ),
    );
  }

  static String? _parseItemId(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text == '0' || text == 'null') return null;
    return text;
  }

  static String? _nonEmpty(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text == '#' || text == 'null') return null;
    return text;
  }

  /// يحوّل وقت السيرفر (غالباً UTC بدون Z) إلى التوقيت المحلي
  static DateTime? _parseCreatedAt(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;

    if (parsed.isUtc) return parsed.toLocal();

    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    ).toLocal();
  }
}
