import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

/// أبعاد شريط صفحة تفاصيل المنتج
abstract final class ProductDetailsAppBarMetrics {
  static double favoriteWidth() => 33.82.w;
  static double favoriteHeight() => 29.85.h;
  static double favoriteRadius() => 9.95.r;
  static double favoriteIconSize() => 18.sp;

  static List<BoxShadow> favoriteShadow() => [
        BoxShadow(
          color: const Color(0xFF659AB9).withValues(alpha: 0.38),
          blurRadius: 3.76.r,
          spreadRadius: 0,
          offset: Offset.zero,
        ),
      ];

  static Color favoriteIconColor() => AppColors.homeHeart;
}
