import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';

/// نصوص الشعار تحت اللوغو (السبلاش فقط)
class AppLogoText extends StatelessWidget {
  const AppLogoText({super.key, this.animate = false});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppConstants.appName,
          style: AppTextStyles.splashTitle(),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),
        Text(
          AppConstants.appTagline,
          style: AppTextStyles.splashTagline(),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (!animate) return column;

    return column
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
