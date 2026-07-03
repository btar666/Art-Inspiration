import 'package:flutter/material.dart';

/// خط التطبيق — DIN Next LT Arabic
abstract final class AppFonts {
  static const String family = 'DINNextLTArabic';

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight bold = FontWeight.w700;

  /// يطابق الأوزان المتوفرة في الملفات (300 / 400 / 700)
  static FontWeight resolveWeight(FontWeight? weight) {
    final value = weight?.value ?? FontWeight.w400.value;
    if (value <= FontWeight.w300.value) return light;
    if (value <= FontWeight.w500.value) return regular;
    return bold;
  }

  static TextStyle base({FontWeight? fontWeight, Color? color}) => TextStyle(
        fontFamily: family,
        fontWeight: resolveWeight(fontWeight),
        color: color,
      );
}
