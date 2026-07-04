import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';

/// شريط سفلي لصفحات الشراء
class CheckoutBottomBar extends StatelessWidget {
  const CheckoutBottomBar({
    super.key,
    required this.label,
    required this.onTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  final String label;
  final VoidCallback onTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.orderDetailsFooter,
        boxShadow: [
          BoxShadow(
            color: AppColors.orderCardShadow,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: secondaryLabel == null
          ? Material(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(28.r),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(28.r),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: secondaryLabel!,
                    onPressed: onSecondaryTap,
                    variant: AppButtonVariant.secondary,
                    expanded: true,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AppButton(
                    label: label,
                    onPressed: onTap,
                    expanded: true,
                  ),
                ),
              ],
            ),
    );
  }
}
