import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
  });

  final VoidCallback onTap;
  final String label;
  final double? height;

  @override
  Widget build(BuildContext context) {
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
