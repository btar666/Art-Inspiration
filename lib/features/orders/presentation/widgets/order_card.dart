import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/order_model.dart';
import 'order_status_badge.dart';

/// كارد طلب في قائمة الفواتير
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final OrderModel order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.orderCardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OrderImage(order: order),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.orderName, style: AppTextStyles.ordersCardTitle()),
                    SizedBox(height: 4.h),
                    Text(
                      order.address,
                      style: AppTextStyles.ordersCardSubtitle(),
                    ),
                    SizedBox(height: 10.h),
                    const _DottedDivider(),
                    SizedBox(height: 10.h),
                    Text(
                      'السعر : ${order.formattedPrice}',
                      style: AppTextStyles.ordersCardPrice(),
                    ),
                    SizedBox(height: 12.h),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderImage extends StatelessWidget {
  const _OrderImage({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      decoration: BoxDecoration(
        color: order.imageBgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 12.h,
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
          Icon(
            Icons.spa_outlined,
            size: 40.sp,
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        36,
        (index) => Expanded(
          child: Container(
            height: 1.5.h,
            margin: EdgeInsets.symmetric(horizontal: 1.2.w),
            color: index.isEven ? AppColors.dotGrid : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
