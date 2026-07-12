import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/pinned_blur_gradient_background.dart';
import '../../../orders/presentation/widgets/orders_page_header.dart';
import '../../data/models/explore_models.dart';
import 'explore_scroll_metrics.dart';
import 'explore_tabs_section.dart';

/// هيدر الاكسبلور — عنوان + تبويبات يختفيان معاً عند التمرير
class ExploreHeaderOverlay extends StatelessWidget {
  const ExploreHeaderOverlay({
    super.key,
    required this.scrollOffset,
    required this.selectedTab,
    required this.onTabSelected,
    this.onNotificationTap,
  });

  final double scrollOffset;
  final ExploreTab selectedTab;
  final ValueChanged<ExploreTab> onTabSelected;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final hideStart = ExploreScrollMetrics.headerHideStartOffset();
    final hideRange = ExploreScrollMetrics.headerHideAnimationRange();
    final hideProgress =
        ((scrollOffset - hideStart) / hideRange).clamp(0.0, 1.0);
    final opacity = 1.0 - hideProgress;

    if (opacity <= 0) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: opacity < 0.1,
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, -12.h * hideProgress),
            child: ClipRect(
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: PinnedBlurGradientBackground(
                      fadeStops: PinnedBlurHeaderStyle.homeFadeStops,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: topInset),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 8.h, 0, 0),
                          child: OrdersPageHeader(
                            title: 'الاكسبلور',
                            onNotificationTap: onNotificationTap,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ExploreTabsSection(
                          selectedTab: selectedTab,
                          onTabSelected: onTabSelected,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
