import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../app_api/models/slider_item_model.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';

/// بانر ترويجي متحرك — من api/slider
class HomePromoBanner extends ConsumerStatefulWidget {
  const HomePromoBanner({super.key});

  @override
  ConsumerState<HomePromoBanner> createState() => _HomePromoBannerState();
}

class _HomePromoBannerState extends ConsumerState<HomePromoBanner> {
  int _currentIndex = 0;
  final _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final sliderAsync = ref.watch(sliderProvider);

    return sliderAsync.when(
      loading: () => _BannerShell(
        child: Center(
          child: SizedBox(
            width: 28.w,
            height: 28.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => _BannerShell(
        child: _FallbackBanner(onRetry: () => ref.invalidate(sliderProvider)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return _BannerShell(child: _FallbackBanner(onRetry: null));
        }
        return _SliderBanner(
          items: items,
          currentIndex: _currentIndex,
          controller: _controller,
          onPageChanged: (index) => setState(() => _currentIndex = index),
        );
      },
    );
  }
}

class _SliderBanner extends StatelessWidget {
  const _SliderBanner({
    required this.items,
    required this.currentIndex,
    required this.controller,
    required this.onPageChanged,
  });

  final List<SliderItemModel> items;
  final int currentIndex;
  final CarouselSliderController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
      child: Column(
        children: [
          CarouselSlider.builder(
            carouselController: controller,
            itemCount: items.length,
            options: CarouselOptions(
              height: 150.h,
              viewportFraction: 1,
              enlargeCenterPage: false,
              autoPlay: items.length > 1,
              onPageChanged: (index, _) => onPageChanged(index),
            ),
            itemBuilder: (context, index, _) {
              final item = items[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: ColoredBox(
                  color: AppColors.homeBannerBg,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        memCacheWidth:
                            (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context))
                                .round()
                                .clamp(1, 2048),
                        memCacheHeight:
                            (150.h * MediaQuery.devicePixelRatioOf(context))
                                .round()
                                .clamp(1, 2048),
                        fadeInDuration: const Duration(milliseconds: 120),
                        fadeOutDuration: Duration.zero,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.image_outlined,
                          size: 40.sp,
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      if (item.title.trim().isNotEmpty)
                        Positioned(
                          left: 12.w,
                          right: 12.w,
                          bottom: 12.h,
                          child: Text(
                            item.title,
                            style: AppTextStyles.homeLogoTitle().copyWith(
                              fontSize: 13.sp,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (items.length > 1) ...[
            SizedBox(height: 10.h),
            AnimatedSmoothIndicator(
              activeIndex: currentIndex.clamp(0, items.length - 1),
              count: items.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: AppColors.dotInactive,
                dotHeight: 6.h,
                dotWidth: 6.w,
                expansionFactor: 3,
                spacing: 6.w,
              ),
              onDotClicked: (index) => controller.animateToPage(index),
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerShell extends StatelessWidget {
  const _BannerShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 0),
      child: Container(
        height: 150.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.homeBannerBg,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: child,
      ),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner({required this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ART INSPIRATION',
                  style: AppTextStyles.homeLogoTitle().copyWith(fontSize: 14.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  'اكتشفي جمالك مع أفضل منتجات العناية',
                  style: AppTextStyles.homeProductDescription(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (onRetry != null) ...[
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: onRetry,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: AppFonts.family,
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.spa_outlined,
            size: 48.sp,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
