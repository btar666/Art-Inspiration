import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../data/models/notification_model.dart';
import '../../data/notifications_mock_data.dart';
import '../widgets/notification_card.dart';

/// صفحة الإشعارات
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageBackHeader(
              title: 'الأشعارات',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h + bottomInset),
                children: [
                  for (final group in NotificationGroup.values) ...[
                    _GroupHeader(label: group.label),
                    SizedBox(height: 12.h),
                    for (final notification
                        in NotificationsMockData.forGroup(group)) ...[
                      NotificationCard(notification: notification),
                      SizedBox(height: 10.h),
                    ],
                    SizedBox(height: 8.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: AppTextStyles.notificationGroupTitle(),
      ),
    );
  }
}
