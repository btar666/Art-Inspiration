import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد وتنسيق صفحة الإعدادات
abstract final class SettingsMetrics {
  static double cardRadius() => 16.r;
  static double profileCardRadius() => 18.r;

  /// عناصر القائمة — من التصميم (354×47.88)
  static double menuCardRadius() => 15.96.r;
  static double menuCardHeight() => 47.88.h;
  static EdgeInsets menuCardPadding() =>
      EdgeInsets.symmetric(horizontal: 15.96.w);

  static EdgeInsets cardPadding() =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h);

  static EdgeInsets profilePadding() =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h);

  static double profileAvatarSize() => 56.w;
  static double itemGap() => 10.h;
  static double sectionGap() => 20.h;
  static double sectionTitleGap() => 10.h;
  static double horizontalPadding() => 20.w;

  static double chevronSize() => 26.sp;
  static double itemIconSize() => 22.sp;

  static List<BoxShadow> cardShadow() => [
        BoxShadow(
          color: const Color(0xFF659AB9).withValues(alpha: 0.38),
          blurRadius: 3.76,
          spreadRadius: 0,
          offset: Offset.zero,
        ),
      ];
}
