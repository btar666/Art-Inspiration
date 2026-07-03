import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/delivery_address_model.dart';

/// بطاقة عنوان توصيل محفوظ
class SavedAddressCardWidget extends StatelessWidget {
  const SavedAddressCardWidget({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  final DeliveryAddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: address.isCurrent
                  ? AppColors.primaryLight
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: AppColors.productStore,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (address.isCurrent) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'الحالي',
                          style: AppTextStyles.settingsMenuItem(
                            color: AppColors.productStore,
                          ).copyWith(fontSize: 10.sp),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      child: Text(
                        address.governorate,
                        style: AppTextStyles.settingsMenuItem().copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  address.area,
                  style: AppTextStyles.settingsMenuItem(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
                if (address.landmark.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    address.landmark,
                    style: AppTextStyles.settingsMenuItem(
                      color: AppColors.textSecondary,
                    ).copyWith(fontSize: 12.sp),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIcon(
                icon: Icons.edit_outlined,
                color: AppColors.settingsIcon,
                onTap: onEdit,
              ),
              SizedBox(width: 4.w),
              _ActionIcon(
                icon: Icons.delete_outline_rounded,
                color: AppColors.settingsDanger,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }
}
