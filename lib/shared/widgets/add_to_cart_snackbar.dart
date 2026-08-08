import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/home/presentation/widgets/main_bottom_nav.dart';

/// عرض رسالة إضافة منتج للسلة بتصميم عائم
void showAddToCartSnackBar(BuildContext context, String productName) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(
          16.w,
          0,
          16.w,
          MainBottomNavMetrics.floatingBarReservedHeight.h + 8.h,
        ),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 2),
        content: AddToCartSnackBarContent(productName: productName),
      ),
    );
}

/// محتوى سناك بار إضافة المنتج للسلة
class AddToCartSnackBarContent extends StatelessWidget {
  const AddToCartSnackBarContent({
    super.key,
    required this.productName,
  });

  final String productName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.orderCardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تمت الإضافة إلى السلة',
                  style: AppTextStyles.authField(
                    color: AppColors.textPrimary,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  productName,
                  style: AppTextStyles.authField(
                    color: AppColors.textSecondary,
                  ).copyWith(fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.primary.withValues(alpha: 0.45),
            size: 22.sp,
          ),
        ],
      ),
    );
  }
}
