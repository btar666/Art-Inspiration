import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

/// أزرار موحدة قابلة لإعادة الاستخدام
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = switch (variant) {
      AppButtonVariant.primary =>
        _PrimaryButton(label: label, onPressed: onPressed, expanded: expanded),
      AppButtonVariant.secondary => _SecondaryButton(
          label: label,
          onPressed: onPressed,
        ),
    };

    if (expanded) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}

enum AppButtonVariant { primary, secondary }

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.expanded,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(28.r),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28.r),
        child: Container(
          width: expanded ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 16.h),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.skipButtonBg,
      borderRadius: BorderRadius.circular(28.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
