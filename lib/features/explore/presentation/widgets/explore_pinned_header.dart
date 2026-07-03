import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../orders/presentation/widgets/orders_page_header.dart';
import '../../data/models/explore_models.dart';
import 'explore_glass_header_background.dart';
import 'explore_segmented_tabs.dart';

/// الرأس الثابت — زجاج أبيض iOS + تبويبات زجاجية
class ExplorePinnedHeader extends StatelessWidget {
  const ExplorePinnedHeader({
    super.key,
    this.headerKey,
    required this.selectedTab,
    required this.onTabSelected,
    this.onNotificationTap,
  });

  final Key? headerKey;
  final ExploreTab selectedTab;
  final ValueChanged<ExploreTab> onTabSelected;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: Column(
          key: headerKey,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                const Positioned.fill(
                  child: ExploreGlassHeaderBackground(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: topInset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OrdersPageHeader(
                        title: 'الاكسبلور',
                        onNotificationTap: onNotificationTap,
                      ),
                      SizedBox(height: 8.h),
                      Padding(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
