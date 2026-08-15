import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// قسم سجل البحث
class SearchHistorySection extends StatelessWidget {
  const SearchHistorySection({
    super.key,
    required this.history,
    required this.onClearAll,
    required this.onRemoveItem,
    required this.onItemTap,
  });

  final List<String> history;
  final VoidCallback onClearAll;
  final ValueChanged<int> onRemoveItem;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    final visible = history.take(AppConstants.maxSearchHistoryItems).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'سجل البحث',
                style: AppTextStyles.searchSectionTitle(),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClearAll,
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.homeDiscount,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...List.generate(visible.length, (index) {
            final term = visible[index];
            return Column(
              children: [
                InkWell(
                  onTap: () => onItemTap(term),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            term,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.searchHistoryItem(),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () => onRemoveItem(index),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < visible.length - 1)
                  Divider(
                    height: 1,
                    color: AppColors.dotGrid.withValues(alpha: 0.8),
                  ),
              ],
            );
          }),
          SizedBox(height: 8.h),
          Divider(
            height: 1,
            color: AppColors.dotGrid.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }
}
