import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_text_styles.dart';

/// شريط أزرار التالي والتخطي في صفحة الـ Onboarding
class OnboardingActionBar extends StatelessWidget {
  const OnboardingActionBar({
    super.key,
    required this.nextLabel,
    required this.onNext,
    required this.onSkip,
    this.secondaryLabel = 'تخطي',
  });

  final String nextLabel;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String secondaryLabel;

  static const Color _barBackground = Color(0xFFEAECFC);
  static const Color _nextBackground = Color(0xFF0000FF);

  /// ارتفاع الشريط — تقرأه صفحة الـ Onboarding لتحسب المساحة الباقية.
  static double get height => 52.h;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _barBackground,
          borderRadius: BorderRadius.circular(21.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21.r),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                flex: 65,
                child: Material(
                  color: _nextBackground,
                  borderRadius: BorderRadius.circular(21.r),
                  child: InkWell(
                    onTap: onNext,
                    borderRadius: BorderRadius.circular(21.r),
                    child: SizedBox(
                      height: height,
                      child: Center(
                        child: Text(
                          nextLabel,
                          style: AppTextStyles.buttonPrimary(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 35,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onSkip,
                    child: SizedBox(
                      height: height,
                      child: Center(
                        child: Text(
                          secondaryLabel,
                          style: AppTextStyles.buttonSecondary(
                            color: _nextBackground,
                          ).copyWith(fontFamily: AppFonts.family),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
