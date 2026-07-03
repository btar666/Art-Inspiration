import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../widgets/info_page_widgets.dart';

/// صفحة تواصل معنا
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const InfoPageHero(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'نحن هنا\nلخدمتك دائماً',
                      subtitle:
                          'فريق الدعم جاهز للإجابة على استفساراتك ومساعدتك في أي وقت — بأسلوب محترف وودّي.',
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
                          const InfoContactTile(
                            icon: Icons.phone_in_talk_rounded,
                            iconColor: AppColors.productStore,
                            iconBg: AppColors.primaryLight,
                            title: 'الهاتف',
                            value: '0770 000 0000',
                          ),
                          SizedBox(height: 10.h),
                          const InfoContactTile(
                            icon: Icons.mail_outline_rounded,
                            iconColor: Color(0xFF5C6BC0),
                            iconBg: Color(0xFFEEF0FB),
                            title: 'البريد الإلكتروني',
                            value: 'support@dentalstore.iq',
                          ),
                          SizedBox(height: 10.h),
                          const InfoContactTile(
                            icon: Icons.chat_rounded,
                            iconColor: Color(0xFF25D366),
                            iconBg: Color(0xFFE8F9EF),
                            title: 'واتساب',
                            value: 'راسلنا مباشرة',
                          ),
                          SizedBox(height: 10.h),
                          const InfoContactTile(
                            icon: Icons.camera_alt_outlined,
                            iconColor: Color(0xFFE1306C),
                            iconBg: Color(0xFFFDEEF3),
                            title: 'انستغرام',
                            value: '@dental_store_iq',
                          ),
                          SizedBox(height: 28.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: AppColors.orderDetailCardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52.w,
                                  height: 52.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Icon(
                                    Icons.support_agent_rounded,
                                    color: AppColors.productStore,
                                    size: 28.sp,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'متوسط وقت الرد',
                                        style: AppTextStyles.settingsMenuItem(
                                          color: AppColors.textSecondary,
                                        ).copyWith(fontSize: 12.sp),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'أقل من 30 دقيقة',
                                        style: AppTextStyles.settingsMenuItem()
                                            .copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.productTitle,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
