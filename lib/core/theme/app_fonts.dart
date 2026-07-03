import 'package:flutter/material.dart';

/// خط التطبيق — DIN Next LT Arabic
abstract final class AppFonts {
  static const String family = 'DINNextLTArabic';

  static TextStyle base({FontWeight? fontWeight, Color? color}) => TextStyle(
        fontFamily: family,
        fontWeight: fontWeight,
        color: color,
      );
}
