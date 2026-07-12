import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_endpoints.dart';
import 'api_response_parser.dart';
import 'dio_client.dart';
import 'models/advanced_filter_models.dart';

final advancedFilterApiProvider = Provider<AdvancedFilterApi>((ref) {
  return AdvancedFilterApi(ref.watch(dioProvider));
});

/// خدمة advancedFilter — جلب البيانات من جداول ERP
class AdvancedFilterApi {
  AdvancedFilterApi(this._dio);

  final Dio _dio;

  Future<PaginatedResult<Map<String, dynamic>>> fetch({
    required AdvancedFilterRequest request,
  }) async {
    final response = await safeRequest(
      () => _dio.post<Map<String, dynamic>>(
        ApiEndpoints.advancedFilter,
        queryParameters: {'page': request.page},
        data: request.toJson(),
      ),
    );

    final body = response.data ?? const {};
    final items = ApiResponseParser.extractItems(body);

    var currentPage = _asInt(body['current_page'], request.page);
    var lastPage = _asInt(body['last_page'], 1);
    var total = _asInt(body['total'], items.length);

    // بعض الاستجابات القديمة تضع pagination داخل data كـ Map
    final dataNode = body['data'];
    if (dataNode is Map) {
      currentPage = _asInt(dataNode['current_page'], currentPage);
      lastPage = _asInt(dataNode['last_page'], lastPage);
      total = _asInt(dataNode['total'], total);
    }

    return PaginatedResult(
      items: items,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
    );
  }

  int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
