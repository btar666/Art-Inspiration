import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/models/erp_price_policy.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// سياسة تسعير المستخدم الحالي — من أمان ERP (افتراضي: مفرق)
final userPricePolicyProvider = Provider<ErpPricePolicy>((ref) {
  final user = ref.watch(authNotifierProvider).user;
  return user?.pricePolicy ?? ErpPricePolicy.retail;
});
