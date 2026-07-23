import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_endpoints.dart';
import 'api_response_parser.dart';
import 'dio_client.dart';
import 'models/aman_paginated_result.dart';

final amanRestApiProvider = Provider<AmanRestApi>((ref) {
  return AmanRestApi(ref.watch(dioProvider));
});

/// عميل REST لأمان ERP وفق دليل الاستخدام
class AmanRestApi {
  AmanRestApi(this._dio);

  final Dio _dio;

  Future<AmanPaginatedResult<Map<String, dynamic>>> list({
    required String path,
    int page = 1,
    int perPage = 50,
    Map<String, dynamic>? query,
  }) async {
    final response = await safeRequest(
      () => _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          ...?query,
        },
      ),
    );

    final root = ApiResponseParser.asMap(response.data);
    final items = ApiResponseParser.extractItems(root);
    final meta = root['meta'];
    final metaMap = meta is Map ? Map<String, dynamic>.from(meta) : const {};

    return AmanPaginatedResult(
      items: items,
      currentPage: _asInt(metaMap['current_page'], page),
      lastPage: _asInt(metaMap['last_page'], 1),
      total: _asInt(metaMap['total'], items.length),
      perPage: _asInt(metaMap['per_page'], perPage),
    );
  }

  Future<Map<String, dynamic>> getById(String path) async {
    final response = await safeRequest(
      () => _dio.get<Map<String, dynamic>>(path),
    );
    final root = ApiResponseParser.asMap(response.data);
    final data = root['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return root;
  }

  Future<Map<String, dynamic>> create({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final response = await safeRequest(
      () => _dio.post<Map<String, dynamic>>(path, data: body),
    );
    final root = ApiResponseParser.asMap(response.data);
    final data = root['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return root;
  }

  Future<Map<String, dynamic>> me() => getById(ApiEndpoints.me);

  int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
