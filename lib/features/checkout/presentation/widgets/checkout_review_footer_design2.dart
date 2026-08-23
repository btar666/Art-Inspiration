import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/presentation/widgets/cart_page_metrics.dart';
import 'checkout_review_overlay_metrics.dart';

/// **تصميم 2** — زر تأكيد زجاجي momo عائم (blur 20، حدود primary).
///
/// محفوظ للرجوع إليه لاحقاً. الافتراضي الحالي: [CartCheckoutFooter] الزجاجي
/// من صفحة السلة في [CheckoutReviewPage].
class CheckoutReviewFooterDesign2 extends StatelessWidget {
  const CheckoutReviewFooterDesign2({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  static const double _height = 52;
  static const double _borderRadius = 21;

  static double height() => _height.h;

  static double overlayBottomOffset(BuildContext context) =>
      CheckoutReviewOverlayMetrics.overlayBottomOffset(context);

  static double scrollBottomInset(BuildContext context) {
    final footer = CartPageMetrics.footerPadding();
    return height() +
        footer.top +
        footer.bottom +
        CheckoutReviewOverlayMetrics.overlayBottomExtra() +
        CheckoutReviewOverlayMetrics.scrollExtraBottom() +
        MediaQuery.paddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_borderRadius.r);
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: SizedBox(
        height: _height.h,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _GlassLayer(color: Colors.white.withValues(alpha: 0.2)),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: radius,
                  child: Center(
                    child: Text(
                      label,
                      style: AppTextStyles.buttonPrimary(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
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
            ],
          ),
        ),
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
