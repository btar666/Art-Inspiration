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
  // ValueNotifier وليس setState: setState هنا يعيد بناء HomeContent كاملاً —
  // أي كل شرائح الكتالوج — لمجرد إظهار زر صغير أثناء السكرول.
  final _showScrollToTop = ValueNotifier<bool>(false);

  // تُبنى مرة واحدة ولا يتغيّر وسيطها أبداً. لماذا حقول وليس داخل build:
  // أي إعادة بناء لـ HomePage — وقد رُصدت واحدة عند كل جلسة سكرول، من تغيّر
  // InheritedWidget فوق الصفحة (didChangeDependencies) — كانت تُنشئ HomeContent
  // جديداً، فيُعاد بناء كل شرائح الكتالوج. قياساً: إطار واحد بطول 130 مللي ثانية.
  // بتثبيت النسخة يرى فلاتر نفس الودجت فيتخطّى الشجرة كاملة.
  late final Widget _content = HomeContent(scrollController: _scrollController);
  late final Widget _header = HomeHeaderOverlay(
    scrollOffsetListenable: _scrollOffset,
    onNotificationTap: _openNotifications,
  );
  late final Widget _compactHeader = HomeCompactHeaderOverlay(
    scrollOffsetListenable: _scrollOffset,
    onNotificationTap: _openNotifications,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  /// ارتفاع الهيرو يعتمد على عرض الشاشة، فيُقرأ من الـ context لا ثابتاً
  double _hideStart() => HomeScrollMetrics.logoHideStartOffset(
        MediaQuery.paddingOf(context).top,
        MediaQuery.sizeOf(context),
      );

  void _onScroll() {
    final offset = _scrollController.offset;
    // ValueNotifier لا يُبلّغ إلا عند تغيّر القيمة فعلاً
    _showScrollToTop.value =
        offset > _hideStart() + 80;

    if ((offset - _scrollOffset.value).abs() < 3) return;

    final hideEnd = _hideStart() + HomeScrollMetrics.logoHideAnimationRange();

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
    _showScrollToTop.dispose();
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
            _content,
            _header,
            _compactHeader,
            ValueListenableBuilder<bool>(
              valueListenable: _showScrollToTop,
              builder: (context, visible, _) => ScrollToTopButton(
                visible: visible,
                onTap: _scrollToTop,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
