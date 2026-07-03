import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// رأس بصري لصفحات المعلومات (من نحن، تواصل، مساعدة)
class InfoPageHero extends StatelessWidget {
  const InfoPageHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.gradientColors,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [
          AppColors.primaryLight,
          AppColors.surface,
          AppColors.background,
        ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 36.h, 24.w, 32.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: colors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.productStore.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.productStore,
                size: 34.sp,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: AppTextStyles.settingsSectionTitle().copyWith(
              fontSize: 22.sp,
              height: 1.35,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 10.h),
          Text(
            subtitle,
            style: AppTextStyles.settingsMenuItem(
              color: AppColors.textSecondary,
            ).copyWith(
              fontWeight: FontWeight.w500,
              height: 1.65,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

/// شارة إحصائية صغيرة
class InfoStatChip extends StatelessWidget {
  const InfoStatChip({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.settingsCardBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.orderCardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.settingsProfileName().copyWith(
                color: AppColors.productStore,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.settingsMenuItem(
                color: AppColors.textSecondary,
              ).copyWith(fontSize: 11.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// عنوان قسم مع شارة اختيارية
class InfoSectionTitle extends StatelessWidget {
  const InfoSectionTitle({
    super.key,
    required this.title,
    this.badge,
  });

  final String title;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (badge != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              badge!,
              style: AppTextStyles.settingsMenuItem(
                color: AppColors.productStore,
              ).copyWith(fontSize: 11.sp),
            ),
          ),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.settingsSectionTitle(),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// بطاقة زجاجية شفافة
class InfoGlassCard extends StatelessWidget {
  const InfoGlassCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: AppColors.orderDetailCardBorder,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.orderCardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// عنصر قيمة في بطاقة من نحن
class InfoValueTile extends StatelessWidget {
  const InfoValueTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(icon, color: AppColors.productStore, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: AppTextStyles.settingsMenuItem().copyWith(
                  fontWeight: FontWeight.w800,
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
                  height: 1.6,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// بطاقة قناة تواصل
class InfoContactTile extends StatelessWidget {
  const InfoContactTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.orderDetailCardBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.orderCardShadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
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
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      style: AppTextStyles.settingsMenuItem().copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// سؤال شائع قابل للتوسيع
class InfoFaqTile extends StatefulWidget {
  const InfoFaqTile({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  State<InfoFaqTile> createState() => _InfoFaqTileState();
}

class _InfoFaqTileState extends State<InfoFaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.settingsCardBorder),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.orderCardShadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      _expanded
                          ? Icons.remove_circle_outline_rounded
                          : Icons.add_circle_outline_rounded,
                      color: AppColors.productStore,
                      size: 22.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        widget.question,
                        style: AppTextStyles.settingsMenuItem().copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                if (_expanded) ...[
                  SizedBox(height: 10.h),
                  Text(
                    widget.answer,
                    style: AppTextStyles.settingsMenuItem(
                      color: AppColors.textSecondary,
                    ).copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.65,
                    ),
                    textAlign: TextAlign.right,
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
