import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/explore_models.dart';

/// شريط التبويبات — عام | براندات | اقسام
class ExploreSegmentedTabs extends StatelessWidget {
  const ExploreSegmentedTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    this.glassStyle = false,
  });

  final ExploreTab selectedTab;
  final ValueChanged<ExploreTab> onTabSelected;
  final bool glassStyle;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      height: 46.h,
      padding: EdgeInsets.all(4.w),
      decoration: glassStyle
          ? null
          : BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: AppColors.dotGrid, width: 1.2),
            ),
      child: Row(
        children: ExploreTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(tab),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(24.r),
                  border: glassStyle && isSelected
                      ? Border.all(
                          color: AppColors.primarySoft.withValues(alpha: 0.5),
                        )
                      : null,
                ),
                child: Text(
                  tab.label,
                  textAlign: TextAlign.center,
                  style: glassStyle
                      ? AppTextStyles.exploreTabLabel(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF000000),
                        )
                      : AppTextStyles.exploreTabLabel(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary.withValues(alpha: 0.72),
                          weight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (glassStyle) return bar;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: bar,
    );
  }
}
