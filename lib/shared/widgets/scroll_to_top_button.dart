import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../features/home/presentation/widgets/main_bottom_nav.dart';

/// زر الصعود لأعلى الصفحة — نفس طابع زر السلة العائم
class ScrollToTopButton extends StatelessWidget {
  const ScrollToTopButton({
    super.key,
    required this.visible,
    required this.onTap,
  });

  final bool visible;
  final VoidCallback onTap;

  static double get size => 50.w;

  static double bottomOffset(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return padding.bottom +
        MainBottomNavMetrics.floatingBarReservedHeight.h +
        12.h;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20.w,
      bottom: bottomOffset(context),
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AnimatedScale(
            scale: visible ? 1 : 0.85,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: ColoredBox(
                      color: Colors.white.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 28.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
