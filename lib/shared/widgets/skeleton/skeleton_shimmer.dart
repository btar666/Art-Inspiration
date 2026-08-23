import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

/// نطاق shimmer مشترك لجميع عناصر الـ skeleton في الشجرة الفرعية
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SkeletonShimmerScope(
      animation: _controller,
      child: widget.child,
    );
  }
}

class _SkeletonShimmerScope extends InheritedWidget {
  const _SkeletonShimmerScope({
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  static Animation<double>? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_SkeletonShimmerScope>()
        ?.animation;
  }

  @override
  bool updateShouldNotify(_SkeletonShimmerScope oldWidget) =>
      animation != oldWidget.animation;
}

/// مستطيل shimmer — أساس جميع عناصر الـ skeleton
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8.r);
    final animation = _SkeletonShimmerScope.of(context);

    if (animation == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: radius,
        ),
      );
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final shift = -1.2 + animation.value * 2.4;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment(shift - 0.5, 0),
              end: Alignment(shift + 0.5, 0),
              colors: const [
                AppColors.primaryLight,
                AppColors.surface,
                AppColors.primaryLight,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// خط نصي shimmer
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    required this.width,
    this.height,
    this.borderRadius,
  });

  final double width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height ?? 12.h,
      borderRadius: borderRadius ?? BorderRadius.circular(6.r),
    );
  }
}
