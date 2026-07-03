import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../orders/presentation/widgets/orders_page_header.dart';
import '../../data/settings_content.dart';
import '../widgets/edit_profile_bottom_sheet.dart';
import '../widgets/settings_menu_tile.dart';
import '../widgets/settings_profile_card.dart';

/// صفحة الإعدادات
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OrdersPageHeader(
              title: 'الأعدادات',
              onNotificationTap: () => context.push(AppRoutes.notifications),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  8.h,
                  16.w,
                  100.h + bottomInset,
                ),
                children: [
                  const SettingsProfileCard(),
                  SizedBox(height: 20.h),
                  ...SettingsContent.settingsSections.expand(
                    (section) => [
                      _SectionTitle(title: section.title),
                      SizedBox(height: 10.h),
                      ...section.items.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: SettingsMenuTile(
                            item: item,
                            notificationsEnabled: item.hasToggle
                                ? _notificationsEnabled
                                : null,
                            onNotificationsChanged: item.hasToggle
                                ? (value) => setState(
                                      () => _notificationsEnabled = value,
                                    )
                                : null,
                            onTap: () => _onSettingsItemTap(item.id),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                    ],
                  ),
                  const _SectionTitle(title: 'عن التطبيق'),
                  SizedBox(height: 10.h),
                  ...SettingsContent.accountActions.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: SettingsMenuTile(
                        item: item,
                        onTap: () => _onAccountActionTap(item.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSettingsItemTap(String id) {
    switch (id) {
      case 'edit_profile':
        EditProfileBottomSheet.show(context);
      case 'favorites':
        context.push(AppRoutes.favorites);
      case 'delivery_location':
        context.push(AppRoutes.settingsAddresses);
      case 'about_us':
        context.push(AppRoutes.settingsAbout);
      case 'contact':
        context.push(AppRoutes.settingsContact);
      case 'help':
        context.push(AppRoutes.settingsHelp);
      default:
        break;
    }
  }

  void _onAccountActionTap(String id) {
    switch (id) {
      case 'logout':
        _showConfirmDialog(
          title: 'تسجيل الخروج',
          message: 'هل أنت متأكد من تسجيل الخروج؟',
        );
      case 'delete_account':
        _showConfirmDialog(
          title: 'حذف الحساب',
          message: 'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
          isDanger: true,
        );
      default:
        break;
    }
  }

  Future<void> _showConfirmDialog({
    required String title,
    required String message,
    bool isDanger = false,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.right),
        content: Text(message, textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'تأكيد',
              style: TextStyle(
                color: isDanger ? AppColors.settingsDanger : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.settingsSectionTitle(),
      textAlign: TextAlign.right,
    );
  }
}
