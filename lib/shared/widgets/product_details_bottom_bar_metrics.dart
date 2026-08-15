import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

/// أبعاد ومظهر شريط أزرار صفحة تفاصيل المنتج العائم
abstract final class ProductDetailsBottomBarMetrics {
  static double horizontalMargin() => 20.w;
  static double bottomMargin() => 16.h;

  static double glassBlurSigma() => 52;
  static double glassBorderWidth() => 1.35;

  static LinearGradient frostFill() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          const Color(0xFFE8EBFF).withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.12),
        ],
      );

  static LinearGradient sapphireFill() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.26),
          const Color(0xFF8B97FF).withValues(alpha: 0.28),
          AppColors.primary.withValues(alpha: 0.22),
        ],
      );

  static Color frostHaze() => Colors.white.withValues(alpha: 0.18);

  static LinearGradient frostBorder() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.7),
          Colors.white.withValues(alpha: 0.28),
          AppColors.primary.withValues(alpha: 0.18),
        ],
      );

  static LinearGradient sapphireBorder() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.75),
          AppColors.primarySoft.withValues(alpha: 0.4),
          AppColors.primary.withValues(alpha: 0.28),
        ],
      );

  static List<BoxShadow> frostShadow({required bool pressed}) => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: pressed ? 0.06 : 0.12),
          blurRadius: pressed ? 18 : 36,
          spreadRadius: pressed ? 0 : 2,
          offset: Offset(0, pressed ? 4 : 8),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.55),
          blurRadius: 16,
          spreadRadius: -2,
          offset: const Offset(0, -1),
        ),
      ];

  static List<BoxShadow> sapphireShadow({required bool pressed}) => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: pressed ? 0.14 : 0.24),
          blurRadius: pressed ? 18 : 36,
          spreadRadius: pressed ? 0 : 2,
          offset: Offset(0, pressed ? 5 : 10),
        ),
        BoxShadow(
          color: const Color(0xFF9AABFF).withValues(alpha: 0.28),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.45),
          blurRadius: 12,
          offset: const Offset(0, -2),
        ),
      ];

  static double priceRowWidth() => 352.09.w;
  static double priceRowHeight() => 50.h;
  static EdgeInsets priceRowPadding() =>
      EdgeInsets.symmetric(horizontal: 12.w);

  static double gapBetweenRows() => 10.h;

  static double quantityButtonSize() => 32.w;
  static double quantityButtonIconSize() => 18.sp;
  static double quantityGap() => 10.w;
  static double quantityUnderlineWidth() => 16.w;
  static double quantityUnderlineHeight() => 2.h;
  static Color quantityUnderlineColor() => AppColors.primary;

  /// ارتفاع محجوز فوق الأزرار العائمة لزر السلة
  static const double floatingCartReservedHeight = 142;

  static double addToCartWidth() => 352.09.w;
  static double addToCartHeight() => 52.h;

  static double occupiedHeight() =>
      priceRowHeight() + gapBetweenRows() + addToCartHeight() + bottomMargin();
}
