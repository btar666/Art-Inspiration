import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/pinned_blur_gradient_background.dart';
import 'home_scroll_metrics.dart';
import 'home_top_section.dart';

/// شريط الشعار + خلفية blur للهيدر — يختفي عند الوصول لقسم المنتجات
class HomeLogoHeaderOverlay extends StatelessWidget {
  const HomeLogoHeaderOverlay({
    super.key,
    required this.scrollOffsetListenable,
    this.onNotificationTap,
  });

  final ValueListenable<double> scrollOffsetListenable;
  final VoidCallback? onNotificationTap;

  double _headerBlurHeight(double topInset) =>
      topInset +
      HomeScrollMetrics.logoBarHeight() +
      HomeScrollMetrics.searchBlockHeight();

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final hideStart = HomeScrollMetrics.logoHideStartOffset();
    final hideRange = HomeScrollMetrics.logoHideAnimationRange();
    final headerBlurHeight = _headerBlurHeight(topInset);

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
          height: headerBlurHeight,
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
                          fadeStops: PinnedBlurHeaderStyle.exploreFadeStops,
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
                      top: 0,
                      left: 0,
                      right: 0,
                      height: topInset + HomeScrollMetrics.logoBarHeight(),
                      child: IgnorePointer(
                        ignoring: opacity < 0.1,
                        child: Padding(
                          padding: EdgeInsets.only(top: topInset),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 8.h, 0, 8.h),
                            child: HomeLogoHeader(
                              onNotificationTap: onNotificationTap,
                            ),
                          ),
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
