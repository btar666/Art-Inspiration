import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/onboarding_content.dart';

/// كاروسيل صور الـ Onboarding — يعرض الشرائح المجاورة على الجانبين (RTL)
class OnboardingCarousel extends StatelessWidget {
  const OnboardingCarousel({
    super.key,
    required this.carouselController,
    required this.onPageChanged,
    required this.height,
  });

  final CarouselSliderController carouselController;
  final ValueChanged<int> onPageChanged;

  /// المساحة المتاحة للكاروسيل — تصغر على الشاشات القصيرة.
  final double height;

  /// الفراغ الذي يحتاجه enlargeCenterPage فوق البطاقة وتحتها.
  static double get _gutter => 24.h;

  static double get _designCardHeight => 280.w * (4 / 3);

  /// الارتفاع المرسوم في التصميم — السقف الذي لا يتجاوزه الكاروسيل.
  static double get designHeight => _designCardHeight + _gutter;

  @override
  Widget build(BuildContext context) {
    // البطاقة تحافظ على نسبة 3:4 مهما ضاقت المساحة.
    final cardHeight = math.max(0.0, height - _gutter);
    final cardWidth = cardHeight * (3 / 4);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: CarouselSlider.builder(
        carouselController: carouselController,
        itemCount: OnboardingContent.items.length,
        options: CarouselOptions(
          height: height,
          viewportFraction: 0.72,
          enlargeCenterPage: true,
          enlargeFactor: 0.18,
          enableInfiniteScroll: false,
          padEnds: true,
          clipBehavior: Clip.none,
          onPageChanged: (index, _) => onPageChanged(index),
        ),
        itemBuilder: (context, index, _) {
          return Center(
            child: _CarouselCard(
              item: OnboardingContent.items[index],
              width: cardWidth,
              height: cardHeight,
            ),
          );
        },
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({
    required this.item,
    required this.width,
    required this.height,
  });

  final OnboardingItem item;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: item.imageAsset != null
            ? SvgPicture.asset(
                item.imageAsset!,
                width: width,
                height: height,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                placeholderBuilder: (_) =>
                    SizedBox(width: width, height: height),
              )
            : Container(
                color: item.accentColor,
                alignment: Alignment.center,
                child: Stack(
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
              ),
      ),
    ).animate(key: ValueKey(item.title)).fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
