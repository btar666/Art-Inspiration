import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_exception.dart';
import 'models/aman_paginated_result.dart';

/// موفّر قديم — أمان ERP يستخدم [amanRestApiProvider].
@Deprecated('استخدم amanRestApiProvider')
final advancedFilterApiProvider = Provider<AdvancedFilterApi>((ref) {
  return const AdvancedFilterApi();
});

/// طبقة توافق مؤقتة — Dan advancedFilter لم يعد مستخدماً مع أمان ERP.
@Deprecated('استخدم AmanRestApi')
class AdvancedFilterApi {
  const AdvancedFilterApi();

  Future<AmanPaginatedResult<Map<String, dynamic>>> fetch({
    required Object request,
  }) async {
    throw const ApiException(
      message: 'تم الانتقال إلى أمان ERP — استخدم AmanRestApi',
    );
  }
}
