import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import 'home_scroll_metrics.dart';
import 'home_top_section.dart';

/// شريط الشعار الثابت بخلفية شفافة وتغويش — يختفي عند الوصول لقسم المنتجات
class HomeLogoHeaderOverlay extends StatelessWidget {
  const HomeLogoHeaderOverlay({
    super.key,
    required this.scrollOffset,
    this.onNotificationTap,
  });

  final double scrollOffset;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final barHeight = topInset + HomeScrollMetrics.logoBarHeight();
    final hideStart = HomeScrollMetrics.logoHideStartOffset();
    final hideRange = HomeScrollMetrics.logoHideAnimationRange();
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
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  height: barHeight,
                  padding: EdgeInsets.only(top: topInset),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.72),
                  ),
                  alignment: Alignment.center,
                  child: HomeLogoHeader(onNotificationTap: onNotificationTap),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
