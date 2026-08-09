import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/settings_content.dart';
import 'settings_card.dart';
import 'settings_metrics.dart';

/// بطاقة الملف الشخصي في صفحة الإعدادات
class SettingsProfileCard extends ConsumerWidget {
  const SettingsProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final displayName = user?.name.trim().isNotEmpty == true
        ? user!.name
        : SettingsContent.userName;
    final subtitle = user?.phone ?? user?.email;

    return SettingsCard(
      padding: SettingsMetrics.profilePadding(),
      borderRadius: BorderRadius.circular(SettingsMetrics.profileCardRadius()),
      child: Row(
        children: [
          const _ProfileAvatar(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.settingsProfileName(),
                  textAlign: TextAlign.right,
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.settingsMenuItem(),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final size = SettingsMetrics.profileAvatarSize();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE9E4F5),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: 28.sp,
        color: AppColors.primary.withValues(alpha: 0.55),
      ),
    );
  }
}
