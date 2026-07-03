import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
      child: _UnifiedSearchBar(
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

/// شريط بحث موحّد — فلتر مدمج يسار + باركود + نص + بحث
class _UnifiedSearchBar extends StatelessWidget {
  const _UnifiedSearchBar({
    this.onFilterTap,
    this.onScannerTap,
    this.onSearchTap,
  });

  final VoidCallback? onFilterTap;
  final VoidCallback? onScannerTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: onSearchTap,
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: AppColors.dotGrid, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              _FilterButton(onTap: onFilterTap),
              GestureDetector(
                onTap: onScannerTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'أبحث عن منتج أو متجر محدد ..',
                  style: AppTextStyles.authField(),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Icon(Icons.search, color: AppColors.textPrimary, size: 24.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر الفلتر — خلفية بلون اللوغو بثلاث زوايا دائرية وزاوية حادة
class _FilterButton extends StatelessWidget {
  const _FilterButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 52.w,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            bottomLeft: Radius.circular(28.r),
            bottomRight: Radius.circular(28.r),
            topRight: Radius.zero,
          ),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          AppAssets.filterIcon,
          width: 22.w,
          height: 22.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
