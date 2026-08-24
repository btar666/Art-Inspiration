import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';

/// نصوص الشعار تحت اللوغو (السبلاش فقط) — صورة بدل النص
class AppLogoText extends StatelessWidget {
  const AppLogoText({super.key, this.animate = false});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    final brand = Image.asset(
      AppAssets.splashBrandText,
      width: 240.w,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      alignment: Alignment.topCenter,
    );

    if (!animate) return brand;

    return brand
        .animate()
        .fadeIn(duration: 600.ms, delay: 350.ms)
        .scale(
          begin: const Offset(0.2, 0.2),
          end: const Offset(1, 1),
          duration: 900.ms,
          delay: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
