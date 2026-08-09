import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';

/// محتوى صفحات الـ Onboarding
class OnboardingItem {
  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    this.imageAsset,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String? imageAsset;
}

abstract final class OnboardingContent {
  static const items = [
    OnboardingItem(
      title: 'شريكك الموثوق في عالم الجمال',
      description:
          'منصة متخصصة توفر لك منتجات التجميل والعناية، وتجمع احتياجاتك '
          'في مكان واحد بتجربة شراء سهلة ومنظمة.',
      icon: Icons.spa_outlined,
      accentColor: Color(0xFFE8C4B8),
      imageAsset: AppAssets.onboarding1,
    ),
    OnboardingItem(
      title: 'كل منتجاتك بمكان واحد',
      description:
          'يوفر التطبيق مجموعة من منتجات التجميل والعناية من مصادر وعلامات '
          'مختلفة، لتسهيل البحث عن المنتجات وإضافتها إلى طلبك من مكان واحد.',
      icon: Icons.verified_outlined,
      accentColor: Color(0xFFD4C4E8),
      imageAsset: AppAssets.onboarding2,
    ),
    OnboardingItem(
      title: 'طلباتك بكل سهولة',
      description:
          'صُمم التطبيق لتسهيل عملية الشراء، من تصفح المنتجات ومعرفة تفاصيلها '
          'وكمياتها، إلى إنشاء الطلب ومتابعة حالته حتى التجهيز والتوصيل.',
      icon: Icons.card_giftcard_outlined,
      accentColor: Color(0xFFC4D8E8),
      imageAsset: AppAssets.onboarding3,
    ),
  ];
}
