import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/search_filter_state.dart';

/// صف الفلاتر النشطة — chip مباشرة على يسار «تصفية حسب»
class SearchActiveFiltersRow extends StatelessWidget {
  const SearchActiveFiltersRow({
    super.key,
    required this.filter,
  });

  final SearchFilterState filter;

  @override
  Widget build(BuildContext context) {
    final labels = filter.activeFilterLabels;
    if (labels.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 14.h),
      child: Align(
        alignment: Alignment.centerRight,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'تصفية حسب :',
                  style: AppTextStyles.searchFilterLabel(),
                ),
                SizedBox(width: 10.w),
                for (var i = 0; i < labels.length; i++) ...[
                  if (i > 0) SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      labels[i],
                      style: AppTextStyles.searchFilterChip(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
