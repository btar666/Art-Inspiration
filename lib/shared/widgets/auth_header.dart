import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_text_styles.dart';
import 'app_animated_logo.dart';
import 'decorative_dot_grid.dart';
import 'sparkle_icon.dart';

/// رأس موحد لصفحات تسجيل الدخول وإنشاء الحساب
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.animate = true,
    this.errorTick = 0,
  });

  final String title;
  final String subtitle;
  final bool animate;
  final int errorTick;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        SizedBox(height: 8.h),
        AppAnimatedLogo(
          size: 64,
          errorTick: errorTick,
        ),
        SizedBox(height: 20.h),
        Text(
          title,
          style: AppTextStyles.authTitle(),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            subtitle,
            style: AppTextStyles.authSubtitle(),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    if (!animate) return content;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -20.h,
          right: -10.w,
          child: SparkleIcon(size: 14.w, delay: 200.ms),
        ),
        Positioned(
          top: 30.h,
          left: -20.w,
          child: SparkleIcon(size: 12.w, filled: false, delay: 400.ms),
        ),
        content
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
      ],
    );
  }
}

/// خلفية صفحات المصادقة مع نقاط زخرفية
class AuthPageBackground extends StatelessWidget {
  const AuthPageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecorativeDotGrid(
          alignment: Alignment.topRight,
          rows: 3,
          columns: 5,
          padding: EdgeInsets.only(top: 56, right: 24),
        ),
        const DecorativeDotGrid(
          alignment: Alignment.centerLeft,
          rows: 4,
          columns: 3,
          padding: EdgeInsets.only(left: 16),
        ),
        child,
      ],
    );
  }
}
