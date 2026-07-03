import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../widgets/info_page_widgets.dart';

/// صفحة من نحن
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
              title: 'من نحن ؟',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const InfoPageHero(
                      icon: Icons.verified_outlined,
                      title: 'شريكك الموثوق\nفي عالم طب الأسنان',
                      subtitle:
                          'منصة عراقية راقية تجمع أطباء الأسنان مع أفضل المتاجر والمستلزمات الطبية الأصلية — بتجربة شراء سهلة، آمنة، ومحترفة.',
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h + bottomInset),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const InfoStatChip(value: '+500', label: 'منتج أصلي'),
                              SizedBox(width: 10.w),
                              const InfoStatChip(value: '+50', label: 'متجر معتمد'),
                              SizedBox(width: 10.w),
                              const InfoStatChip(value: '+1K', label: 'طبيب نشط'),
                            ],
                          ),
                          SizedBox(height: 28.h),
                          const InfoSectionTitle(
                            title: 'قصتنا',
                            badge: 'رؤيتنا',
                          ),
                          SizedBox(height: 14.h),
                          InfoGlassCard(
                            child: Text(
                              'وُلدت منصتنا من إيمان عميق بأن طبيب الأسنان يستحق تجربة تسوق تليق بمهنته — بعيداً عن التعقيد والمجهول. نربط العيادات بمتاجر موثوقة، ونضمن جودة المنتجات، ونسهّل الوصول إلى كل ما يحتاجه الطبيب في مكان واحد.',
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
                          const InfoSectionTitle(title: 'قيمنا'),
                          SizedBox(height: 14.h),
                          InfoGlassCard(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 8.h,
                            ),
                            child: Column(
                              children: [
                                const InfoValueTile(
                                  icon: Icons.shield_outlined,
                                  title: 'الأصالة والثقة',
                                  description:
                                      'كل منتج يمر عبر معايير صارمة لضمان الجودة والمصداقية.',
                                ),
                                Divider(
                                  height: 28.h,
                                  color: AppColors.orderCardDivider
                                      .withValues(alpha: 0.6),
                                ),
                                const InfoValueTile(
                                  icon: Icons.auto_awesome_outlined,
                                  title: 'الرقي في التجربة',
                                  description:
                                      'تصميم وخدمة تعكس احترامنا لمهنة الطب ووقت الطبيب.',
                                ),
                                Divider(
                                  height: 28.h,
                                  color: AppColors.orderCardDivider
                                      .withValues(alpha: 0.6),
                                ),
                                const InfoValueTile(
                                  icon: Icons.hub_outlined,
                                  title: 'مجتمع متكامل',
                                  description:
                                      'نبني جسراً بين الأطباء والمتاجر والموردين في بيئة واحدة.',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  AppColors.bottomNavBackground,
                                  AppColors.productStore,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.productStore
                                      .withValues(alpha: 0.28),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  '« نهدف إلى أن نكون المنصة الأولى التي يثق بها كل طبيب أسنان في العراق »',
                                  style: AppTextStyles.settingsMenuItem().copyWith(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.7,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(height: 12.h),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '— فريق المنصة',
                                    style: AppTextStyles.settingsMenuItem(
                                      color: Colors.white70,
                                    ).copyWith(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
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
