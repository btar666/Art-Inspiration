import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (history.isNotEmpty)
                GestureDetector(
                  onTap: onClearAll,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.homeDiscount,
                    size: 22.sp,
                  ),
                ),
              const Spacer(),
              Text(
                'سجل البحث',
                style: AppTextStyles.searchSectionTitle(),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (history.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 100.h),
                  child: Text(
                    'سجل البحث فارغ',
                    style: AppTextStyles.searchEmptyState(),
                  ),
                ),
              ),
            )
          else ...[
            ...List.generate(history.length, (index) {
              final term = history[index];
              return Column(
                children: [
                  InkWell(
                    onTap: () => onItemTap(term),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => onRemoveItem(index),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            term,
                            style: AppTextStyles.searchHistoryItem(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < history.length - 1)
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
        ],
      ),
    );
  }
}
