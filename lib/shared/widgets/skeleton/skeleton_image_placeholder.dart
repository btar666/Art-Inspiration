import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'skeleton_shimmer.dart';

/// placeholder لتحميل الصور — shimmer للشاشات الكاملة، ثابت داخل القوائم
class SkeletonImagePlaceholder extends StatelessWidget {
  const SkeletonImagePlaceholder({
    super.key,
    this.borderRadius,
    this.animated = false,
  });

  final BorderRadius? borderRadius;

  /// افتراضياً ثابت داخل القوائم — فعّل shimmer فقط لشاشات التحميل الكاملة
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8.r);

    if (!animated) {
      return ClipRRect(
        borderRadius: radius,
        child: SkeletonBox(
          width: double.infinity,
          height: double.infinity,
          borderRadius: radius,
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: SkeletonShimmer(
        child: SkeletonBox(
          width: double.infinity,
          height: double.infinity,
          borderRadius: radius,
        ),
      ),
    );
  }
}
