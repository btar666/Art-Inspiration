import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';

/// رأس صفحة السلة — رجوع + عنوان + حذف الكل
class CartPageHeader extends StatelessWidget {
  const CartPageHeader({
    super.key,
    required this.onBack,
    this.onClearAll,
    this.showClearAll = false,
  });

  final VoidCallback onBack;
  final VoidCallback? onClearAll;
  final bool showClearAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          AppBackButton(onTap: onBack),
          Expanded(
            child: Text(
              'السلة',
              style: AppTextStyles.ordersPageTitle(),
              textAlign: TextAlign.center,
            ),
          ),
          if (showClearAll)
            GestureDetector(
              onTap: onClearAll,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: Center(
                  child: Image.asset(
                    AppAssets.cartClearAll,
                    width: 24.w,
                    height: 24.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          else
            SizedBox(width: AppBackButtonMetrics.size()),
        ],
      ),
    );
  }
}
