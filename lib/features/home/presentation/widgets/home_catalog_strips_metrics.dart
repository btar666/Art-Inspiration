import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// مقاييس صفوف الفئات والبراندات في الرئيسية
abstract final class HomeCatalogStripsMetrics {
  static double titleTop() => 6.h;
  static double titleBottom() => 4.h;
  static double sectionsToBrandsGap() => 4.h;
  static double containerShadowBlur() => 4;
  static EdgeInsets listPadding() => EdgeInsets.fromLTRB(
        20.w,
        containerShadowBlur(),
        20.w,
        containerShadowBlur(),
      );
  static double itemGap() => 6.w;
  static double brandItemGap() => 6.w;

  static double categoryBoxSize() => 80.w;
  static double categoryRadius() => 12.r;
  static double categoryLabelGap() => 6.h;
  static double categoryLabelHeight() => 16.h;
  static double categoryListHeight() =>
      categoryBoxSize() +
      categoryLabelGap() +
      categoryLabelHeight() +
      containerShadowBlur() * 2;

  static Color categoryFill() => AppColors.background;

  static double brandWidth() => 124.w;
  static double brandHeight() => 58.h;
  static double brandRadius() => 14.r;
  static double brandListHeight() => brandHeight() + containerShadowBlur() * 2;

  static List<BoxShadow> containerShadow() => [
        BoxShadow(
          color: const Color(0xFF0000FF).withValues(alpha: 0.12),
          blurRadius: containerShadowBlur(),
          spreadRadius: 0,
          offset: Offset.zero,
        ),
      ];
}
