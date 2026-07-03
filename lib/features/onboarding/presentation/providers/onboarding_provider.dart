import 'package:flutter_riverpod/flutter_riverpod.dart';

/// مزود حالة صفحة الـ Onboarding الحالية
final onboardingPageIndexProvider = StateProvider<int>((ref) => 0);

final isLastOnboardingPageProvider = Provider<bool>((ref) {
  final index = ref.watch(onboardingPageIndexProvider);
  return index >= 2;
});
