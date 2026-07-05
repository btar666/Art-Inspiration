import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

/// مقاييس زر الرجوع الموحّد
abstract final class AppBackButtonMetrics {
  static double size() => 30.w;

  static double iconSize() => 17.sp;
}

/// زر الرجوع الدائري الموحّد في التطبيق
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppBackButtonMetrics.size(),
        height: 30.h,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.background,
          size: AppBackButtonMetrics.iconSize(),
        ),
      ),
    );
  }
}
