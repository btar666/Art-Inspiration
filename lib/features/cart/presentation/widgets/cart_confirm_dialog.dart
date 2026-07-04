import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// حوار تأكيد حذف — منتج أو إفراغ السلة
class CartConfirmDialog extends StatelessWidget {
  const CartConfirmDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
  });

  final String title;
  final String confirmLabel;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) => CartConfirmDialog(
        title: title,
        confirmLabel: confirmLabel,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 36.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.homeDiscount.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.homeDiscount,
                size: 26.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: AppTextStyles.cartDialogTitle(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'هل أنت متأكد ؟',
              style: AppTextStyles.cartDialogBody(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.homeDiscount,
                      side: const BorderSide(
                        color: AppColors.homeDiscount,
                        width: 1.2,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.cartDialogCancel(),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.homeDiscount,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: AppTextStyles.cartDialogConfirm(),
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
