import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/onboarding_content.dart';

/// كاروسيل صور الـ Onboarding — يعرض الشرائح المجاورة على الجانبين (RTL)
class OnboardingCarousel extends StatelessWidget {
  const OnboardingCarousel({
    super.key,
    required this.carouselController,
    required this.onPageChanged,
  });

  final CarouselSliderController carouselController;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CarouselSlider.builder(
        carouselController: carouselController,
        itemCount: OnboardingContent.items.length,
        options: CarouselOptions(
          height: 340.h,
          viewportFraction: 0.62,
          enlargeCenterPage: true,
          enlargeFactor: 0.22,
          enableInfiniteScroll: false,
          padEnds: true,
          clipBehavior: Clip.none,
          onPageChanged: (index, _) => onPageChanged(index),
        ),
        itemBuilder: (context, index, _) {
          return _CarouselCard(item: OnboardingContent.items[index]);
        },
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300.h,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: item.accentColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: item.imageAsset != null
          ? Image.asset(
              item.imageAsset!,
              width: double.infinity,
              height: 300.h,
              fit: BoxFit.cover,
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                Icon(
                  item.icon,
                  size: 64.sp,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ],
            ),
    )
        .animate(key: ValueKey(item.title))
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
