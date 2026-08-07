import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/floating_cart_button.dart';
import '../widgets/home_content.dart';
import '../widgets/home_logo_header_overlay.dart';
import '../widgets/home_scroll_metrics.dart';
import '../widgets/main_bottom_nav.dart';

/// الصفحة الرئيسية
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();
  final _scrollOffset = ValueNotifier<double>(0);
  bool _logoFullyHidden = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if ((offset - _scrollOffset.value).abs() < 1) return;

    final hideEnd = HomeScrollMetrics.logoHideStartOffset() +
        HomeScrollMetrics.logoHideAnimationRange();

    // بعد اختفاء الشعار بالكامل لا نحدّث الـ overlay أثناء السكرول السريع
    if (offset >= hideEnd) {
      if (!_logoFullyHidden) {
        _logoFullyHidden = true;
        _scrollOffset.value = hideEnd;
      }
      return;
    }

    _logoFullyHidden = false;
    _scrollOffset.value = offset;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          HomeContent(scrollController: _scrollController),
          HomeLogoHeaderOverlay(
            scrollOffsetListenable: _scrollOffset,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
          DraggableFloatingCartButton(
            onTap: () => context.push(AppRoutes.cart),
            bottomReservedHeight: MainBottomNavMetrics.floatingBarReservedHeight,
          ),
        ],
      ),
    );
  }
}
