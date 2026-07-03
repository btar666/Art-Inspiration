import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../data/settings_content.dart';
import 'settings_menu_tile.dart';
import 'settings_metrics.dart';

/// قسم في صفحة الإعدادات
class SettingsSectionBlock extends StatelessWidget {
  const SettingsSectionBlock({
    super.key,
    required this.section,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    this.onItemTap,
  });

  final SettingsSection section;
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final void Function(SettingsMenuItem item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          section.title,
          style: AppTextStyles.settingsSectionTitle(),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: SettingsMetrics.sectionTitleGap()),
        for (var i = 0; i < section.items.length; i++) ...[
          if (i > 0) SizedBox(height: SettingsMetrics.itemGap()),
          SettingsMenuTile(
            item: section.items[i],
            notificationsEnabled: section.items[i].hasToggle
                ? notificationsEnabled
                : null,
            onNotificationsChanged: section.items[i].hasToggle
                ? onNotificationsChanged
                : null,
            onTap: section.items[i].hasToggle
                ? null
                : () => onItemTap?.call(section.items[i]),
          ),
        ],
      ],
    );
  }
}
