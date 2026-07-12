import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';

/// شريط أزرار الذيل في صفحة تفاصيل الطلب
class OrderDetailsActionBar extends StatelessWidget {
  const OrderDetailsActionBar({
    super.key,
    required this.onPrimary,
    required this.onSecondary,
    this.primaryLabel = 'إعادة الطلب',
    this.secondaryLabel = 'العودة',
  });

  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final String primaryLabel;
  final String secondaryLabel;

  static const Color _barBackground = Color(0xFF8C8EFD);
  static const Color _reorderBackground = Color(0xFF0000FF);

  static const double _barHeight = 52;
  static const double _borderRadius = 21;
  static const double _reorderWidthFraction = 0.60;

  @override
  Widget build(BuildContext context) {
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
