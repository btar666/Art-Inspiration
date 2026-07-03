import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../data/settings_content.dart';
import 'settings_card.dart';
import 'settings_metrics.dart';

/// بطاقة الملف الشخصي في صفحة الإعدادات
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      padding: SettingsMetrics.profilePadding(),
      borderRadius: BorderRadius.circular(SettingsMetrics.profileCardRadius()),
      child: Row(
        children: [
          _ProfileAvatar(imageUrl: SettingsContent.profileImageUrl),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              SettingsContent.userName,
              style: AppTextStyles.settingsProfileName(),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = SettingsMetrics.profileAvatarSize();

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          color: const Color(0xFFE9E4F5),
          child: Icon(Icons.person_rounded, size: 28.sp),
        ),
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          color: const Color(0xFFE9E4F5),
          child: Icon(Icons.person_rounded, size: 28.sp),
        ),
      ),
    );
  }
}
