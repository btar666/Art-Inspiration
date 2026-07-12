import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response_parser.dart';
import '../../../core/network/dio_client.dart';

final createInvoiceApiProvider = Provider<CreateInvoiceApi>((ref) {
  return CreateInvoiceApi(ref.watch(dioProvider));
});

/// إنشاء فاتورة مبيعات عبر POST /api/v1/invoices
class CreateInvoiceApi {
  CreateInvoiceApi(this._dio);

  final Dio _dio;

  Future<CreatedInvoiceResult> create(Map<String, dynamic> body) async {
    final response = await safeRequest(
      () => _dio.post<Map<String, dynamic>>(
        ApiEndpoints.createInvoice,
        data: body,
      ),
    );

    final root = ApiResponseParser.asMap(response.data);
    final dataNode = root['data'];
    final data = dataNode is Map
        ? Map<String, dynamic>.from(dataNode)
        : root;

    final id = (data['id'] ?? root['id'] ?? '').toString();
    final elementNumber = (data['elementNumber'] ??
            root['elementNumber'] ??
            body['elementNumber'] ??
            '')
        .toString();

    if (id.isEmpty && elementNumber.isEmpty) {
      throw ApiException(
        message: ApiResponseParser.messageFrom(
          root,
          fallback: 'فشل إنشاء الفاتورة',
        ),
      );
    }

    return CreatedInvoiceResult(
      id: id.isNotEmpty ? id : elementNumber,
      elementNumber: elementNumber,
      raw: data,
    );
  }
}

class CreatedInvoiceResult {
  const CreatedInvoiceResult({
    required this.id,
    required this.elementNumber,
    required this.raw,
  });

  final String id;
  final String elementNumber;
  final Map<String, dynamic> raw;
}
