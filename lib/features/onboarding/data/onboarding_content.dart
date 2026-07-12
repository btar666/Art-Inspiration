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
      title: 'اكتشفي جمالكِ الحقيقي',
      description:
          'تصفّحي أحدث منتجات التجميل والعناية بالبشرة المختارة بعناية، '
          'من المكياج اليومي إلى العناية المتكاملة التي تناسب أسلوبكِ.',
      icon: Icons.spa_outlined,
      accentColor: Color(0xFFE8C4B8),
      imageAsset: AppAssets.onboarding1,
    ),
    OnboardingItem(
      title: 'جودة تثقي بها',
      description:
          'منتجات أصلية من أفضل العلامات العالمية في عالم الكوزمتك، '
          'بأسعار منافسة وتوصيل سريع وآمن إلى باب منزلكِ.',
      icon: Icons.verified_outlined,
      accentColor: Color(0xFFD4C4E8),
      imageAsset: AppAssets.onboarding2,
    ),
    OnboardingItem(
      title: 'ابدئي رحلتكِ الآن',
      description:
          'انضمي إلينا واستمتعي بتجربة تسوق سلسة مع عروض حصرية، '
          'نقاط مكافآت، وتوصيات مخصصة تناسب احتياجاتكِ الجمالية.',
      icon: Icons.card_giftcard_outlined,
      accentColor: Color(0xFFC4D8E8),
      imageAsset: AppAssets.onboarding3,
    ),
  ];
}
