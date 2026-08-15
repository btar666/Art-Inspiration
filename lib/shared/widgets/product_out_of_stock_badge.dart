import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'glass_shimmer_sweep.dart';

/// تاك «غير متوفر» زجاجي على كارت/صورة المنتج
class ProductOutOfStockBadge extends StatelessWidget {
  const ProductOutOfStockBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 8.r : 10.r);
    final borderWidth = compact ? 1.0 : 1.2;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.homeDiscount.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 7.w : 10.w,
              vertical: compact ? 3.h : 5.h,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: AppColors.homeDiscount.withValues(alpha: 0.35),
                width: borderWidth,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFE0E0).withValues(alpha: 0.55),
                  AppColors.orderStatusCancelledBg.withValues(alpha: 0.62),
                  AppColors.homeDiscount.withValues(alpha: 0.38),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(
                  child: GlassShimmerSweep(highlightAlpha: 0.42),
                ),
                Text(
                  'غير متوفر',
                  style: AppTextStyles.homeProductCardOutOfStock(
                    fontSize: compact ? 10.sp : 11.94.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
