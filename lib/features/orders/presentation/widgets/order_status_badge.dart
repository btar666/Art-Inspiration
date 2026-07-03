import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/order_status.dart';

/// شارة حالة الطلب
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, text) = switch (status) {
      OrderStatus.delivering => (
          AppColors.orderStatusDeliveringBg,
          AppColors.orderStatusDeliveringText,
        ),
      OrderStatus.delivered => (
          AppColors.orderStatusDeliveredBg,
          AppColors.orderStatusDeliveredText,
        ),
      OrderStatus.cancelled => (
          AppColors.orderStatusCancelledBg,
          AppColors.orderStatusCancelledText,
        ),
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24.r),
      ),
      alignment: Alignment.center,
      child: Text(
        status.label,
        style: AppTextStyles.ordersStatusBadge(color: text),
      ),
    );
  }
}
