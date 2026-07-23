/// ثوابت التطبيق العامة
abstract final class AppConstants {
  static const String appName = 'ART INSPIRATION';
  static const String appTagline = 'FOR GENERAL TRADING COSMETICS';

  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String cartItemsKey = 'cart_items';
  static const String favoritesKey = 'favorites';
  static const String savedAddressesKey = 'saved_addresses';
  static const String localOrdersKey = 'local_orders';
  static const String authAccessTokenKey = 'auth_access_token';
  static const String authRefreshTokenKey = 'auth_refresh_token';
  static const String authUserKey = 'auth_user';
  static const String catalogOfflineCacheKey = 'catalog_offline_cache';
  static const int catalogOfflineCacheVersion = 6;

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
