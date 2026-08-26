import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_compact_header_overlay.dart';
import '../widgets/home_content.dart';
import '../widgets/home_header_overlay.dart';
import '../widgets/home_scroll_metrics.dart';
import '../../../../shared/widgets/scroll_to_top_button.dart';

/// الصفحة الرئيسية
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();
  final _scrollOffset = ValueNotifier<double>(0);
  bool _headerFullyHidden = false;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final shouldShow =
        offset > HomeScrollMetrics.logoHideStartOffset() + 80;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }

    if ((offset - _scrollOffset.value).abs() < 3) return;

    final hideEnd = HomeScrollMetrics.logoHideStartOffset() +
        HomeScrollMetrics.logoHideAnimationRange();

    // بعد اختفاء الهيدر بالكامل لا نحدّث الـ overlay أثناء السكرول السريع
    if (offset >= hideEnd) {
      if (!_headerFullyHidden) {
        _headerFullyHidden = true;
        _scrollOffset.value = hideEnd;
      }
      return;
    }

    _headerFullyHidden = false;
    _scrollOffset.value = offset;
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  void _openNotifications() => context.push(AppRoutes.notifications);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            HomeContent(scrollController: _scrollController),
            HomeHeaderOverlay(
              scrollOffsetListenable: _scrollOffset,
              onNotificationTap: _openNotifications,
            ),
            HomeCompactHeaderOverlay(
              scrollOffsetListenable: _scrollOffset,
              onNotificationTap: _openNotifications,
            ),
            ScrollToTopButton(
              visible: _showScrollToTop,
              onTap: _scrollToTop,
            ),
          ],
        ),
      ),
    );
  }
}
