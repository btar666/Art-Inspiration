import '../../../core/constants/app_assets.dart';

/// نمط عنصر قائمة الإعدادات
enum SettingsMenuStyle { normal, logout, danger }

/// عنصر في قائمة الإعدادات
class SettingsMenuItem {
  const SettingsMenuItem({
    required this.id,
    required this.title,
    required this.iconAsset,
    this.style = SettingsMenuStyle.normal,
    this.hasToggle = false,
  });

  final String id;
  final String title;
  final String iconAsset;
  final SettingsMenuStyle style;
  final bool hasToggle;
}

/// قسم في صفحة الإعدادات
class SettingsSection {
  const SettingsSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<SettingsMenuItem> items;
}

/// محتوى صفحة الإعدادات
abstract final class SettingsContent {
  static const userName = 'نونة الحنونة';

  static const profileImageUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop';

  static const settingsSections = [
    SettingsSection(
      title: 'الأعدادات',
      items: [
        SettingsMenuItem(
          id: 'favorites',
          title: 'المفضلات',
          iconAsset: AppAssets.settingsFavorites,
        ),
        SettingsMenuItem(
          id: 'edit_profile',
          title: 'تعديل معلوماتك',
          iconAsset: AppAssets.settingsEdit,
        ),
        SettingsMenuItem(
          id: 'delivery_location',
          title: 'موقع التوصيل',
          iconAsset: AppAssets.settingsLocation,
        ),
        SettingsMenuItem(
          id: 'notifications',
          title: 'الأشعارات',
          iconAsset: AppAssets.settingsNotifications,
          hasToggle: true,
        ),
      ],
    ),
    SettingsSection(
      title: 'عن التطبيق',
      items: [
        SettingsMenuItem(
          id: 'about_us',
          title: 'من نحن ؟',
          iconAsset: AppAssets.settingsAbout,
        ),
        SettingsMenuItem(
          id: 'contact',
          title: 'تواصل معنا',
          iconAsset: AppAssets.settingsContact,
        ),
        SettingsMenuItem(
          id: 'help',
          title: 'المساعدة',
          iconAsset: AppAssets.settingsHelp,
        ),
      ],
    ),
  ];

  static const accountActions = [
    SettingsMenuItem(
      id: 'logout',
      title: 'تسجيل الخروج',
      iconAsset: AppAssets.settingsLogout,
      style: SettingsMenuStyle.logout,
    ),
    SettingsMenuItem(
      id: 'delete_account',
      title: 'حذف حسابي',
      iconAsset: AppAssets.settingsDeleteAccount,
      style: SettingsMenuStyle.danger,
    ),
  ];
}
