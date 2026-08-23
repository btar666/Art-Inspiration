import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// شريط أزرار الذيل في صفحة تفاصيل الطلب
class OrderDetailsActionBar extends StatelessWidget {
  const OrderDetailsActionBar({
    super.key,
    required this.onPrimary,
    required this.onSecondary,
    this.primaryLabel = 'إعادة الطلب',
    this.secondaryLabel = 'العودة',
    this.glassSecondaryOnly = false,
  });

  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final String primaryLabel;
  final String secondaryLabel;

  /// تصميم «momo»: الشريط القديم مع زر عودة زجاجي بدل البنفسجي
  final bool glassSecondaryOnly;

  static const Color _barBackground = Color(0xFF8C8EFD);
  static const Color _reorderBackground = Color(0xFF0000FF);

  static const double _barHeight = 52;
  static const double _borderRadius = 21;
  static const double _reorderWidthFraction = 0.60;

  @override
  Widget build(BuildContext context) {
    if (glassSecondaryOnly) {
      return _GlassSecondaryActionBar(
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        primaryLabel: primaryLabel,
        secondaryLabel: secondaryLabel,
      );
    }

    return SizedBox(
      height: _barHeight.h,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final reorderWidth = barWidth * _reorderWidthFraction;
          final backWidth = barWidth * (1 - _reorderWidthFraction);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: _barBackground,
                  borderRadius: BorderRadius.circular(_borderRadius.r),
                ),
                child: SizedBox(
                  height: _barHeight.h,
                  width: double.infinity,
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: backWidth,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSecondary,
                    borderRadius: BorderRadius.circular(_borderRadius.r),
                    child: Center(
                      child: Text(
                        secondaryLabel,
                        style: AppTextStyles.buttonPrimary(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: reorderWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _reorderBackground,
                    borderRadius: BorderRadius.circular(_borderRadius.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 6.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPrimary,
                      borderRadius: BorderRadius.circular(_borderRadius.r),
                      child: Center(
                        child: Text(
                          primaryLabel,
                          style: AppTextStyles.buttonPrimary(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlassSecondaryActionBar extends StatelessWidget {
  const _GlassSecondaryActionBar({
    required this.onPrimary,
    required this.onSecondary,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final String primaryLabel;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: OrderDetailsActionBar._barHeight.h,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final reorderWidth =
              barWidth * OrderDetailsActionBar._reorderWidthFraction;
          final backWidth = barWidth * (1 - OrderDetailsActionBar._reorderWidthFraction);
          final radius =
              BorderRadius.circular(OrderDetailsActionBar._borderRadius.r);

          return ClipRRect(
            borderRadius: radius,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: _GlassLayer(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: backWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onSecondary,
                      borderRadius: radius,
                      child: Center(
                        child: Text(
                          secondaryLabel,
                          style: AppTextStyles.buttonPrimary(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: reorderWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: OrderDetailsActionBar._reorderBackground,
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 6.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onPrimary,
                        borderRadius: radius,
                        child: Center(
                          child: Text(
                            primaryLabel,
                            style: AppTextStyles.buttonPrimary(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GlassLayer extends StatelessWidget {
  const _GlassLayer({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: ColoredBox(color: color),
    );
  }
}
