import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/floating_cart_route_rules.dart';
import '../../core/router/floating_cart_suppression.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/home/presentation/widgets/floating_cart_button.dart';

/// زر السلة العائم على مستوى التطبيق — يظهر عند وجود منتجات في السلة
class GlobalFloatingCartOverlay extends ConsumerWidget {
  const GlobalFloatingCartOverlay({
    super.key,
    required this.router,
    required this.location,
  });

  final GoRouter router;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authNotifierProvider).isLoggedIn;
    final itemCount = ref.watch(cartItemCountProvider);
    final suppressed = ref.watch(floatingCartSuppressedProvider);
    final visible = isLoggedIn &&
        itemCount > 0 &&
        !suppressed &&
        FloatingCartRouteRules.shouldShow(location);

    if (!visible) return const SizedBox.shrink();

    return DraggableFloatingCartButton(
      key: const ValueKey('global-floating-cart'),
      onTap: () => router.push(AppRoutes.cart),
      bottomReservedHeight:
          FloatingCartRouteRules.bottomReservedHeight(location),
    );
  }
}
