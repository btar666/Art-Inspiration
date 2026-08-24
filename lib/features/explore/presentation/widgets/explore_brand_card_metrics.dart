import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// مقاييس كارد البراند — حسب Figma
abstract final class ExploreBrandCardMetrics {
  static const Color labelBackground = Color(0xFFE7E9F9);

  static double cardWidth() => 108.44.w;

  static double logoContainerHeight() => 97.49.h;

  static EdgeInsets logoPadding() =>
      EdgeInsets.symmetric(horizontal: 7.51.w, vertical: 8.45.h);

  static BorderRadius logoBorderRadius() => BorderRadius.only(
        topLeft: Radius.circular(20.65.r),
        topRight: Radius.circular(20.65.r),
      );

  static double gapHeight() => 6.5.h;

  static double labelContainerHeight() => 23.h;

  static BorderRadius labelBorderRadius() => BorderRadius.only(
        bottomLeft: Radius.circular(labelContainerHeight() / 2),
        bottomRight: Radius.circular(labelContainerHeight() / 2),
      );

  static double totalHeight() =>
      logoContainerHeight() + gapHeight() + labelContainerHeight();

  static double gridAspectRatio() => cardWidth() / totalHeight();

  static double chevronSize() => 18.w;

  static double chevronInset() => 3.w;

  static List<BoxShadow> logoCardShadow() => [
        BoxShadow(
          color: const Color(0xFF659AB9).withValues(alpha: 0.16),
          blurRadius: 3.r,
          offset: Offset(0, 1.h),
        ),
      ];

  static List<BoxShadow> labelCardShadow() => [
        BoxShadow(
          color: const Color(0xFF659AB9).withValues(alpha: 0.14),
          blurRadius: 3.r,
          offset: Offset(0, 1.h),
        ),
      ];
}
