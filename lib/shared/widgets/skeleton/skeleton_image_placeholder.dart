import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'skeleton_shimmer.dart';

/// placeholder shimmer لتحميل الصور — يملأ المساحة المتاحة
class SkeletonImagePlaceholder extends StatelessWidget {
  const SkeletonImagePlaceholder({
    super.key,
    this.borderRadius,
  });

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8.r);

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
