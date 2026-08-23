import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// نوع حوار تأكيد السلة
enum CartConfirmType {
  clearCart,
  removeItem,
  outOfStockCheckout,
}

/// حوار تأكيد أفرغ السلة أو حذف منتج — مطابق للتصميم
class CartConfirmDialog extends StatelessWidget {
  const CartConfirmDialog({
    super.key,
    required this.type,
  });

  final CartConfirmType type;

  static Future<bool> show(
    BuildContext context,
    CartConfirmType type,
  ) async {
    if (type == CartConfirmType.outOfStockCheckout) {
      await showOutOfStockCheckoutWarning(context);
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => CartConfirmDialog(type: type),
    );
    return result ?? false;
  }

  /// تحذير: منتجات نافذة تمنع إكمال الشراء
  static Future<void> showOutOfStockCheckoutWarning(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const CartConfirmDialog(
        type: CartConfirmType.outOfStockCheckout,
      ),
    );
  }

  static const _accentColor = AppColors.homeDiscount;

  String get _title => switch (type) {
        CartConfirmType.clearCart => 'أفرغ السلة',
        CartConfirmType.removeItem => 'حذف المنتج من السلة',
        CartConfirmType.outOfStockCheckout => 'لا يمكن إكمال الشراء',
      };

  String get _body => switch (type) {
        CartConfirmType.clearCart => 'هل أنت متأكد ؟',
        CartConfirmType.removeItem => 'هل أنت متأكد ؟',
        CartConfirmType.outOfStockCheckout =>
          'يوجد منتجات نافذة في السلة. يرجى حذفها قبل إكمال الشراء.',
      };

  String get _confirmLabel => switch (type) {
        CartConfirmType.clearCart => 'أفرغ السلة',
        CartConfirmType.removeItem => 'حذف المنتج',
        CartConfirmType.outOfStockCheckout => 'حسناً',
      };

  bool get _isWarningOnly => type == CartConfirmType.outOfStockCheckout;

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
              child: _isWarningOnly
                  ? Icon(
                      Icons.inventory_2_outlined,
                      size: 28.sp,
                      color: _accentColor,
                    )
                  : Image.asset(
                      AppAssets.settingsDeleteAccount,
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
              _body,
              style: AppTextStyles.cartDialogBody(
                color: AppColors.textSecondary,
              ).copyWith(
                fontSize: 14.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            if (_isWarningOnly)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
              )
            else
              Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accentColor,
                      side: const BorderSide(color: _accentColor, width: 1.2),
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
