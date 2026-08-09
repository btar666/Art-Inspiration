import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

/// شريط سفلي ثابت لصفحات الإعدادات
class SettingsBottomBar extends StatelessWidget {
  const SettingsBottomBar({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.orderCardShadow,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: AppButton(
        label: label,
        onPressed: onTap,
        expanded: true,
      ),
    );
  }
}

/// حالة فارغة لصفحات الإعدادات
class SettingsEmptyState extends StatelessWidget {
  const SettingsEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.imageAsset,
  });

  final String title;
  final IconData? icon;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                width: 280.w,
                fit: BoxFit.contain,
              )
            else
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.info_outline_rounded,
                  color: AppColors.productStore,
                  size: 36.sp,
                ),
              ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: AppTextStyles.settingsMenuItem(
                color: AppColors.textSecondary,
              ).copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
