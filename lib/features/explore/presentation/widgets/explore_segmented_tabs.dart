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

  int get _selectedIndex => ExploreTab.values.indexOf(selectedTab);

  Alignment _pillAlignment(int index) {
    final count = ExploreTab.values.length;
    if (count <= 1) return Alignment.center;
    final step = 2 / (count - 1);
    return Alignment(1 - step * index, 0);
  }

  @override
  Widget build(BuildContext context) {
    final tabCount = ExploreTab.values.length;

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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: _pillAlignment(_selectedIndex),
            child: FractionallySizedBox(
              widthFactor: 1 / tabCount,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24.r),
                  border: glassStyle
                      ? Border.all(
                          color: AppColors.primarySoft.withValues(alpha: 0.5),
                        )
                      : null,
                  boxShadow: glassStyle
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: ExploreTab.values.map((tab) {
              final isSelected = tab == selectedTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabSelected(tab),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      style: (glassStyle
                              ? AppTextStyles.exploreTabLabel(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF000000),
                                )
                              : AppTextStyles.exploreTabLabel(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary
                                          .withValues(alpha: 0.72),
                                  weight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ))
                          .copyWith(height: 1),
                      child: Text(
                        tab.label,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );

    if (glassStyle) return bar;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: bar,
    );
  }
}
