import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/data/products_repository.dart';
import '../../shared/widgets/product_details_widget.dart';
import '../router/app_router.dart';
import 'notification_payload.dart';
import 'push_notifications.dart';

/// يفتح صفحة المنتج عند الضغط على إشعار فيه item_id
class NotificationNavigationBinder extends ConsumerStatefulWidget {
  const NotificationNavigationBinder({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<NotificationNavigationBinder> createState() =>
      _NotificationNavigationBinderState();
}

class _NotificationNavigationBinderState
    extends ConsumerState<NotificationNavigationBinder> {
  @override
  void initState() {
    super.initState();
    PushNotifications.onNotificationTap = _onTap;
    widget.router.routerDelegate.addListener(_onRouteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryOpenPending();
    });
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    if (PushNotifications.onNotificationTap == _onTap) {
      PushNotifications.onNotificationTap = null;
    }
    super.dispose();
  }

  void _onRouteChanged() => _tryOpenPending();

  void _onTap(Map<String, dynamic> data) {
    final itemId = NotificationPayload.itemIdFrom(data);
    if (itemId != null) {
      PushNotifications.pendingProductId = itemId;
    }
    _tryOpenPending();
  }

  bool _canOpenProduct(String path) {
    return path != AppRoutes.splash &&
        path != AppRoutes.onboarding &&
        path != AppRoutes.login &&
        path != AppRoutes.register &&
        path != AppRoutes.requestSuccess;
  }

  Future<void> _tryOpenPending() async {
    final path = widget.router.state.uri.path;
    if (!_canOpenProduct(path)) return;

    final itemId = await PushNotifications.takePendingProductId();
    if (itemId == null) return;

    await openProductByItemId(
      ref: ref,
      itemId: itemId,
      router: widget.router,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> openProductByItemId({
  required WidgetRef ref,
  required String itemId,
  GoRouter? router,
  BuildContext? context,
}) async {
  final product =
      await ref.read(productsRepositoryProvider).fetchProductById(itemId);

  final GoRouter? goRouter = router ??
      (context != null ? GoRouter.maybeOf(context) : null) ??
      (rootNavigatorKey.currentContext != null
          ? GoRouter.maybeOf(rootNavigatorKey.currentContext!)
          : null);

  if (product == null) {
    final messengerContext = context ?? rootNavigatorKey.currentContext;
    if (messengerContext != null && messengerContext.mounted) {
      ScaffoldMessenger.of(messengerContext).showSnackBar(
        const SnackBar(content: Text('تعذر فتح المنتج')),
      );
    }
    return;
  }

  if (goRouter != null) {
    goRouter.push(
      AppRoutes.productDetailsPath(product.id),
      extra: product,
    );
    return;
  }

  if (context != null && context.mounted) {
    ProductDetailsWidget.open(context, product);
  }
}
