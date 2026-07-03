import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_text_styles.dart';

/// بانر ترويجي متحرك
class HomePromoBanner extends StatefulWidget {
  const HomePromoBanner({super.key});

  @override
  State<HomePromoBanner> createState() => _HomePromoBannerState();
}

class _HomePromoBannerState extends State<HomePromoBanner> {
  int _currentIndex = 0;
  final _controller = CarouselSliderController();

  static const _banners = [
    _BannerData(
      title: 'DISCOVER YOUR BEAUTY',
      subtitle: 'اكتشفي جمالك مع أفضل منتجات العناية',
    ),
    _BannerData(
      title: 'NEW COLLECTION',
      subtitle: 'تشكيلة جديدة من مستحضرات التجميل',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Column(
        children: [
          CarouselSlider.builder(
            carouselController: _controller,
            itemCount: _banners.length,
            options: CarouselOptions(
              height: 150.h,
              viewportFraction: 1,
              enlargeCenterPage: false,
              onPageChanged: (index, _) => setState(() => _currentIndex = index),
            ),
            itemBuilder: (context, index, _) => _BannerCard(data: _banners[index]),
          ),
          SizedBox(height: 10.h),
          AnimatedSmoothIndicator(
            activeIndex: _currentIndex,
            count: _banners.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.primary,
              dotColor: AppColors.dotInactive,
              dotHeight: 6.h,
              dotWidth: 6.w,
              expansionFactor: 3,
              spacing: 6.w,
            ),
            onDotClicked: (index) => _controller.animateToPage(index),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  const _BannerData({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.data});

  final _BannerData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.homeBannerBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.homeLogoTitle().copyWith(fontSize: 14.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  data.subtitle,
                  style: AppTextStyles.homeProductDescription(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'تسوقي الآن',
                        style: TextStyle(
                          fontFamily: AppFonts.family,
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 10.sp),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 100.w,
            height: 110.h,
            decoration: BoxDecoration(
              color: AppColors.homeLavender,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 8.h,
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Icon(Icons.spa_outlined, size: 48.sp, color: AppColors.primary.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
