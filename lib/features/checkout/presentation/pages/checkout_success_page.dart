import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../widgets/checkout_bottom_bar.dart';

/// الخطوة 3 — تم التأكيد
class CheckoutSuccessPage extends StatelessWidget {
  const CheckoutSuccessPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
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
            CheckoutBottomBar(
              label: 'تتبع الطلب',
              onTap: () => context.go(AppRoutes.orderTrackingPath(orderId)),
            ),
          ],
        ),
      ),
    );
  }
}
