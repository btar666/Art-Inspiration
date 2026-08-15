import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';

/// أبعاد شريط التنقل العائم
abstract final class MainBottomNavMetrics {
  static double width() => 340.w;
  static double height() => 56.h;
  static double radius() => 40.r;
  static double horizontalMargin() => 16.5.w;
  static double bottomMargin() => 16.h;

  /// تصغير خفيف عند السكرول للأسفل
  static double compactScale() => 0.90;
  static double compactDy() => 8.h;
  static double compactAfterPx() => 4;
  static double expandAfterPx() => 4;

  /// ارتفاع محجوز فوق الشريط العائم (هامش + شريط + فراغ)
  static const double floatingBarReservedHeight = 84;
}

/// شريط التنقل السفلي العائم
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(
      label: 'البحث',
      iconActive: AppAssets.navSearchIn,
      iconInactive: AppAssets.navSearchOut,
      iconWidth: 26,
      iconHeight: 26,
    ),
    _NavItem(
      label: 'اكسبلور',
      iconActive: AppAssets.navExploreIn,
      iconInactive: AppAssets.navExploreOut,
      iconWidth: 26,
      iconHeight: 24,
    ),
    _NavItem(
      label: 'الرئيسية',
      iconWidth: 34,
      iconHeight: 34,
      isHome: true,
    ),
    _NavItem(
      label: 'الفواتير',
      iconActive: AppAssets.navFoaterIn,
      iconInactive: AppAssets.navFoaterOut,
      iconWidth: 28,
      iconHeight: 22,
    ),
    _NavItem(
      label: 'الأعدادات',
      iconActive: AppAssets.navSettingsIn,
      iconInactive: AppAssets.navSettingsOut,
      iconWidth: 26,
      iconHeight: 25,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MainBottomNavMetrics.radius()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MainBottomNavMetrics.radius()),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: MainBottomNavMetrics.width(),
            height: MainBottomNavMetrics.height(),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius:
                  BorderRadius.circular(MainBottomNavMetrics.radius()),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                return _NavBarItem(
                  item: _items[index],
                  isActive: index == currentIndex,
                  onTap: () => onTap(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.iconWidth,
    required this.iconHeight,
    this.iconActive,
    this.iconInactive,
    this.isHome = false,
  });

  final String label;
  final String? iconActive;
  final String? iconInactive;
  final double iconWidth;
  final double iconHeight;
  final bool isHome;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58.w,
        height: double.infinity,
        child: Semantics(
          button: true,
          selected: isActive,
          label: item.label,
          child: Center(
            child: _NavIcon(item: item, isActive: isActive),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.item,
    required this.isActive,
  });

  final _NavItem item;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final width = item.iconWidth.w;
    final height = item.iconHeight.h;

    if (item.isHome) {
      return Opacity(
        opacity: isActive ? 1 : 0.45,
        child: Image.asset(
          AppAssets.logo,
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      );
    }

    return Image.asset(
      isActive ? item.iconActive! : item.iconInactive!,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
