import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/onboarding_content.dart';

/// كاروسيل صور الـ Onboarding مع تأثير التكبير
class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({
    super.key,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340.h,
      child: PageView.builder(
        controller: widget.pageController,
        itemCount: OnboardingContent.items.length,
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: widget.pageController,
            builder: (context, child) {
              double value = 1;
              if (widget.pageController.position.haveDimensions) {
                value = (widget.pageController.page ?? index.toDouble()) - index;
                value = (1 - (value.abs() * 0.25)).clamp(0.75, 1.0);
              }

              return Center(
                child: Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0.6, 1.0),
                    child: child,
                  ),
                ),
              );
            },
            child: _CarouselCard(item: OnboardingContent.items[index]),
          );
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
      width: 220.w,
      height: 300.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // تأثير دائري خلفي
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
