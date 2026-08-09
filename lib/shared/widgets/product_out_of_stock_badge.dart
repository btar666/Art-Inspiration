import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// تاك «غير متوفر» على كارت/صورة المنتج
class ProductOutOfStockBadge extends StatelessWidget {
  const ProductOutOfStockBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.w : 8.w,
        vertical: compact ? 3.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.orderStatusDeliveredBg,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        'غير متوفر',
        style: AppTextStyles.homeProductCardOutOfStock(
          fontSize: compact ? 10.sp : 11.94.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
