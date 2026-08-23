import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/connectivity_error_handler.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/presentation/widgets/orders_page_header.dart';
import '../../data/settings_content.dart';
import '../widgets/edit_profile_bottom_sheet.dart';
import '../widgets/settings_confirm_dialog.dart';
import '../widgets/settings_menu_tile.dart';
import '../widgets/settings_profile_card.dart';

/// صفحة الإعدادات
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).refreshProfile();
    });
  }

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
                physics: const ClampingScrollPhysics(),
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
      default:
        break;
    }
  }

  void _onAccountActionTap(String id) {
    switch (id) {
      case 'logout':
        _showConfirmDialog(
          type: SettingsConfirmType.logout,
          onConfirm: _logout,
        );
      case 'delete_account':
        _showConfirmDialog(
          type: SettingsConfirmType.deleteAccount,
          onConfirm: _deleteAccount,
        );
      default:
        break;
    }
  }

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  Future<void> _deleteAccount() async {
    final ok = await ref.read(authNotifierProvider.notifier).deleteAccount();
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.login);
      return;
    }
    final error = ref.read(authNotifierProvider).errorMessage;
    if (ConnectivityErrorHandler.shouldShowMessage(error)) {
      await ConnectivityErrorHandler.promptRetry(
        context: context,
        ref: ref,
        onRetry: _deleteAccount,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'تعذر حذف الحساب')),
    );
  }

  Future<void> _showConfirmDialog({
    required SettingsConfirmType type,
    Future<void> Function()? onConfirm,
  }) async {
    final confirmed = await SettingsConfirmDialog.show(context, type);

    if (confirmed && onConfirm != null) {
      await onConfirm();
    }
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
