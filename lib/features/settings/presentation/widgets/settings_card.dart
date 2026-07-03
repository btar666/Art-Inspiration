import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'settings_metrics.dart';

/// كونتينر أبيض بظل موحّد لصفحة الإعدادات
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(SettingsMetrics.cardRadius());

    final content = Padding(
      padding: padding ?? SettingsMetrics.cardPadding(),
      child: child,
    );

    // الظل على DecoratedBox خارجي — Ink لا يرسم boxShadow
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: SettingsMetrics.cardShadow(),
      ),
      child: Material(
        color: AppColors.background,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: content,
              ),
      ),
    );
  }
}
