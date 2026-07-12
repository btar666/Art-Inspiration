import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response_parser.dart';
import '../../../core/network/dio_client.dart';
import 'models/auth_models.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(baseDioProvider));
});

/// خدمة المصادقة — login / register / refreshToken
class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  Future<AuthSession> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    final body = <String, dynamic>{
      'password': password,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };

    final response = await safeRequest(
      () => _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: body,
      ),
    );

    return _parseAuthResponse(response.data);
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
    final now = DateTime.now().toUtc().toIso8601String();
    final elementNumber = phone.replaceAll(RegExp(r'\D'), '');

    final main = {
      'password': password,
      'confirmPassword': password,
      'name': firstName,
      'type': 'individual',
      'elementNumber': elementNumber,
      'company': shopName,
      'email': email,
      'phone': phone,
      'city': governorate,
      'country': 'Iraq',
      'notes': 'Art Inspiration App customer',
    };

    final body = {
      'role': 'customer',
      'invoiceID': '',
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'status': 'Active',
      'meta': jsonEncode({
        'data': [
          {
            'createdAt': now,
            'invoiceID': 'CUS-$elementNumber',
            'name': 'OpeningBalance',
            'totalAmount': 0,
            'elementNumber': elementNumber,
          }
        ],
      }),
      'main': jsonEncode(main),
      'issueDate': now,
      'createdAt': now,
      'updatedAt': now,
      'elementNumber': elementNumber,
      'name': '$firstName $lastName'.trim(),
    };

    final response = await safeRequest(
      () => _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: body,
      ),
    );

    return _parseAuthResponse(response.data);
  }

  Future<AuthTokens> refreshToken(String token) async {
    final response = await safeRequest(
      () => _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'token': token},
      ),
    );

    final root = ApiResponseParser.asMap(response.data);
    final tokens = AuthTokens.fromJson(root);
    if (tokens.accessToken.isEmpty) {
      throw const ApiException(message: 'فشل تجديد الجلسة');
    }
    return tokens;
  }

  AuthSession _parseAuthResponse(Map<String, dynamic>? data) {
    final root = ApiResponseParser.asMap(data);
    final tokens = AuthTokens.fromJson(root);

    if (tokens.accessToken.isEmpty) {
      final nested = root['data'];
      if (nested is Map) {
        final nestedTokens =
            AuthTokens.fromJson(Map<String, dynamic>.from(nested));
        if (nestedTokens.accessToken.isNotEmpty) {
          return AuthSession(
            tokens: nestedTokens,
            user: _extractUser(root, nested),
          );
        }
      }
      throw ApiException(
        message:
            ApiResponseParser.messageFrom(root, fallback: 'فشل تسجيل الدخول'),
      );
    }

    return AuthSession(
      tokens: tokens,
      user: _extractUser(root, root['data']),
    );
  }

  AuthUser? _extractUser(Map<String, dynamic> root, dynamic node) {
    if (root['user'] is Map) {
      return AuthUser.fromJson(Map<String, dynamic>.from(root['user'] as Map));
    }
    if (node is Map) {
      return AuthUser.fromJson(Map<String, dynamic>.from(node));
    }
    return null;
  }
}
