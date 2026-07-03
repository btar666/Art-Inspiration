import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد معرض صور صفحة تفاصيل المنتج
abstract final class ProductDetailsGalleryMetrics {
  static double mainImageHeight() => 276.28.h;
  static double mainImageRadius() => 16.r;
  static double thumbnailHeight() => 63.1.h;
  static double thumbnailWidth() => 63.1.w;
  static double columnGap() => 10.w;

  static List<BoxShadow> mainImageShadow() => [
        BoxShadow(
          color: const Color(0xFF659AB9).withValues(alpha: 0.38),
          blurRadius: 3.76.r,
          spreadRadius: 0,
          offset: Offset.zero,
        ),
      ];

  /// المسافة بين الصور المصغّرة لملء ارتفاع الصورة الرئيسية بالكامل
  static double thumbnailGapForCount(int count) {
    if (count <= 1) return 0;
    final mainH = mainImageHeight();
    final thumbH = thumbnailHeight();
    return (mainH - count * thumbH) / (count - 1);
  }

  /// فجوة العرض الافتراضية (4 صور مرئية)
  static double thumbnailGap() => thumbnailGapForCount(4);
}
