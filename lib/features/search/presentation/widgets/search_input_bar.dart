import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/unified_search_bar.dart';

/// شريط بحث تفاعلي لصفحة البحث
class SearchInputBar extends StatelessWidget {
  const SearchInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onScannerTap,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onScannerTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
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
              SearchBarcodeButton(onTap: onScannerTap, width: 44.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.authField(
                            color: AppColors.textPrimary,
                          ).copyWith(fontSize: 16.5.sp),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن منتج محدد ... ',
                            hintStyle: AppTextStyles.authField().copyWith(
                              fontSize: 16.5.sp,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(
                              8.w,
                              14.h,
                              4.w,
                              14.h,
                            ),
                          ),
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                        ),
                      ),
                      ListenableBuilder(
                        listenable: controller,
                        builder: (context, _) {
                          if (controller.text.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return GestureDetector(
                            onTap: () {
                              controller.clear();
                              onChanged?.call('');
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                                size: 20.sp,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.w, right: 16.w),
                child: Image.asset(
                  AppAssets.searchIcon,
                  width: 24.sp,
                  height: 24.sp,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
