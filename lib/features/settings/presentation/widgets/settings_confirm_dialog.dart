import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// نوع حوار تأكيد الإعدادات
enum SettingsConfirmType {
  logout,
  deleteAccount,
}

/// حوار تأكيد تسجيل الخروج أو حذف الحساب — مطابق للتصميم
class SettingsConfirmDialog extends StatelessWidget {
  const SettingsConfirmDialog({
    super.key,
    required this.type,
  });

  final SettingsConfirmType type;

  static Future<bool> show(
    BuildContext context,
    SettingsConfirmType type,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => SettingsConfirmDialog(type: type),
    );
    return result ?? false;
  }

  String get _iconAsset => switch (type) {
        SettingsConfirmType.logout => AppAssets.settingsLogout,
        SettingsConfirmType.deleteAccount => AppAssets.settingsDeleteAccount,
      };

  Color get _accentColor => switch (type) {
        SettingsConfirmType.logout => AppColors.settingsLogout,
        SettingsConfirmType.deleteAccount => AppColors.settingsDanger,
      };

  String get _title => switch (type) {
        SettingsConfirmType.logout => 'تسجيل الخروج',
        SettingsConfirmType.deleteAccount => 'حذف الحساب',
      };

  String get _message => switch (type) {
        SettingsConfirmType.logout => 'لن تفقد بياناتك ، هل أنت متأكد ؟',
        SettingsConfirmType.deleteAccount =>
          'ستفقد كافة بياناتك ، هل أنت متأكد ؟',
      };

  String get _confirmLabel => switch (type) {
        SettingsConfirmType.logout => 'تسجيل الخروج',
        SettingsConfirmType.deleteAccount => 'حذف الحساب',
      };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                _iconAsset,
                width: 28.w,
                height: 28.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              _title,
              style: AppTextStyles.cartDialogTitle(color: _accentColor).copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              _message,
              style: AppTextStyles.cartDialogBody(
                color: AppColors.textSecondary,
              ).copyWith(
                fontSize: 14.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accentColor,
                      side: BorderSide(color: _accentColor, width: 1.2),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.cartDialogCancel(
                        color: _accentColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      _confirmLabel,
                      style: AppTextStyles.cartDialogConfirm(
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
