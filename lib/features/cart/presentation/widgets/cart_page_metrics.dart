import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// مقاييس صفحة السلة — نفس آلية صفحة تفاصيل الطلب
abstract final class CartPageMetrics {
  static const Color pageBackground = Color(0xFFEAECFC);

  static double footerHeight() => 50.h;

  static double whiteContainerBottomRadius() => 44.r;

  static EdgeInsets footerPadding() =>
      EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 8.h);
}
