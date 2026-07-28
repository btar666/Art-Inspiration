import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/whatsapp_link.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../app_api/models/app_info_model.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';
import '../widgets/info_page_widgets.dart';

/// صفحة تواصل معنا — من api/info
class ContactUsPage extends ConsumerWidget {
  const ContactUsPage({super.key});

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
              title: 'تواصل معنا',
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
                data: (info) => _ContactBody(
                  info: info,
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

class _ContactBody extends StatelessWidget {
  const _ContactBody({
    required this.info,
    required this.bottomInset,
  });

  final AppInfoModel info;
  final double bottomInset;

  String _display(String value, {String fallback = '—'}) {
    final text = value.trim();
    if (text.isEmpty || text == '#') return fallback;
    return text;
  }

  String get _whatsappDisplay {
    final whatsapp = info.whatsapp.trim();
    if (whatsapp.isNotEmpty && whatsapp != '#') return whatsapp;
    return _display(info.phone, fallback: 'راسلنا على واتساب');
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = WhatsAppLink.buildUri(
      info.whatsapp,
      fallbackPhone: info.phone,
    );

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم واتساب غير متوفر')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح واتساب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InfoPageHero(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'نحن هنا\nلخدمتك دائماً',
            subtitle:
                'فريق الدعم جاهز للإجابة على استفساراتك ومساعدتك في أي وقت.',
            gradientColors: [
              Color(0xFFF3F0E8),
              Color(0xFFFAF8F4),
              Colors.white,
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const InfoSectionTitle(
                  title: 'قنوات التواصل',
                  badge: 'مباشر',
                ),
                SizedBox(height: 14.h),
                InfoContactTile(
                  icon: Icons.phone_in_talk_rounded,
                  iconColor: AppColors.productStore,
                  iconBg: AppColors.primaryLight,
                  title: 'الهاتف',
                  value: _display(info.phone),
                ),
                SizedBox(height: 10.h),
                InfoContactTile(
                  icon: Icons.mail_outline_rounded,
                  iconColor: const Color(0xFF5C6BC0),
                  iconBg: const Color(0xFFEEF0FB),
                  title: 'البريد الإلكتروني',
                  value: _display(info.email),
                ),
                SizedBox(height: 10.h),
                InfoContactTile(
                  icon: Icons.chat_rounded,
                  iconColor: const Color(0xFF25D366),
                  iconBg: const Color(0xFFE8F9EF),
                  title: 'واتساب',
                  value: _whatsappDisplay,
                  onTap: () => _openWhatsApp(context),
                ),
                SizedBox(height: 10.h),
                InfoContactTile(
                  icon: Icons.camera_alt_outlined,
                  iconColor: const Color(0xFFE1306C),
                  iconBg: const Color(0xFFFDEEF3),
                  title: 'انستغرام',
                  value: _display(info.instagram, fallback: 'قريباً'),
                ),
                SizedBox(height: 10.h),
                InfoContactTile(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.primaryLight,
                  title: 'العنوان',
                  value: _display(info.address),
                ),
                SizedBox(height: 10.h),
                InfoContactTile(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF5C6BC0),
                  iconBg: const Color(0xFFEEF0FB),
                  title: 'الموقع',
                  value: _display(info.website),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
