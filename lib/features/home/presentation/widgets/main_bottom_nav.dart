import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';

/// شريط التنقل السفلي
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.search, label: 'البحث'),
    _NavItem(icon: Icons.grid_view_rounded, label: 'اكسبلور'),
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية', isHome: true),
    _NavItem(icon: Icons.inventory_2_outlined, label: 'الفواتير'),
    _NavItem(icon: Icons.settings_outlined, label: 'الأعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
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
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    this.isHome = false,
  });

  final IconData icon;
  final String label;
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
    final color = isActive ? AppColors.primary : AppColors.homeNavInactive;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.isHome)
              Opacity(
                opacity: isActive ? 1 : 0.45,
                child: Image.asset(
                  AppAssets.logo,
                  width: 24.w,
                  height: 24.w,
                  fit: BoxFit.contain,
                ),
              )
            else
              Icon(item.icon, color: color, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 9.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
