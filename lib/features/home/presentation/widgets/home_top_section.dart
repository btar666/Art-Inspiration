import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/unified_search_bar.dart';

/// الجزء العلوي: شعار وسط + إشعارات يسار + شريط بحث موحّد
class HomeTopSection extends StatelessWidget {
  const HomeTopSection({
    super.key,
    this.onNotificationTap,
    this.onFilterTap,
    this.onScannerTap,
    this.onSearchTap,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onFilterTap;
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
            onFilterTap: onFilterTap,
            onScannerTap: onScannerTap,
            onSearchTap: onSearchTap,
          ),
        ],
      ),
    );
  }
}

/// صف الشعار والإشعارات
class HomeLogoHeader extends StatelessWidget {
  const HomeLogoHeader({super.key, this.onNotificationTap});

  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 28.sp),
          Expanded(child: _CenterLogo()),
          _NotificationButton(onTap: onNotificationTap),
        ],
      ),
    );
  }
}

/// شريط البحث الموحّد
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onFilterTap,
    this.onScannerTap,
    this.onSearchTap,
  });

  final VoidCallback? onFilterTap;
  final VoidCallback? onScannerTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: UnifiedSearchBar(
        hintText: 'أبحث عن منتج أو متجر محدد ..',
        onFilterTap: onFilterTap,
        onScannerTap: onScannerTap,
        onSearchTap: onSearchTap,
      ),
    );
  }
}

class _CenterLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppConstants.appName,
          style: AppTextStyles.homeLogoTitle(),
          textAlign: TextAlign.center,
        ),
        Text(
          AppConstants.appTagline,
          style: AppTextStyles.homeLogoSubtitle(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(Icons.notifications_rounded, color: AppColors.primary, size: 28.sp),
    );
  }
}
