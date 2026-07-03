import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/settings_content.dart';
import 'settings_card.dart';
import 'settings_metrics.dart';

/// عنصر قائمة في صفحة الإعدادات
class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    super.key,
    required this.item,
    this.notificationsEnabled,
    this.onNotificationsChanged,
    this.onTap,
  });

  final SettingsMenuItem item;
  final bool? notificationsEnabled;
  final ValueChanged<bool>? onNotificationsChanged;
  final VoidCallback? onTap;

  Color get _accentColor => switch (item.style) {
        SettingsMenuStyle.logout => AppColors.settingsLogout,
        SettingsMenuStyle.danger => AppColors.settingsDanger,
        SettingsMenuStyle.normal => AppColors.settingsIcon,
      };

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      onTap: item.hasToggle ? null : onTap,
      padding: SettingsMetrics.menuCardPadding(),
      borderRadius: BorderRadius.circular(SettingsMetrics.menuCardRadius()),
      child: SizedBox(
        height: SettingsMetrics.menuCardHeight(),
        child: Row(
          children: [
            Image.asset(
              item.iconAsset,
              width: SettingsMetrics.itemIconSize(),
              height: SettingsMetrics.itemIconSize(),
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                item.title,
                style: AppTextStyles.settingsMenuItem(
                  color: item.style == SettingsMenuStyle.normal
                      ? null
                      : _accentColor,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            if (item.hasToggle)
              Switch.adaptive(
                value: notificationsEnabled ?? true,
                onChanged: onNotificationsChanged,
                activeThumbColor: AppColors.background,
                activeTrackColor: AppColors.homeHeart,
                inactiveThumbColor: AppColors.background,
                inactiveTrackColor: AppColors.dotGrid,
              )
            else
              Transform.rotate(
                angle: math.pi,
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: _accentColor.withValues(
                    alpha: item.style == SettingsMenuStyle.normal ? 0.55 : 1,
                  ),
                  size: SettingsMetrics.chevronSize(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
