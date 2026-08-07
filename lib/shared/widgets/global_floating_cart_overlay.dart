import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/floating_cart_route_rules.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/home/presentation/widgets/floating_cart_button.dart';

/// زر السلة العائم على مستوى التطبيق — يظهر عند وجود منتجات في السلة
class GlobalFloatingCartOverlay extends ConsumerWidget {
  const GlobalFloatingCartOverlay({
    super.key,
    required this.location,
  });

  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(cartItemCountProvider);
    final visible =
        itemCount > 0 && FloatingCartRouteRules.shouldShow(location);

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !visible,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (visible)
              DraggableFloatingCartButton(
                key: const ValueKey('global-floating-cart'),
                onTap: () => context.push(AppRoutes.cart),
                bottomReservedHeight:
                    FloatingCartRouteRules.bottomReservedHeight(location),
              ),
          ],
        ),
      ),
    );
  }
}
