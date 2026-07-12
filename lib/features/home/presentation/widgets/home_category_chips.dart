import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// شرائح الأقسام الأفقية
class HomeCategoryChips extends StatelessWidget {
  const HomeCategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    this.title = 'الأقسام الأكثر شهرة',
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
          child: Text(title, style: AppTextStyles.homeSectionTitle()),
        ),
        SizedBox(
          height: 38.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.homeChipBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    categories[index],
                    style: AppTextStyles.homeProductCategory(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
