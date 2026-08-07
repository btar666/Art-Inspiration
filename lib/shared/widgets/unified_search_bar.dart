import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// شريط بحث موحّد — فلتر مدمج + نص + بحث (مع باركود اختياري)
class UnifiedSearchBar extends StatelessWidget {
  const UnifiedSearchBar({
    super.key,
    required this.hintText,
    this.onFilterTap,
    this.onScannerTap,
    this.onSearchTap,
    this.controller,
    this.onChanged,
    this.showScanner = true,
    this.showFilter = true,
  });

  final String hintText;
  final VoidCallback? onFilterTap;
  final VoidCallback? onScannerTap;
  final VoidCallback? onSearchTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool showScanner;
  final bool showFilter;

  bool get _isEditable => controller != null;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.dotGrid, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          if (showFilter) SearchFilterButton(onTap: onFilterTap),
          if (showScanner)
            GestureDetector(
              onTap: onScannerTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: showFilter ? 0 : 16.w),
              child: _isEditable
                  ? TextField(
                      controller: controller,
                      onChanged: onChanged,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.authField(),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hintText,
                        hintStyle: AppTextStyles.authField(),
                        hintTextDirection: TextDirection.rtl,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    )
                  : Text(
                      hintText,
                      style: AppTextStyles.authField(),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: _isEditable
          ? bar
          : GestureDetector(
              onTap: onSearchTap,
              child: bar,
            ),
    );
  }
}

/// زر الفلتر — خلفية بلون اللوغو بثلاث زوايا دائرية وزاوية حادة
class SearchFilterButton extends StatelessWidget {
  const SearchFilterButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 52.w,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            bottomLeft: Radius.circular(28.r),
            bottomRight: Radius.circular(28.r),
            topRight: Radius.zero,
          ),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          AppAssets.filterIcon,
          width: 22.w,
          height: 22.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
