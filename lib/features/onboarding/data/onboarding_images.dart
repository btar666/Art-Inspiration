import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد فك ترميز صور الـ Onboarding — بحجم العرض الفعلي فقط
abstract final class OnboardingImages {
  static const _aspectRatio = 4 / 3;
  static const _designWidth = 240.0;

  static int cacheWidth(BuildContext context) =>
      (_designWidth.w * MediaQuery.devicePixelRatioOf(context)).round();

  static int cacheHeight(BuildContext context) =>
      (_designWidth.w * _aspectRatio * MediaQuery.devicePixelRatioOf(context))
          .round();

  static ImageProvider provider(String asset, BuildContext context) {
    return ResizeImage(
      AssetImage(asset),
      width: cacheWidth(context),
      height: cacheHeight(context),
    );
  }

  static Future<void> precacheAll(BuildContext context, Iterable<String> assets) {
    return Future.wait(
      assets.map((asset) => precacheImage(provider(asset, context), context)),
    );
  }
}
