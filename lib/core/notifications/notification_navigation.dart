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
    if (itemId == null) return;
    PushNotifications.pendingProductId = itemId;
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

    final itemId = PushNotifications.takePendingProductId();
    if (itemId == null) return;

    await openProductByItemId(context, ref, itemId);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> openProductByItemId(
  BuildContext context,
  WidgetRef ref,
  String itemId,
) async {
  final product =
      await ref.read(productsRepositoryProvider).fetchProductById(itemId);
  if (!context.mounted) return;

  if (product == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تعذر فتح المنتج')),
    );
    return;
  }

  ProductDetailsWidget.open(context, product);
}
