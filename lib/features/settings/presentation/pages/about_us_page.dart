import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';

/// صفحة من نحن — نص about من api/info
class AboutUsPage extends ConsumerWidget {
  const AboutUsPage({super.key});

  String _plainAbout(String raw) {
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final infoAsync = ref.watch(appInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageBackHeader(
              title: 'من نحن ؟',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: infoAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(appInfoProvider),
                    child: const Text('إعادة المحاولة'),
                  ),
                ),
                data: (info) => _AboutBody(
                  aboutText: () {
                    final text = _plainAbout(info.about);
                    return text.isEmpty
                        ? 'Art Inspiration — منصة عراقية راقية لمستحضرات التجميل والعناية، نجمع لك أفضل البراندات العالمية والمحلية في مكان واحد، مع تجربة شراء سلسة وتوصيل موثوق لكل المحافظات.'
                        : text;
                  }(),
                  bottomInset: bottomInset,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutBody extends StatelessWidget {
  const _AboutBody({
    required this.aboutText,
    required this.bottomInset,
  });

  final String aboutText;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AboutHero(),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 24.h + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AboutStatsRow(),
                SizedBox(height: 28.h),
                _AboutStoryCard(text: aboutText),
                SizedBox(height: 28.h),
                const _AboutValuesSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF0014FF),
            Color(0xFF3D4DFF),
            Color(0xFF7B8FE8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30.h,
            left: -20.w,
            child: _HeroOrb(size: 120.w, opacity: 0.14),
          ),
          Positioned(
            bottom: -40.h,
            right: -10.w,
            child: _HeroOrb(size: 90.w, opacity: 0.1),
          ),
          Positioned(
            top: 24.h,
            right: 24.w,
            child: _HeroOrb(size: 48.w, opacity: 0.12),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 88.w,
                    height: 88.w,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      AppAssets.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
                Text(
                  'ART INSPIRATION',
                  style: AppTextStyles.settingsMenuItem(
                    color: Colors.white.withValues(alpha: 0.72),
                  ).copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 8.h),
                Text(
                  'شريكك الموثوق\nفي عالم الجمال',
                  style: AppTextStyles.settingsSectionTitle(
                    color: Colors.white,
                  ).copyWith(
                    fontSize: 26.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 12.h),
                Text(
                  'منصة عراقية راقية تجمعك مع أفضل منتجات التجميل والعناية — بتجربة شراء سهلة، آمنة، وأنيقة.',
                  style: AppTextStyles.settingsMenuItem(
                    color: Colors.white.withValues(alpha: 0.88),
                  ).copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.7,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroOrb extends StatelessWidget {
  const _HeroOrb({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _AboutStatsRow extends StatelessWidget {
  const _AboutStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _AboutStatCard(value: '+1000', label: 'منتج'),
        SizedBox(width: 10),
        _AboutStatCard(value: '18', label: 'محافظة'),
        SizedBox(width: 10),
        _AboutStatCard(value: '100%', label: 'أصلي'),
      ],
    );
  }
}

class _AboutStatCard extends StatelessWidget {
  const _AboutStatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.settingsCardBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.orderCardShadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primary, Color(0xFF7B8FE8)],
              ).createShader(bounds),
              child: Text(
                value,
                style: AppTextStyles.settingsProfileName().copyWith(
                  color: Colors.white,
                  fontSize: 22.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.settingsMenuItem(
                color: AppColors.textSecondary,
              ).copyWith(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutStoryCard extends StatelessWidget {
  const _AboutStoryCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.settingsCardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.orderCardShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'قصتنا',
                  style: AppTextStyles.settingsMenuItem(
                    color: AppColors.primary,
                  ).copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.format_quote_rounded,
                color: AppColors.primarySoft,
                size: 28.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            text,
            style: AppTextStyles.settingsMenuItem(
              color: AppColors.textSecondary,
            ).copyWith(
              fontWeight: FontWeight.w500,
              height: 1.85,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _AboutValuesSection extends StatelessWidget {
  const _AboutValuesSection();

  static const _values = [
    (
      icon: Icons.verified_rounded,
      title: 'جودة مضمونة',
      description: 'منتجات أصلية من براندات موثوقة ومعتمدة.',
    ),
    (
      icon: Icons.local_shipping_rounded,
      title: 'توصيل سريع',
      description: 'نغطي المحافظات العراقية بخدمة توصيل موثوقة.',
    ),
    (
      icon: Icons.support_agent_rounded,
      title: 'دعم متواصل',
      description: 'فريقنا جاهز لمساعدتك في أي وقت تحتاجه.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'لماذا نحن؟',
          style: AppTextStyles.settingsSectionTitle(),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 14.h),
        ..._values.map(
          (value) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _AboutValueTile(
              icon: value.icon,
              title: value.title,
              description: value.description,
            ),
          ),
        ),
      ],
    );
  }
}

class _AboutValueTile extends StatelessWidget {
  const _AboutValueTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppColors.primaryLight.withValues(alpha: 0.45),
            AppColors.background,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.settingsCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: AppTextStyles.settingsMenuItem().copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.sp,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: AppTextStyles.settingsMenuItem(
                    color: AppColors.textSecondary,
                  ).copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    fontSize: 13.sp,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
