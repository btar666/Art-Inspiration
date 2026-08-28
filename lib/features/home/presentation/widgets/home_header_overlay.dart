import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import 'home_scroll_metrics.dart';
import 'home_top_section.dart';

/// هيدر البحث الثابت فوق السلايدر — يختفي عند الوصول لقسم المنتجات
class HomeHeaderOverlay extends StatelessWidget {
  const HomeHeaderOverlay({
    super.key,
    required this.scrollOffsetListenable,
    this.onNotificationTap,
  });

  final ValueListenable<double> scrollOffsetListenable;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final hideStart = HomeScrollMetrics.logoHideStartOffset(
      topInset,
      MediaQuery.sizeOf(context),
    );
    final hideRange = HomeScrollMetrics.logoHideAnimationRange();
    final headerHeight =
        topInset + HomeScrollMetrics.headerRowHeight() + 36.h;

    return ValueListenableBuilder<double>(
      valueListenable: scrollOffsetListenable,
      // يُبنى مرة واحدة: التغويش وشريط البحث لا يتغيّران مع السكرول — تتغيّر
      // شفافيتهما وموضعهما فقط. بدون هذا الـ child كان الهيدر كاملاً يُعاد
      // بناؤه مع كل إشعار سكرول، بما فيه شريط البحث وأنيميشن التلميح.
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // لا شريط ملوّن فوق البانر (طلب المالك). يبقى ظل رقيق بعلو شريط
            // الحالة وحده، لأن ساعة النظام بيضاء وتختفي فوق البانرات الفاتحة.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.32),
                        Colors.black.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: topInset,
              left: 0,
              right: 0,
              child: HomeSearchBar(
                onSearchTap: () => context.go(AppRoutes.search),
                onScannerTap: () => context.push(AppRoutes.barcodeScanner),
                onNotificationTap: onNotificationTap,
              ),
            ),
          ],
        ),
      ),
      builder: (context, scrollOffset, child) {
        final hideProgress =
            ((scrollOffset - hideStart) / hideRange).clamp(0.0, 1.0);
        final opacity = 1.0 - hideProgress;

        if (opacity <= 0) return const SizedBox.shrink();

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight,
          child: IgnorePointer(
            ignoring: opacity < 0.1,
            child: Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, -12.h * hideProgress),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
