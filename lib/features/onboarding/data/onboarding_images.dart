import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// تحميل مسبق لصور الـ Onboarding (SVG)
abstract final class OnboardingImages {
  static Future<void> precacheAll(
    BuildContext context,
    Iterable<String> assets,
  ) {
    return Future.wait(
      assets.map((asset) async {
        final loader = SvgAssetLoader(asset);
        await svg.cache.putIfAbsent(
          loader.cacheKey(null),
          () => loader.loadBytes(null),
        );
      }),
    );
  }
}
