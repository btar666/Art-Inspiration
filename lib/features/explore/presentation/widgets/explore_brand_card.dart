import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/explore_models.dart';
import 'explore_brand_card_metrics.dart';

/// كارد براند — كونتينر علوي للشعار + كونتينر سفلي للاسم
class ExploreBrandCard extends StatelessWidget {
  const ExploreBrandCard({
    super.key,
    required this.brand,
    this.onTap,
  });

  final ExploreBrandModel brand;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: ExploreBrandCardMetrics.cardWidth(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BrandLogoContainer(brand: brand),
              SizedBox(height: ExploreBrandCardMetrics.gapHeight()),
              _BrandLabelContainer(brand: brand),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandLogoContainer extends StatelessWidget {
  const _BrandLogoContainer({required this.brand});

  final ExploreBrandModel brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ExploreBrandCardMetrics.cardWidth(),
      height: ExploreBrandCardMetrics.logoContainerHeight(),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: ExploreBrandCardMetrics.logoBorderRadius(),
        boxShadow: ExploreBrandCardMetrics.logoCardShadow(),
      ),
      padding: ExploreBrandCardMetrics.logoPadding(),
      alignment: Alignment.center,
      child: brand.logoAsset != null
          ? Image.asset(
              brand.logoAsset!,
              fit: BoxFit.contain,
            )
          : Text(
              brand.name,
              style: AppTextStyles.exploreBrandLogo().copyWith(
                fontSize: 28.sp,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }
}

class _BrandLabelContainer extends StatelessWidget {
  const _BrandLabelContainer({required this.brand});

  final ExploreBrandModel brand;

  @override
  Widget build(BuildContext context) {
    final chevronSize = ExploreBrandCardMetrics.chevronSize();

    return Container(
      width: ExploreBrandCardMetrics.cardWidth(),
      height: ExploreBrandCardMetrics.labelContainerHeight(),
      decoration: BoxDecoration(
        color: ExploreBrandCardMetrics.labelBackground,
        borderRadius: ExploreBrandCardMetrics.labelBorderRadius(),
        boxShadow: ExploreBrandCardMetrics.labelCardShadow(),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Padding(
            padding: EdgeInsets.only(left: ExploreBrandCardMetrics.chevronInset()),
            child: const _BrandChevronButton(),
          ),
          Expanded(
            child: Text(
              brand.name,
              style: AppTextStyles.exploreBrandLabel(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: chevronSize + ExploreBrandCardMetrics.chevronInset(),
          ),
        ],
      ),
    );
  }
}

class _BrandChevronButton extends StatelessWidget {
  const _BrandChevronButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ExploreBrandCardMetrics.chevronSize(),
      height: 18.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0000FF).withValues(alpha: 0.30),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Transform.rotate(
            angle: math.pi,
            child: Icon(
              Icons.chevron_left_rounded,
              size: 14.sp,
              color: AppColors.background,
            ),
          ),
        ),
      ),
    );
  }
}
