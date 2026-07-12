import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/erp_dev_session.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/storage/onboarding_storage.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/decorative_background.dart';
import '../../../../shared/widgets/sparkle_icon.dart';
import '../../data/onboarding_content.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_carousel.dart';
import '../widgets/onboarding_page_indicator.dart';

/// صفحة الـ Onboarding — 3 شرائح مع أنيميشن
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.72);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingStorageProvider).markCompleted();
    if (!mounted) return;
    context.go(
      ErpDevSession.skipLoginToHome ? AppRoutes.home : AppRoutes.login,
    );
  }

  void _onNext() {
    final currentIndex = ref.read(onboardingPageIndexProvider);
    if (currentIndex < OnboardingContent.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(onboardingPageIndexProvider);
    final item = OnboardingContent.items[currentIndex];
    final isLast = currentIndex == OnboardingContent.items.length - 1;

    return Scaffold(
      body: DecorativeBackground(
        child: Stack(
          children: [
            Positioned(
              top: 40.h,
              left: 20.w,
              child: SparkleIcon(size: 14.w, delay: 300.ms),
            ),
            Positioned(
              bottom: 100.h,
              right: 30.w,
              child: SparkleIcon(size: 12.w, filled: false, delay: 500.ms),
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 80.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: AppTextStyles.onboardingTitle(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SparkleIcon(size: 16.w, delay: 100.ms),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          item.description,
                          style: AppTextStyles.onboardingBody(),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                        ),
                      ],
                    )
                        .animate(key: ValueKey('text_$currentIndex'))
                        .fadeIn(duration: 400.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                  SizedBox(height: 56.h),
                  OnboardingCarousel(
                    pageController: _pageController,
                    currentIndex: currentIndex,
                    onPageChanged: (index) {
                      ref.read(onboardingPageIndexProvider.notifier).state =
                          index;
                    },
                  ),
                  SizedBox(height: 24.h),
                  OnboardingPageIndicator(
                    pageController: _pageController,
                    count: OnboardingContent.items.length,
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                    child: Row(
                      children: [
                        AppButton(
                          label: 'تخطي',
                          variant: AppButtonVariant.secondary,
                          onPressed: _completeOnboarding,
                        ),
                        const Spacer(),
                        AppButton(
                          label: isLast ? 'ابدئي الآن' : 'التالي',
                          variant: AppButtonVariant.primary,
                          onPressed: _onNext,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 500.ms,
                        delay: 200.ms,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
