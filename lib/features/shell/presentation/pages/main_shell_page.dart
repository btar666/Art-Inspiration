import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../home/presentation/widgets/main_bottom_nav.dart';
import '../../../../core/router/app_router.dart';

/// الهيكل الرئيسي مع شريط التنقل السفلي
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key, required this.child});

  final Widget child;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _navShrink;
  late final Animation<double> _navT;
  int? _lastTabIndex;
  double _scrollAccum = 0;

  @override
  void initState() {
    super.initState();
    _navShrink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      reverseDuration: const Duration(milliseconds: 420),
    );
    _navT = CurvedAnimation(
      parent: _navShrink,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeOutBack,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final index = _indexFromLocation(GoRouterState.of(context).uri.path);
    if (_lastTabIndex != null && _lastTabIndex != index) {
      _scrollAccum = 0;
      _setCompact(false);
    }
    _lastTabIndex = index;
  }

  @override
  void dispose() {
    _navShrink.dispose();
    super.dispose();
  }

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

  void _setCompact(bool compact) {
    if (compact) {
      if (_navShrink.status != AnimationStatus.forward &&
          _navShrink.status != AnimationStatus.completed) {
        _navShrink.forward();
      }
    } else if (_navShrink.status != AnimationStatus.reverse &&
        _navShrink.status != AnimationStatus.dismissed) {
      _navShrink.reverse();
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification.metrics.pixels <= 2) {
      _scrollAccum = 0;
      _setCompact(false);
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta == 0) return false;

      if (delta > 0) {
        _scrollAccum = _scrollAccum < 0 ? 0 : _scrollAccum;
        _scrollAccum += delta;
        if (_scrollAccum >= MainBottomNavMetrics.compactAfterPx()) {
          _setCompact(true);
        }
      } else {
        _scrollAccum = _scrollAccum > 0 ? 0 : _scrollAccum;
        _scrollAccum += delta;
        if (_scrollAccum <= -MainBottomNavMetrics.expandAfterPx()) {
          _setCompact(false);
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _indexFromLocation(location);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.child,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MainBottomNavMetrics.bottomMargin() + bottomInset,
            child: Center(
              child: AnimatedBuilder(
                animation: _navT,
                builder: (context, child) {
                  final t = _navT.value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(
                      0,
                      lerpDouble(0, MainBottomNavMetrics.compactDy(), t)!,
                    ),
                    child: Transform.scale(
                      alignment: Alignment.bottomCenter,
                      scale: lerpDouble(
                        1,
                        MainBottomNavMetrics.compactScale(),
                        t,
                      ),
                      child: child,
                    ),
                  );
                },
                child: MainBottomNav(
                  currentIndex: currentIndex,
                  onTap: (index) => _onNavTap(context, index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
