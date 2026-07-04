import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_text_styles.dart';

/// حالة السلة الفارغة
class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.basketLogo,
              width: 260.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            Text(
              'السلة فارغة ! أضف أول منتج الآن',
              style: AppTextStyles.cartEmptyMessage(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
