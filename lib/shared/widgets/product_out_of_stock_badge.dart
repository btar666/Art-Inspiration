import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'glass_shimmer_sweep.dart';

/// تاك «نافذ» زجاجي على كارت/صورة المنتج
///
/// [compact] للقوائم: بدون blur/shimmer لتفادي تعليق السكرول.
class ProductOutOfStockBadge extends StatelessWidget {
  const ProductOutOfStockBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 8.r : 10.r);
    final borderWidth = compact ? 1.0 : 1.2;
    final label = Text(
      'نافذ',
      style: AppTextStyles.homeProductCardOutOfStock(
        fontSize: compact ? 10.sp : 11.94.sp,
      ),
      textAlign: TextAlign.center,
    );

    if (compact) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: AppColors.orderStatusCancelledBg.withValues(alpha: 0.92),
          border: Border.all(
            color: AppColors.homeDiscount.withValues(alpha: 0.4),
            width: borderWidth,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
          child: label,
        ),
      );
    }

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
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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
                Transform.translate(
                  offset: Offset(0, -2.h),
                  child: label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
