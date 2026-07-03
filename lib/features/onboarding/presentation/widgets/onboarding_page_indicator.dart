import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/app_colors.dart';

/// مؤشر الصفحات — نقاط + كapsule للصفحة النشطة
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.pageController,
    required this.count,
  });

  final PageController pageController;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: pageController,
      count: count,
      effect: ExpandingDotsEffect(
        activeDotColor: AppColors.primary,
        dotColor: AppColors.dotInactive,
        dotHeight: 8.h,
        dotWidth: 8.w,
        expansionFactor: 4,
        spacing: 8.w,
        radius: 4.r,
      ),
    );
  }
}
