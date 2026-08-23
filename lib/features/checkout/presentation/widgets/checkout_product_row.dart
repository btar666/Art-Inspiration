import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/data/models/cart_item_model.dart';

/// صف منتج في صفحة مراجعة الطلب
class CheckoutProductRow extends StatelessWidget {
  const CheckoutProductRow({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: 56.w,
            height: 56.w,
            color: product.imageBgColor,
            child: product.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                  )
                : Icon(Icons.image_outlined, color: AppColors.textSecondary),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                product.name,
                style: AppTextStyles.ordersDetailValue(),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 6.h),
              _ProductInfoRow(
                label: 'الكمية المطلوبة :',
                value: '${item.quantity}',
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Text(
            product.formattedPrice,
            style: AppTextStyles.ordersItemPrice(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _ProductInfoRow extends StatelessWidget {
  const _ProductInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.ordersDetailLabel(),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.ordersDetailValue(),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
