import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد ذيل وخلفية صفحة تفاصيل المنتج
abstract final class ProductDetailsBottomBarMetrics {
  static const Color pageBackground = Color(0xFFEAECFC);
  static const Color background = pageBackground;

  static const double whiteContainerHeightFraction = 0.80;
  static double whiteContainerBottomRadius() => 50.r;

  static EdgeInsets padding() => EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 4.h);

  static double priceRowWidth() => 352.09.w;
  static double priceRowHeight() => 51.87.h;
  static double priceRowRadius() => 20.95.r;
  static Color priceRowBackground() =>
      const Color(0xFFFFFFFF).withValues(alpha: 0.3);
  static Color priceRowBorderColor() =>
      const Color(0xFF0000FF).withValues(alpha: 0.5);
  static double priceRowBorderWidth() => 0.5;
  static double priceRowBlurSigma() => 10;
  static EdgeInsets priceRowPadding() =>
      EdgeInsets.symmetric(horizontal: 14.w);

  static double gapBetweenRows() => 7.98.h;

  static double quantityButtonWidth() => 27.86.w;
  static double quantityButtonHeight() => 24.58.h;
  static double quantityButtonRadius() => 10.r;
  static double quantityButtonIconSize() => 18.sp;
  static double quantityButtonBorderWidth() => 2;
  static Color quantityButtonBorderColor() => const Color(0xFFFFFFFF);
  static double quantityGap() => 12.w;
  static double quantityUnderlineWidth() => 14.w;
  static double quantityUnderlineHeight() => 1.2.h;
  static Color quantityUnderlineColor() => const Color(0xFFFFFFFF);

  static double addToCartWidth() => 352.09.w;
  static double addToCartHeight() => 51.87.h;
  static double addToCartRadius() => 20.95.r;
  static Color addToCartBackground() => const Color(0xFFFFFFFF);
}
