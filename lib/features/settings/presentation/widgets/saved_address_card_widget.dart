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
    this.selectionMode = false,
    this.isSelected = false,
  });

  final DeliveryAddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool selectionMode;
  final bool isSelected;

  bool get _showCurrentBadge =>
      selectionMode ? isSelected : address.isCurrent;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: _showCurrentBadge
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
                  if (_showCurrentBadge) ...[
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
            if (selectionMode)
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.orderCardBorder,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 16.sp,
                        color: AppColors.background,
                      )
                    : null,
              )
            else ...[
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
          ],
        ),
      ],
    );

    if (selectionMode) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.orderCardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.orderCardShadow.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: content,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: content,
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
