import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/pinned_blur_gradient_background.dart';
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
    final hideStart = HomeScrollMetrics.logoHideStartOffset();
    final hideRange = HomeScrollMetrics.logoHideAnimationRange();
    final headerHeight =
        topInset + HomeScrollMetrics.headerRowHeight() + 36.h;

    return ValueListenableBuilder<double>(
      valueListenable: scrollOffsetListenable,
      builder: (context, scrollOffset, _) {
        final hideProgress =
            ((scrollOffset - hideStart) / hideRange).clamp(0.0, 1.0);
        final opacity = 1.0 - hideProgress;

        if (opacity <= 0) return const SizedBox.shrink();

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, -12.h * hideProgress),
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: PinnedBlurGradientBackground(
                          fadeStops: PinnedBlurHeaderStyle.homeFadeStops,
                          strongBlurSigma:
                              PinnedBlurHeaderStyle.exploreStrongBlurSigma,
                          mediumBlurSigma:
                              PinnedBlurHeaderStyle.exploreMediumBlurSigma,
                          lightBlurSigma:
                              PinnedBlurHeaderStyle.exploreLightBlurSigma,
                          strongBlurMaskEnd:
                              PinnedBlurHeaderStyle.exploreStrongBlurMaskEnd,
                        ),
                      ),
                    ),
                    Positioned(
                      top: topInset,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: opacity < 0.1,
                        child: HomeSearchBar(
                          onSearchTap: () => context.go(AppRoutes.search),
                          onScannerTap: () =>
                              context.push(AppRoutes.barcodeScanner),
                          onNotificationTap: onNotificationTap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
