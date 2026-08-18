/// ثوابت التطبيق العامة
abstract final class AppConstants {
  static const String appName = 'ART INSPIRATION';
  static const String appTagline = 'FOR GENERAL TRADING COSMETICS';

  static const String onboardingCompletedKey = 'onboarding_completed_v1';
  static const String cartItemsKey = 'cart_items';
  static const String favoritesKey = 'favorites';
  static const String savedAddressesKey = 'saved_addresses';
  static const String localOrdersKey = 'local_orders';
  static const String authAccessTokenKey = 'auth_access_token';
  static const String authRefreshTokenKey = 'auth_refresh_token';
  static const String authUserKey = 'auth_user';
  static const String catalogOfflineCacheKey = 'catalog_offline_cache';
  static const String taxonomyCacheKey = 'catalog_taxonomy_cache';
  static const String orderImageCacheKey = 'order_preview_image_cache';
  static const String pendingNotificationProductIdKey =
      'pending_product_id_from_notification';
  static const String pendingNotificationProductAtKey =
      'pending_product_id_from_notification_at';
  static const String searchHistoryKey = 'search_history';
  static const int maxSearchHistoryItems = 5;
  static const int catalogOfflineCacheVersion = 9;
  static const int taxonomyCacheVersion = 2;
  static const int orderImageCacheVersion = 1;

  /// للتجربة فقط: إجبار ظهور الـ Onboarding في كل تشغيل
  static const bool alwaysShowOnboarding = false;

  /// تأخير قصير بعد انتهاء دوران اللوغو قبل الانتقال
  static const Duration splashPostRotationDelay = Duration(milliseconds: 500);

  /// مدة دوران اللوغو في السبلاش
  static const Duration splashLogoRotationDuration = Duration(milliseconds: 900);

  /// حجم التصميم المرجعي (iPhone 14 Pro)
  static const double designWidth = 393;
  static const double designHeight = 852;
}
