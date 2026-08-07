import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/pinned_blur_gradient_background.dart';
import 'home_scroll_metrics.dart';
import 'home_top_section.dart';

/// شريط الشعار الثابت بتغويش متدرج — يختفي عند الوصول لقسم المنتجات
class HomeLogoHeaderOverlay extends StatelessWidget {
  const HomeLogoHeaderOverlay({
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
          child: IgnorePointer(
            ignoring: opacity < 0.1,
            child: Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, -12.h * hideProgress),
                child: ClipRect(
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: PinnedBlurGradientBackground(
                          fadeStops: PinnedBlurHeaderStyle.homeFadeStops,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: topInset),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 8.h, 0, 8.h),
                          child: HomeLogoHeader(
                            onNotificationTap: onNotificationTap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
