import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// مقاييس صفحة العناوين المحفوظة
abstract final class SavedAddressesPageMetrics {
  static const Color pageBackground = Color(0xFFEAECFC);

  static const double footerHeightFraction = 0.10;

  static double whiteContainerBottomRadius() => 44.r;

  static Offset footerButtonOffset() => Offset(0, 6.h);

  static EdgeInsets footerPadding() =>
      EdgeInsets.fromLTRB(24.w, 0, 24.w, 10.h);

  static EdgeInsets listPadding() =>
      EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h);

  static double locationIconSize() => 48.w;

  static double locationIconRadius() => 12.r;

  static double actionButtonSize() => 36.w;

  static double actionButtonRadius() => 10.r;

  static Color locationIconBackground() => const Color(0xFFF4F6FA);

  static Color editButtonBackground() => const Color(0xFFFFF5D6);

  static Color deleteButtonBackground() => const Color(0xFFFFE8E8);
}
