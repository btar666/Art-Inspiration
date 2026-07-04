import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// تفاصيل السعر في السلة
class CartPriceSummary extends StatelessWidget {
  const CartPriceSummary({
    super.key,
    required this.subtotal,
    required this.deliveryLabel,
    required this.total,
    this.isFreeDelivery = false,
  });

  final String subtotal;
  final String deliveryLabel;
  final String total;
  final bool isFreeDelivery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'تفاصيل السعر',
            style: AppTextStyles.cartSectionTitle(),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.orderCardBorder, width: 1),
          ),
          child: Column(
            children: [
              _PriceRow(label: 'سعر الطلب :', value: subtotal),
              SizedBox(height: 10.h),
              _PriceRow(
                label: 'سعر التوصيل :',
                value: deliveryLabel,
                valueColor: isFreeDelivery
                    ? AppColors.orderFreeDelivery
                    : AppColors.textPrimary,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(
                  height: 1,
                  color: AppColors.dotGrid,
                ),
              ),
              _PriceRow(
                label: 'السعر الكلي :',
                value: total,
                valueColor: AppColors.orderTotalPrice,
                labelWeight: FontWeight.w800,
                valueWeight: FontWeight.w800,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.labelWeight,
    this.valueWeight,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? labelWeight;
  final FontWeight? valueWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.cartPriceLabel(weight: labelWeight),
        ),
        Text(
          value,
          style: AppTextStyles.cartPriceValue(
            color: valueColor,
            weight: valueWeight,
          ),
        ),
      ],
    );
  }
}
