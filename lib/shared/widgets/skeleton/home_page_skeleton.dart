import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/home/presentation/widgets/home_catalog_strips_metrics.dart';
import '../../../features/home/presentation/widgets/home_product_card_metrics.dart';
import '../../../features/home/presentation/widgets/home_scroll_metrics.dart';
import 'product_card_skeleton.dart';
import 'skeleton_shimmer.dart';

/// skeleton الصفحة الرئيسية أثناء تحميل الكatalog
class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({
    super.key,
    this.topInset = 0,
    this.bottomInset = 0,
  });

  final double topInset;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final cardWidth = HomeProductCardMetrics.width();
    final cardHeight = HomeProductCardMetrics.height();
    final heroHeight = HomeScrollMetrics.heroHeight(
      topInset,
      MediaQuery.sizeOf(context),
    );
    final headerTop = topInset + 8.h;

    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(
                  child: SkeletonBox(borderRadius: BorderRadius.zero),
                ),
                Positioned(
                  top: headerTop,
                  left: 28.w,
                  right: 52.w,
                  child: SkeletonBox(
                    height: HomeScrollMetrics.searchBarHeight(),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
              ],
            ),
          ),
          _CatalogStripSkeleton(
            titleWidth: 72.w,
            itemWidth: HomeCatalogStripsMetrics.categoryBoxSize(),
            itemHeight: HomeCatalogStripsMetrics.categoryBoxSize(),
            labelHeight: HomeCatalogStripsMetrics.categoryLabelHeight(),
            listHeight: HomeCatalogStripsMetrics.categoryListHeight(),
            itemCount: 4,
            itemRadius: HomeCatalogStripsMetrics.categoryRadius(),
          ),
          _CatalogStripSkeleton(
            titleWidth: 88.w,
            itemWidth: HomeCatalogStripsMetrics.brandWidth(),
            itemHeight: HomeCatalogStripsMetrics.brandHeight(),
            labelHeight: 0,
            listHeight: HomeCatalogStripsMetrics.brandListHeight(),
            itemCount: 3,
            itemRadius: HomeCatalogStripsMetrics.brandRadius(),
            topGap: HomeCatalogStripsMetrics.sectionsToBrandsGap(),
          ),
          _FeaturedStripSkeleton(
            cardWidth: cardWidth,
            cardHeight: cardHeight,
          ),
          _FeaturedStripSkeleton(
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            topGap: 4.h,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 12.h),
            child: SkeletonLine(width: 110.w, height: 18.h),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h + bottomInset),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14.h,
                crossAxisSpacing: 14.w,
                childAspectRatio: HomeProductCardMetrics.aspectRatio(),
              ),
              itemCount: 6,
              itemBuilder: (_, __) => const ProductCardSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogStripSkeleton extends StatelessWidget {
  const _CatalogStripSkeleton({
    required this.titleWidth,
    required this.itemWidth,
    required this.itemHeight,
    required this.labelHeight,
    required this.listHeight,
    required this.itemCount,
    required this.itemRadius,
    this.topGap = 0,
  });

  final double titleWidth;
  final double itemWidth;
  final double itemHeight;
  final double labelHeight;
  final double listHeight;
  final int itemCount;
  final double itemRadius;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: HomeCatalogStripsMetrics.titleTop() + topGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              0,
              20.w,
              HomeCatalogStripsMetrics.titleBottom(),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: SkeletonLine(width: titleWidth, height: 16.h),
            ),
          ),
          SizedBox(
            height: listHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: HomeCatalogStripsMetrics.listPadding(),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (_, __) =>
                  SizedBox(width: HomeCatalogStripsMetrics.itemGap()),
              itemBuilder: (_, __) => Column(
                children: [
                  SkeletonBox(
                    width: itemWidth,
                    height: itemHeight,
                    borderRadius: BorderRadius.circular(itemRadius),
                  ),
                  if (labelHeight > 0) ...[
                    SizedBox(height: HomeCatalogStripsMetrics.categoryLabelGap()),
                    SkeletonLine(
                      width: itemWidth * 0.7,
                      height: labelHeight,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedStripSkeleton extends StatelessWidget {
  const _FeaturedStripSkeleton({
    required this.cardWidth,
    required this.cardHeight,
    this.topGap = 0,
  });

  final double cardWidth;
  final double cardHeight;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h + topGap, 20.w, 10.h),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SkeletonLine(width: 120.w, height: 18.h),
                ),
              ),
              SkeletonLine(width: 56.w, height: 12.h),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (_, __) => SizedBox(
              width: cardWidth,
              child: const ProductCardSkeleton(),
            ),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

/// skeleton بانر الترويج — هيرو بعرض الشاشة
class HomeBannerSkeleton extends StatelessWidget {
  const HomeBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: SkeletonBox(borderRadius: BorderRadius.zero),
    );
  }
}

/// skeleton أقسام/براندات مميزة — شريطان أفقيان
class HomeFeaturedSectionsLoadingSkeleton extends StatelessWidget {
  const HomeFeaturedSectionsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeFeaturedStripSkeleton(),
        HomeFeaturedStripSkeleton(),
      ],
    );
  }
}

/// skeleton شريط منتجات مميزة أفقي
class HomeFeaturedStripSkeleton extends StatelessWidget {
  const HomeFeaturedStripSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cardWidth = HomeProductCardMetrics.width();
    final cardHeight = HomeProductCardMetrics.height();

    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SkeletonLine(width: 120.w, height: 18.h),
                  ),
                ),
                SkeletonLine(width: 56.w, height: 12.h),
              ],
            ),
          ),
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (_, __) => SizedBox(
                width: cardWidth,
                child: const ProductCardSkeleton(),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
