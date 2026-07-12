import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/delivery_address_model.dart';
import 'saved_addresses_page_metrics.dart';

/// بطاقة عنوان توصيل محفوظ
class SavedAddressCardWidget extends StatelessWidget {
  const SavedAddressCardWidget({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    this.selectionMode = false,
    this.isSelected = false,
    this.onSelect,
  });

  final DeliveryAddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onSelect;

  bool get _showCurrentBadge =>
      selectionMode ? isSelected : address.isCurrent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSelect,
              behavior: HitTestBehavior.opaque,
              child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _LocationIcon(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            textDirection: TextDirection.rtl,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                address.governorate,
                                style: AppTextStyles.settingsMenuItem().copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.sp,
                                ),
                              ),
                              if (_showCurrentBadge) ...[
                                SizedBox(width: 6.w),
                                Text(
                                  '( العنوان الحالي )',
                                  style: AppTextStyles.settingsMenuItem(
                                    color: AppColors.primary,
                                  ).copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          address.area,
                          style: AppTextStyles.settingsMenuItem(
                            color: AppColors.textSecondary,
                          ).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          _AddressActionButton(
            asset: AppAssets.addressEditIcon,
            backgroundColor: SavedAddressesPageMetrics.editButtonBackground(),
            onTap: onEdit,
          ),
          SizedBox(width: 8.w),
          _AddressActionButton(
            asset: AppAssets.addressDeleteIcon,
            backgroundColor: SavedAddressesPageMetrics.deleteButtonBackground(),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _LocationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = SavedAddressesPageMetrics.locationIconSize();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: SavedAddressesPageMetrics.locationIconBackground(),
        borderRadius: BorderRadius.circular(
          SavedAddressesPageMetrics.locationIconRadius(),
        ),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        AppAssets.settingsLocation,
        width: 24.w,
        height: 24.w,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _AddressActionButton extends StatelessWidget {
  const _AddressActionButton({
    required this.asset,
    required this.backgroundColor,
    required this.onTap,
  });

  final String asset;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = SavedAddressesPageMetrics.actionButtonSize();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            SavedAddressesPageMetrics.actionButtonRadius(),
          ),
        ),
        padding: EdgeInsets.all(8.w),
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
