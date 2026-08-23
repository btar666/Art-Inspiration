import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد كارت المنتج الثابتة — مطابقة لتصميم Figma
abstract final class HomeProductCardMetrics {
  static double width() => 169.12.w;

  /// مرتبط بالعرض ليتوافق مع ارتفاع خلية الشبكة (aspect ratio)
  static double height() => width() / aspectRatio();

  static double radius() => 15.92.r;

  static EdgeInsets padding() =>
      EdgeInsets.fromLTRB(4.97.w, 0, 5.97.w, 4.97.h);

  static double gap() => 9.95.h;

  static double imageToNameGap() => 9.w;

  static double nameToCategoryGap() => 4.h;

  static double categoryToDescriptionGap() => 3.h;

  static double descriptionToPriceGap() => 12.h;

  static double aspectRatio() {
    // الصورة مربّعة داخل الـ padding؛ نزيد ارتفاع الكارت بنفس الزيادة
    const designWidth = 169.12;
    const oldDesignHeight = 277.56;
    const oldImageHeight = 127.0;
    const imageHorizontalPad = 10.0;
    final squareImageHeight = designWidth - imageHorizontalPad;
    final newDesignHeight =
        oldDesignHeight - oldImageHeight + squareImageHeight;
    return designWidth / newDesignHeight;
  }

  static const Color shadowColor = Color(0xFF659AB9);

  static double shadowBlur() => 3.98.r;

  /// ارتفاع صورة المنتج — مربّع بعرض المساحة داخل الـ padding
  static double imageHeight() =>
      width() - imagePadding().left - imagePadding().right;

  static EdgeInsets imagePadding() =>
      EdgeInsets.only(top: 5.w, left: 5.w, right: 5.w);

  static double priceBarHeight() => 33.h;

  static double priceBarRadius() => 10.r;

  static double priceBarLeftRadius() => 16.r;

  static double cartButtonSize() => priceBarHeight();

  static double cartIconSize() => 22.w;

  static EdgeInsets priceBarMargin() =>
      EdgeInsets.symmetric(horizontal: 8.w);

  static Color priceBarBackground() => Colors.black.withValues(alpha: 0.1);

  static Color accentBlue50() => const Color(0xFF0000FF).withValues(alpha: 0.5);

  static double favoriteWidth() => 24.w;

  static double favoriteHeight() => 22.w;

  static double favoriteRadius() => 6.r;

  static double favoriteIconSize() => 15.sp;

  static double discountWidth() => 34.w;

  static double discountHeight() => 17.w;

  static double discountRadius() => 4.r;

  static Color discountBackground() => const Color(0xFFF45C43);

  static Color favoriteHeartColor() =>
      const Color(0xFF0000FF).withValues(alpha: 0.4);
}
