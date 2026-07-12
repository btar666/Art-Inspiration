import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// دايلوج رسائل المصادقة — تحقق أو خطأ API
class AuthMessageDialog extends StatelessWidget {
  const AuthMessageDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;

  static Future<void> showValidation(
    BuildContext context, {
    required List<String> issues,
  }) {
    if (issues.isEmpty) return Future.value();
    return show(
      context,
      title: 'تحقق من البيانات',
      message: issues.join('\n'),
      icon: Icons.edit_note_rounded,
      accentColor: AppColors.primary,
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String message,
    String title = 'تعذر المتابعة',
  }) {
    return show(
      context,
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      accentColor: AppColors.homeDiscount,
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color accentColor,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (dialogContext) => AuthMessageDialog(
        title: title,
        message: message,
        icon: icon,
        accentColor: accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(
            color: AppColors.orderCardBorder,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 22.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      accentColor.withValues(alpha: 0.14),
                      AppColors.primaryLight.withValues(alpha: 0.35),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: 30.sp,
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          duration: 320.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(duration: 260.ms),
                    SizedBox(height: 16.h),
                    Text(
                      title,
                      style: AppTextStyles.cartDialogTitle(color: accentColor)
                          .copyWith(fontSize: 18.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: AppColors.orderCardBorder),
                      ),
                      child: Text(
                        message,
                        style: AppTextStyles.cartDialogBody(
                          color: AppColors.textPrimary,
                        ).copyWith(height: 1.6, fontSize: 14.sp),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                        child: Text(
                          'حسناً',
                          style: AppTextStyles.cartDialogConfirm(
                            color: AppColors.background,
                          ).copyWith(fontSize: 15.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 220.ms)
        .scale(
          begin: const Offset(0.94, 0.94),
          end: const Offset(1, 1),
          duration: 280.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
