import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/whatsapp_link.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../app_api/models/app_info_model.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';

/// صفحة تواصل معنا — من api/info
class ContactUsPage extends ConsumerWidget {
  const ContactUsPage({super.key});

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

  String get _phone => _display(info.phone, fallback: '');
  String get _email => _display(info.email, fallback: '');
  String get _instagram => _display(info.instagram, fallback: '');

  String get _whatsappDisplay {
    final whatsapp = info.whatsapp.trim();
    if (whatsapp.isNotEmpty && whatsapp != '#') return whatsapp;
    return _phone.isNotEmpty ? _phone : 'راسلنا على واتساب';
  }

  Future<void> _launchUri(
    BuildContext context,
    Uri? uri, {
    required String errorMessage,
  }) async {
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    try {
      var launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _openPhone(BuildContext context) async {
    final phone = _phone;
    if (phone.isEmpty || phone == '—') {
      await _launchUri(context, null, errorMessage: 'رقم الهاتف غير متوفر');
      return;
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    await _launchUri(
      context,
      Uri.parse('tel:$digits'),
      errorMessage: 'تعذر فتح الهاتف',
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final email = _email;
    if (email.isEmpty || email == '—') {
      await _launchUri(context, null, errorMessage: 'البريد غير متوفر');
      return;
    }
    await _launchUri(
      context,
      Uri(scheme: 'mailto', path: email),
      errorMessage: 'تعذر فتح البريد',
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = WhatsAppLink.buildUri(
      info.whatsapp,
      fallbackPhone: info.phone,
    );
    await _launchUri(context, uri, errorMessage: 'تعذر فتح واتساب');
  }

  Future<void> _openInstagram(BuildContext context) async {
    final raw = _instagram;
    if (raw.isEmpty || raw == '—' || raw == 'قريباً') {
      await _launchUri(context, null, errorMessage: 'حساب انستغرام غير متوفر');
      return;
    }

    final uri = raw.startsWith('http')
        ? Uri.tryParse(raw)
        : Uri.tryParse('https://instagram.com/${raw.replaceAll('@', '')}');
    await _launchUri(context, uri, errorMessage: 'تعذر فتح انستغرام');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ContactHero(),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 24.h + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'قنوات التواصل',
                  style: AppTextStyles.settingsSectionTitle(),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 6.h),
                Text(
                  'اختر الطريقة الأنسب للتواصل مع فريقنا',
                  style: AppTextStyles.settingsMenuItem(
                    color: AppColors.textSecondary,
                  ).copyWith(fontSize: 13.sp),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 16.h),
                _ContactChannelCard(
                  icon: Icons.phone_in_talk_rounded,
                  title: 'الهاتف',
                  value: _display(info.phone),
                  accent: AppColors.primary,
                  accentBg: AppColors.primaryLight,
                  onTap: () => _openPhone(context),
                ),
                SizedBox(height: 10.h),
                _ContactChannelCard(
                  icon: Icons.mail_outline_rounded,
                  title: 'البريد الإلكتروني',
                  value: _display(info.email),
                  accent: const Color(0xFF5C6BC0),
                  accentBg: const Color(0xFFEEF0FB),
                  onTap: () => _openEmail(context),
                ),
                SizedBox(height: 10.h),
                _ContactChannelCard(
                  icon: Icons.chat_rounded,
                  title: 'واتساب',
                  value: _whatsappDisplay,
                  accent: const Color(0xFF25D366),
                  accentBg: const Color(0xFFE8F9EF),
                  onTap: () => _openWhatsApp(context),
                ),
                SizedBox(height: 10.h),
                _ContactChannelCard(
                  icon: Icons.camera_alt_outlined,
                  title: 'انستغرام',
                  value: _display(info.instagram, fallback: 'قريباً'),
                  accent: const Color(0xFFE1306C),
                  accentBg: const Color(0xFFFDEEF3),
                  onTap: () => _openInstagram(context),
                ),
                SizedBox(height: 10.h),
                _ContactChannelCard(
                  icon: Icons.location_on_outlined,
                  title: 'العنوان',
                  value: _display(info.address),
                  accent: AppColors.primary,
                  accentBg: AppColors.primaryLight,
                ),
                SizedBox(height: 20.h),
                const _ContactSupportNote(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactHero extends StatelessWidget {
  const _ContactHero();

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
            Color(0xFF1A1A2E),
            Color(0xFF2D3A8C),
            Color(0xFF5C6BC0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3A8C).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24.h,
            left: -16.w,
            child: _ContactHeroOrb(size: 110.w, opacity: 0.12),
          ),
          Positioned(
            bottom: -36.h,
            right: -8.w,
            child: _ContactHeroOrb(size: 84.w, opacity: 0.1),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: 72.w,
                      height: 72.w,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Icon(
                          Icons.headset_mic_rounded,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                Text(
                  'نحن هنا لخدمتك دائماً',
                  style: AppTextStyles.settingsSectionTitle(
                    color: Colors.white,
                  ).copyWith(
                    fontSize: 24.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 10.h),
                Text(
                  'فريق الدعم جاهز للإجابة على استفساراتك ومساعدتك في أي وقت — بكل احترافية واهتمام.',
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

class _ContactHeroOrb extends StatelessWidget {
  const _ContactHeroOrb({
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

class _ContactChannelCard extends StatelessWidget {
  const _ContactChannelCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
    required this.accentBg,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accent;
  final Color accentBg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.settingsCardBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.orderCardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: accent, size: 24.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.settingsMenuItem(
                          color: AppColors.textSecondary,
                        ).copyWith(fontSize: 12.sp),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        value,
                        style: AppTextStyles.settingsMenuItem().copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: 8.w),
                  Transform.rotate(
                    angle: pi,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textSecondary.withValues(alpha: 0.45),
                      size: 14.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactSupportNote extends StatelessWidget {
  const _ContactSupportNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppColors.primaryLight.withValues(alpha: 0.55),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.settingsCardBorder),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.schedule_rounded,
            color: AppColors.primary,
            size: 22.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'أوقات الاستجابة: يومياً من 9 صباحاً حتى 10 مساءً. نسعد بخدمتك دائماً.',
              style: AppTextStyles.settingsMenuItem(
                color: AppColors.textSecondary,
              ).copyWith(
                fontWeight: FontWeight.w500,
                height: 1.65,
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
