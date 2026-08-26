import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// مزود SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

/// خدمة تخزين حالة الـ Onboarding
class OnboardingStorage {
  OnboardingStorage(this._prefs);

  final SharedPreferences _prefs;

  bool get isCompleted =>
      _prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;

  Future<void> markCompleted() async {
    await _prefs.setBool(AppConstants.onboardingCompletedKey, true);
  }

  Future<void> reset() => _prefs.remove(AppConstants.onboardingCompletedKey);
}

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return OnboardingStorage(ref.watch(sharedPreferencesProvider));
});
