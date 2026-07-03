/// ثوابت التطبيق العامة
abstract final class AppConstants {
  static const String appName = 'ART INSPIRATION';
  static const String appTagline = 'FOR GENERAL TRADING COSMETICS';

  static const String onboardingCompletedKey = 'onboarding_completed';

  /// عرض Onboarding في كل مرة — غيّرها إلى false لاحقاً لإخفائها
  static const bool alwaysShowOnboarding = true;

  /// تأخير قصير بعد انتهاء دوران اللوغو قبل الانتقال
  static const Duration splashPostRotationDelay = Duration(milliseconds: 500);

  /// مدة دوران اللوغو في السبلاش
  static const Duration splashLogoRotationDuration = Duration(milliseconds: 900);

  /// حجم التصميم المرجعي (iPhone 14 Pro)
  static const double designWidth = 393;
  static const double designHeight = 852;
}
