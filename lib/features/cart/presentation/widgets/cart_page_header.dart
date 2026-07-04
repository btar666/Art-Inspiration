import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// رأس صفحة السلة — رجوع + عنوان + حذف الكل
class CartPageHeader extends StatelessWidget {
  const CartPageHeader({
    super.key,
    required this.onBack,
    this.onClearAll,
    this.showClearAll = false,
  });

  final VoidCallback onBack;
  final VoidCallback? onClearAll;
  final bool showClearAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          _BackButton(onTap: onBack),
          Expanded(
            child: Text(
              'السلة',
              style: AppTextStyles.ordersPageTitle(),
              textAlign: TextAlign.center,
            ),
          ),
          if (showClearAll)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClearAll,
                borderRadius: BorderRadius.circular(20.r),
                child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.homeDiscount,
                    size: 26.sp,
                  ),
                ),
              ),
            )
          else
            SizedBox(width: 40.w),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.background,
          size: 24.sp,
        ),
      ),
    );
  }
}
