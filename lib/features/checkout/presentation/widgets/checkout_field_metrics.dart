import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// مقاييس حقول صفحة طلب المنتج
abstract final class CheckoutFieldMetrics {
  static double fieldHeight() => 57.h;

  static double borderRadius() => 18.r;

  static Color addAddressLinkColor() =>
      const Color(0xFF0000FF).withValues(alpha: 0.5);
}
