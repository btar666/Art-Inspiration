import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response_parser.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/erp_dev_config.dart';
import 'models/auth_models.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(baseDioProvider));
});

/// مصادقة التطبيق فوق أمان ERP.
///
/// الكتالوج والفواتير تعمل بمفتاح API ثابت (حسب دليل أمان ERP).
/// شاشة Login تربط ملف المستخدم المحلي بنفس المفتاح.
class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  Dio get _authedDio {
    _dio.options.headers['Authorization'] = 'Bearer ${ApiConfig.apiToken}';
    return _dio;
  }

  Future<AuthSession> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    final normalizedEmail = email?.trim().toLowerCase() ?? '';

    // حساب لوحة أمان ERP
    if (normalizedEmail == ErpDevConfig.email.toLowerCase()) {
      if (password != ErpDevConfig.password) {
        throw const ApiException(
          message: 'بيانات الدخول غير صحيحة — تحقق من البريد وكلمة المرور',
          statusCode: 401,
          type: ApiExceptionType.unauthorized,
        );
      }
      return _sessionFromMe();
    }

    if (password.trim().isEmpty) {
      throw const ApiException(message: 'أدخل كلمة المرور');
    }

    // زبون التطبيق — ننشئ/نعيد جلسة محلية مع مفتاح المتجر
    final name = normalizedEmail.isNotEmpty
        ? normalizedEmail.split('@').first
        : (phone ?? 'عميل');

    return AuthSession(
      tokens: const AuthTokens(accessToken: ApiConfig.apiToken),
      user: AuthUser(
        id: phone?.replaceAll(RegExp(r'\D'), '') ??
            normalizedEmail.hashCode.abs().toString(),
        name: name,
        email: normalizedEmail.isEmpty ? null : normalizedEmail,
        phone: phone,
      ),
    );
  }

  Future<AuthSession> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String shopName,
    required String governorate,
  }) async {
    final fullName = '$firstName $lastName'.trim();
    final address = [shopName, governorate]
        .where((e) => e.trim().isNotEmpty)
        .join(' — ');

    try {
      final response = await safeRequest(
        () => _authedDio.post<Map<String, dynamic>>(
          ApiEndpoints.customers,
          data: {
            'name': fullName.isEmpty ? email : fullName,
            'phone': phone,
            'email': email,
            'address': address,
            'tax_number': '',
            'opening_balance': 0,
            'credit_limit': 0,
            'price_policy': 'retail',
            'is_active': true,
            'notes': 'Art Inspiration App',
          },
        ),
      );

      final root = ApiResponseParser.asMap(response.data);
      final data = root['data'];
      final map = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      return AuthSession(
        tokens: const AuthTokens(accessToken: ApiConfig.apiToken),
        user: AuthUser(
          id: (map['id'] ?? phone).toString(),
          name: (map['name'] ?? fullName).toString(),
          email: (map['email'] ?? email).toString(),
          phone: (map['phone'] ?? phone).toString(),
        ),
      );
    } on ApiException {
      // إن فشل إنشاء العميل نكمل بجلسة محلية
      return AuthSession(
        tokens: const AuthTokens(accessToken: ApiConfig.apiToken),
        user: AuthUser(
          id: phone.replaceAll(RegExp(r'\D'), ''),
          name: fullName.isEmpty ? email : fullName,
          email: email,
          phone: phone,
        ),
      );
    }
  }

  Future<AuthTokens> refreshToken(String token) async {
    // مفتاح أمان ERP لا ينتهي حسب الدليل
    if (token.startsWith('amanerp_') || ApiConfig.apiToken.isNotEmpty) {
      return const AuthTokens(accessToken: ApiConfig.apiToken);
    }
    throw const ApiException(message: 'فشل تجديد الجلسة');
  }

  Future<AuthSession> _sessionFromMe() async {
    final response = await safeRequest(
      () => _authedDio.get<Map<String, dynamic>>(ApiEndpoints.me),
    );
    final root = ApiResponseParser.asMap(response.data);
    final data = root['data'];
    AuthUser? user;
    if (data is Map && data['user'] is Map) {
      user = AuthUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    }

    return AuthSession(
      tokens: const AuthTokens(accessToken: ApiConfig.apiToken),
      user: user ??
          const AuthUser(
            id: ErpDevConfig.userId,
            name: ErpDevConfig.userName,
            email: ErpDevConfig.userEmail,
          ),
    );
  }
}
