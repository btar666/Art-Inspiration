import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// مقاييس كارد القسم في تبويب الاقسام
abstract final class ExploreSectionCardMetrics {
  static double borderRadius() => 18.r;

  static EdgeInsets imagePadding() => EdgeInsets.fromLTRB(8.w, 10.h, 8.w, 4.h);

  static EdgeInsets labelPadding() =>
      EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 10.h);

  static double gridAspectRatio() => 0.82;

  static List<BoxShadow> cardShadow() => [
        BoxShadow(
          color: const Color(0xFF659AB9).withValues(alpha: 0.38),
          blurRadius: 3.75.r,
          offset: Offset(0, -1.h),
        ),
      ];
}
