import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/explore_models.dart';
import 'explore_segmented_tabs.dart';

/// شريط التبويبات داخل محتوى التمرير
class ExploreTabsSection extends StatelessWidget {
  const ExploreTabsSection({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final ExploreTab selectedTab;
  final ValueChanged<ExploreTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 25,
            sigmaY: 25,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            child: ExploreSegmentedTabs(
              glassStyle: true,
              selectedTab: selectedTab,
              onTabSelected: onTabSelected,
            ),
          ),
        ),
      ),
    );
  }
}
