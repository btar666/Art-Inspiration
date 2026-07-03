import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/search_filter_state.dart';

/// صف الفلاتر النشطة تحت شريط البحث
class SearchActiveFiltersRow extends StatelessWidget {
  const SearchActiveFiltersRow({
    super.key,
    required this.filter,
  });

  final SearchFilterState filter;

  @override
  Widget build(BuildContext context) {
    final priceLabel = filter.priceFilterLabel;
    if (priceLabel == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        children: [
          Text(
            'تصفية حسب :',
            style: AppTextStyles.searchFilterLabel(),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              priceLabel,
              style: AppTextStyles.searchFilterChip(),
            ),
          ),
        ],
      ),
    );
  }
}
