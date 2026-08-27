import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_api_service.dart';
import '../../models/app_info_model.dart';
import '../../models/return_policy_item.dart';
import '../../models/slider_item_model.dart';

/// سلايدر الرئيسية
final sliderProvider = FutureProvider<List<SliderItemModel>>((ref) async {
  return ref.watch(appApiServiceProvider).fetchSlider();
});

/// معلومات التواصل / من نحن
final appInfoProvider = FutureProvider<AppInfoModel>((ref) async {
  return ref.watch(appApiServiceProvider).fetchInfo();
});

/// سياسة الخصوصية — من api/privacy_policy
final privacyPolicyProvider =
    FutureProvider<List<ReturnPolicyItem>>((ref) async {
  return ref.watch(appApiServiceProvider).fetchPrivacyPolicy();
});

/// سياسات الاستبدال والاسترجاع والضمان — من api/return_policy
final returnPoliciesProvider =
    FutureProvider<List<ReturnPolicyItem>>((ref) async {
  return ref.watch(appApiServiceProvider).fetchReturnPolicies();
});
