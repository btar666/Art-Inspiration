import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// مقاييس صفحة السلة — نفس آلية صفحة تفاصيل الطلب
abstract final class CartPageMetrics {
  static const Color pageBackground = Color(0xFFEAECFC);

  static const double footerHeightFraction = 0.10;

  static double whiteContainerBottomRadius() => 44.r;

  static Offset footerButtonOffset() => Offset(0, 6.h);

  static EdgeInsets footerPadding() =>
      EdgeInsets.fromLTRB(24.w, 0, 24.w, 10.h);
}
