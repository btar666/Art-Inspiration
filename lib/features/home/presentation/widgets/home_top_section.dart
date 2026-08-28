import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_notification_icon_button.dart';
import '../../../../shared/widgets/search_hint_typewriter.dart';
import '../../../../shared/widgets/unified_search_bar.dart';
import '../providers/home_slider_index_provider.dart';
import 'home_scroll_metrics.dart';

/// الجزء العلوي: شعار وسط + إشعارات يسار + شريط بحث موحّد
class HomeTopSection extends StatelessWidget {
  const HomeTopSection({
    super.key,
    this.onNotificationTap,
    this.onScannerTap,
    this.onSearchTap,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onScannerTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      child: Column(
        children: [
          HomeLogoHeader(onNotificationTap: onNotificationTap),
          SizedBox(height: 14.h),
          HomeSearchBar(
            onScannerTap: onScannerTap,
            onSearchTap: onSearchTap,
            onNotificationTap: onNotificationTap,
          ),
        ],
      ),
    );
  }
}

/// صف الشعار والإشعارات
class HomeLogoHeader extends StatelessWidget {
  const HomeLogoHeader({
    super.key,
    this.onNotificationTap,
    this.onHeroBackground = true,
  });

  final VoidCallback? onNotificationTap;
  final bool onHeroBackground;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 28.sp),
          Expanded(child: _CenterLogo(onHeroBackground: onHeroBackground)),
          AppNotificationIconButton(onTap: onNotificationTap),
        ],
      ),
    );
  }
}

/// شريط البحث الموحّد للهيرو — أصغر حجماً مع زر إشعارات
class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({
    super.key,
    this.onScannerTap,
    this.onSearchTap,
    this.onNotificationTap,
  });

  final VoidCallback? onScannerTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintTerm = ref.watch(homeSearchHintTermProvider);
    final hintCycle = ref.watch(homeSearchHintCycleProvider);
    final hintStyle = AppTextStyles.authField().copyWith(fontSize: 16.sp);

    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 8.h, 20.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: UnifiedSearchBar(
              hintChild: SearchHintTypewriter(
                key: ValueKey('search-hint-$hintCycle'),
                term: hintTerm,
                style: hintStyle,
              ),
              onScannerTap: onScannerTap,
              onSearchTap: onSearchTap,
              height: HomeScrollMetrics.searchBarHeight() - 1.h,
              dense: true,
              showBorder: false,
              searchIconAsset: AppAssets.searchIcon,
              fontSize: 16.sp,
              textOffsetY: -3.h,
            ),
          ),
          if (onNotificationTap != null) ...[
            SizedBox(width: 8.w),
            // دائرة بيضاء مثل شريط البحث: الجرس أزرق وكان يختفي فوق البانر الأزرق
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AppNotificationIconButton(
                onTap: onNotificationTap,
                size: 32.w,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CenterLogo extends StatelessWidget {
  const _CenterLogo({this.onHeroBackground = true});

  final bool onHeroBackground;

  @override
  Widget build(BuildContext context) {
    final color = onHeroBackground ? Colors.white : null;
    final shadows = onHeroBackground
        ? const [
            Shadow(blurRadius: 10, color: Colors.black54),
            Shadow(blurRadius: 2, color: Colors.black38),
          ]
        : null;

    return Column(
      children: [
        Text(
          AppConstants.appName,
          style: AppTextStyles.homeLogoTitle(color: color).copyWith(
            shadows: shadows,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          AppConstants.appTagline,
          style: AppTextStyles.homeLogoSubtitle(color: color).copyWith(
            shadows: shadows,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
