import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_refresh_scroll_view.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../data/models/notification_model.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_card.dart';

/// صفحة الإشعارات
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final async = ref.watch(notificationsProvider);

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
              child: async.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: TextButton(
                    onPressed: () =>
                        ref.read(notificationsProvider.notifier).refresh(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return AppRefreshIndicator(
                      onRefresh: () =>
                          ref.read(notificationsProvider.notifier).refresh(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        children: [
                          SizedBox(height: 160.h),
                          Center(
                            child: Text(
                              'لا توجد إشعارات',
                              style: AppTextStyles.notificationGroupTitle(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return AppRefreshIndicator(
                    onRefresh: () =>
                        ref.read(notificationsProvider.notifier).refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        20.w,
                        0,
                        20.w,
                        24.h + bottomInset,
                      ),
                      children: [
                        for (final group in NotificationGroup.values) ...[
                          if (notifications.any((n) => n.group == group)) ...[
                            _GroupHeader(label: group.label),
                            SizedBox(height: 12.h),
                            for (final notification in notifications
                                .where((item) => item.group == group)) ...[
                              NotificationCard(notification: notification),
                              SizedBox(height: 10.h),
                            ],
                            SizedBox(height: 8.h),
                          ],
                        ],
                      ],
                    ),
                  );
                },
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
