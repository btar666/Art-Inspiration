import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/widgets/main_bottom_nav.dart';

/// مقاييس زر إكمال الشراء
abstract final class CartCheckoutFooterMetrics {
  static double buttonHeight() => 51.h;

  static double borderRadius() => 28.r;

  static List<BoxShadow> buttonShadow() => [
        BoxShadow(
          color: const Color(0x293A3F41),
          offset: Offset(0, 9.97.h),
          blurRadius: 27.93.r,
          spreadRadius: -5.98.r,
        ),
      ];
}

/// زر إجراء في ذيل الصفحة (السلة، الشراء، …)
class CartCheckoutFooter extends StatelessWidget {
  const CartCheckoutFooter({
    super.key,
    required this.onTap,
    this.label = 'أكمال الشراء',
    this.height,
    this.glassy = false,
  });

  final VoidCallback onTap;
  final String label;
  final double? height;
  final bool glassy;

  @override
  Widget build(BuildContext context) {
    if (glassy) return _buildGlassy(context);
    return _buildSolid(context);
  }

  Widget _buildGlassy(BuildContext context) {
    final radius = BorderRadius.circular(MainBottomNavMetrics.radius());
    final buttonHeight = height ?? MainBottomNavMetrics.height();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  width: double.infinity,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAECFC).withValues(alpha: 0.12),
                    borderRadius: radius,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _WhiteInnerShadow(borderRadius: radius),
                      Center(
                        child: Text(
                          label,
                          style: AppTextStyles.cartCheckoutButton(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSolid(BuildContext context) {
    final radius = CartCheckoutFooterMetrics.borderRadius();

    return Container(
      width: double.infinity,
      height: height ?? CartCheckoutFooterMetrics.buttonHeight(),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: CartCheckoutFooterMetrics.buttonShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.cartCheckoutButton(),
            ),
          ),
        ),
      ),
    );
  }
}

/// ظل داخلي أبيض خفيف على حواف الزجاج
class _WhiteInnerShadow extends StatelessWidget {
  const _WhiteInnerShadow({this.borderRadius});

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.38),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0, 0.5],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: RadialGradient(
                radius: 1.08,
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.28),
                ],
                stops: const [0.68, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
