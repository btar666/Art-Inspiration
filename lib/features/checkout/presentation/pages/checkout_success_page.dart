import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../cart/presentation/widgets/cart_checkout_footer.dart';
import '../../../cart/presentation/widgets/cart_page_metrics.dart';

/// الخطوة 3 — تم التأكيد
class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final footerHeight = screenHeight * CartPageMetrics.footerHeightFraction;
    final bottomRadius = CartPageMetrics.whiteContainerBottomRadius();

    return Scaffold(
      backgroundColor: CartPageMetrics.pageBackground,
      body: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(bottomRadius),
                  bottomRight: Radius.circular(bottomRadius),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(bottomRadius),
                  bottomRight: Radius.circular(bottomRadius),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PageBackHeader(
                        title: 'التأكيد',
                        onBack: () => context.go(AppRoutes.home),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppAssets.confirmOrderIllustration,
                                width: 220.w,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                'تم التأكيد بنجاح',
                                style: AppTextStyles.checkoutSuccessTitle(),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: footerHeight,
            child: ColoredBox(
              color: CartPageMetrics.pageBackground,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: CartPageMetrics.footerPadding(),
                  child: Transform.translate(
                    offset: CartPageMetrics.footerButtonOffset(),
                    child: CartCheckoutFooter(
                      label: 'تتبع الطلب',
                      onTap: () =>
                          context.go(AppRoutes.orderTrackingPath(orderId)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
