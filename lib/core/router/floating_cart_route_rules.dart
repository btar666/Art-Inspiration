import '../../features/home/presentation/widgets/main_bottom_nav.dart';
import '../../shared/widgets/product_details_bottom_bar_metrics.dart';
import 'app_router.dart';

/// قواعد إظهار زر السلة العائم حسب المسار الحالي
abstract final class FloatingCartRouteRules {
  static const _hiddenPrefixes = [
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.requestSuccess,
  ];

  static bool shouldShow(String location) {
    if (_isHiddenRoute(location)) return false;
    if (location == AppRoutes.cart) return false;
    if (location.startsWith('/checkout')) return false;
    return true;
  }

  static bool _isHiddenRoute(String location) {
    for (final route in _hiddenPrefixes) {
      if (location == route) return true;
    }
    return false;
  }

  static double bottomReservedHeight(String location) {
    if (_isShellTabRoute(location)) {
      return MainBottomNavMetrics.floatingBarReservedHeight;
    }
    if (location.startsWith('/product/')) {
      return ProductDetailsBottomBarMetrics.floatingCartReservedHeight;
    }
    return 24;
  }

  static bool _isShellTabRoute(String location) {
    return location == AppRoutes.home ||
        location == AppRoutes.search ||
        location == AppRoutes.explore ||
        location == AppRoutes.orders ||
        location == AppRoutes.settings;
  }
}
