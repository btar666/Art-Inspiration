import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../app_api/models/app_info_model.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';
import '../widgets/info_page_widgets.dart';

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
      backgroundColor: AppColors.settingsPageBackground,
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
                  info: info,
                  aboutText: () {
                    final text = _plainAbout(info.about);
                    return text.isEmpty
                        ? 'Art Inspiration — منصة عراقية راقية لمستحضرات التجميل والعناية.'
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
    required this.info,
    required this.aboutText,
    required this.bottomInset,
  });

  final AppInfoModel info;
  final String aboutText;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InfoPageHero(
            icon: Icons.verified_outlined,
            title: 'شريكك الموثوق\nفي عالم الجمال',
            subtitle:
                'منصة عراقية راقية تجمعك مع أفضل منتجات التجميل والعناية — بتجربة شراء سهلة وآمنة.',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.w,
              24.h,
              16.w,
              24.h + bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const InfoSectionTitle(
                  title: 'قصتنا',
                  badge: 'من نحن',
                ),
                SizedBox(height: 14.h),
                InfoGlassCard(
                  child: Text(
                    aboutText,
                    style: AppTextStyles.settingsMenuItem(
                      color: AppColors.textSecondary,
                    ).copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.75,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 24.h),
                InfoContactTile(
                  icon: Icons.language_rounded,
                  iconColor: AppColors.productStore,
                  iconBg: AppColors.primaryLight,
                  title: 'الموقع',
                  value: info.website.isEmpty
                      ? 'art-inspiration.com'
                      : info.website,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
