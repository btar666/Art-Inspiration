import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../home/presentation/widgets/main_bottom_nav.dart';
import '../../../../core/router/app_router.dart';

/// الهيكل الرئيسي مع شريط التنقل السفلي
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.child});

  final Widget child;

  int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.search)) return 0;
    if (location.startsWith(AppRoutes.explore)) return 1;
    if (location.startsWith(AppRoutes.home)) return 2;
    if (location.startsWith(AppRoutes.orders)) return 3;
    if (location.startsWith(AppRoutes.settings)) return 4;
    return 2;
  }

  void _onNavTap(BuildContext context, int index) {
    final route = switch (index) {
      0 => AppRoutes.search,
      1 => AppRoutes.explore,
      2 => AppRoutes.home,
      3 => AppRoutes.orders,
      4 => AppRoutes.settings,
      _ => AppRoutes.home,
    };
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: MainBottomNav(
          currentIndex: currentIndex,
          onTap: (index) => _onNavTap(context, index),
        ),
      ),
    );
  }
}
