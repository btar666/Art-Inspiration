import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/checkout/presentation/pages/checkout_review_page.dart';
import '../../features/checkout/presentation/pages/checkout_success_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/request_success_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/explore/presentation/pages/explore_section_page.dart';
import '../../features/home/data/models/product_model.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/search/data/models/search_filter_state.dart';
import '../../features/search/presentation/pages/search_filter_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/settings/presentation/pages/about_us_page.dart';
import '../../features/settings/presentation/pages/contact_us_page.dart';
import '../../features/settings/presentation/pages/help_page.dart';
import '../../features/settings/presentation/pages/saved_addresses_page.dart';
import '../../features/settings/presentation/pages/select_address_for_order_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../shared/widgets/product_details_widget.dart';

/// مسارات التطبيق
abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const requestSuccess = '/request-success';
  static const home = '/home';
  static const productDetails = '/product/:id';
  static const search = '/search';
  static const explore = '/explore';
  static const orders = '/orders';
  static const settings = '/settings';
  static const settingsAbout = '/settings/about';
  static const settingsContact = '/settings/contact';
  static const settingsHelp = '/settings/help';
  static const settingsAddresses = '/settings/addresses';
  static const favorites = '/favorites';
  static const orderDetails = '/orders/:id';
  static const exploreSection = '/explore/sections/:sectionId';
  static const notifications = '/notifications';
  static const searchFilter = '/search/filter';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const checkoutReview = '/checkout/review';
  static const checkoutSuccess = '/checkout/success/:orderId';
  static const checkoutSelectAddress = '/checkout/select-address';
  static const orderTracking = '/checkout/tracking/:orderId';

  static String checkoutSuccessPath(String orderId) =>
      '/checkout/success/$orderId';
  static String orderTrackingPath(String orderId) =>
      '/checkout/tracking/$orderId';

  static String productDetailsPath(String id) => '/product/$id';
  static String orderDetailsPath(String id) => '/orders/$id';
  static String exploreSectionPath(String sectionId) =>
      '/explore/sections/$sectionId';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

/// إعداد GoRouter
GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashPage(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.requestSuccess,
        name: 'request-success',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RequestSuccessPage(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.orderDetails,
        name: 'order-details',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: OrderDetailsPage(orderId: id),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.exploreSection,
        name: 'explore-section',
        pageBuilder: (context, state) {
          final sectionId = state.pathParameters['sectionId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ExploreSectionPage(sectionId: sectionId),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.notifications,
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationsPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.productDetails,
        name: 'product-details',
        pageBuilder: (context, state) {
          final product = state.extra! as ProductModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailsWidget(product: product),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.searchFilter,
        name: 'search-filter',
        pageBuilder: (context, state) {
          final filter = state.extra as SearchFilterState? ??
              const SearchFilterState();
          return CustomTransitionPage(
            key: state.pageKey,
            child: SearchFilterPage(initialFilter: filter),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.cart,
        name: 'cart',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CartPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.checkout,
        name: 'checkout',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CheckoutPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.checkoutReview,
        name: 'checkout-review',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CheckoutReviewPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.checkoutSuccess,
        name: 'checkout-success',
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CheckoutSuccessPage(orderId: orderId),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.checkoutSelectAddress,
        name: 'checkout-select-address',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SelectAddressForOrderPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      // تتبع الطلب معلّق مؤقتاً — أي دخول يُحوَّل لصفحة الطلبات
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.orderTracking,
        name: 'order-tracking',
        redirect: (context, state) => AppRoutes.orders,
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.favorites,
        name: 'favorites',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FavoritesPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.settingsAbout,
        name: 'settings-about',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AboutUsPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.settingsContact,
        name: 'settings-contact',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ContactUsPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.settingsHelp,
        name: 'settings-help',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HelpPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.settingsAddresses,
        name: 'settings-addresses',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SavedAddressesPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomePage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SearchPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.explore,
            name: 'explore',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ExplorePage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.orders,
            name: 'orders',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const OrdersPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final offset = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

  return SlideTransition(
    position: offset,
    child: FadeTransition(opacity: animation, child: child),
  );
}
