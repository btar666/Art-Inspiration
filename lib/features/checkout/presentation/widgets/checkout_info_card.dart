import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// كارد معلومات في صفحات الشراء
class CheckoutInfoCard extends StatelessWidget {
  const CheckoutInfoCard({
    super.key,
    this.rows = const [],
    this.child,
    this.compact = false,
  });

  final List<(String, String)> rows;
  final Widget? child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: compact ? 14.h : 16.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.orderCardBorder),
      ),
      child: child ??
          Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) SizedBox(height: compact ? 8.h : 12.h),
                _InfoRow(label: rows[i].$1, value: rows[i].$2),
              ],
            ],
          ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.ordersDetailLabel(color: AppColors.primary),
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
