import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/skeleton/skeleton_image_placeholder.dart';
import '../../../explore/data/models/explore_models.dart';
import '../../../explore/presentation/providers/explore_tab_provider.dart';
import '../providers/products_provider.dart';
import 'home_catalog_strips_metrics.dart';

/// صفوف أفقية للفئات ثم البراندات أسفل السلايدر
///
/// يقرأ الكتالوج بنفسه بدل استقباله كوسيط، حتى يمرّره [HomeContent] كـ const.
/// المُنشئ الثابت يعني أن فلاتر يتخطّى هذه الشجرة كاملةً عند أي إعادة بناء
/// للصفحة الأم — وهي شجرة غالية: صفّان أفقيان بصور شبكية. قياساً: إعادة بناء
/// واحدة للصفحة كانت تكلّف إطاراً بطول 128 مللي ثانية.
class HomeCatalogStrips extends ConsumerWidget {
  const HomeCatalogStrips({super.key});

  void _openExplore(WidgetRef ref, BuildContext context, ExploreTab tab) {
    ref.read(exploreTabProvider.notifier).state = tab;
    context.go(AppRoutes.explore);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    if (catalog == null) return const SizedBox.shrink();

    final sections = catalog.sectionNames;
    final brands = catalog.brands.where((b) => b.trim().isNotEmpty).toList();

    if (sections.isEmpty && brands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sections.isNotEmpty)
          _CatalogStrip(
            title: 'الأقسام',
            titleTop: HomeCatalogStripsMetrics.titleTop(),
            listHeight: HomeCatalogStripsMetrics.categoryListHeight(),
            itemGap: HomeCatalogStripsMetrics.itemGap(),
            onViewAll: () => _openExplore(ref, context, ExploreTab.sections),
            itemCount: sections.length,
            itemBuilder: (index) {
              final name = sections[index];
              return _CategoryItem(
                label: name,
                imageUrl: catalog.imageForCategory(name),
                onTap: () =>
                    context.push(AppRoutes.exploreSectionPath(name)),
              );
            },
          ),
        if (brands.isNotEmpty)
          _CatalogStrip(
            title: 'برانداتنا',
            titleTop: sections.isEmpty
                ? HomeCatalogStripsMetrics.titleTop()
                : HomeCatalogStripsMetrics.sectionsToBrandsGap(),
            listHeight: HomeCatalogStripsMetrics.brandListHeight(),
            itemGap: HomeCatalogStripsMetrics.brandItemGap(),
            onViewAll: () => _openExplore(ref, context, ExploreTab.brands),
            itemCount: brands.length,
            itemBuilder: (index) {
              final name = brands[index];
              return _BrandItem(
                label: name,
                imageUrl: catalog.imageForBrand(name),
                onTap: () =>
                    context.push(AppRoutes.exploreSectionPath(name)),
              );
            },
          ),
      ],
    );
  }
}

class _CatalogStrip extends StatelessWidget {
  const _CatalogStrip({
    required this.title,
    required this.titleTop,
    required this.listHeight,
    required this.itemGap,
    required this.onViewAll,
    required this.itemCount,
    required this.itemBuilder,
  });

  final String title;
  final double titleTop;
  final double listHeight;
  final double itemGap;
  final VoidCallback onViewAll;
  final int itemCount;
  final Widget Function(int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            titleTop,
            20.w,
            HomeCatalogStripsMetrics.titleBottom(),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(title, style: AppTextStyles.homeSectionTitle()),
              ),
              GestureDetector(
                onTap: onViewAll,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'عرض الكل',
                      style: AppTextStyles.homeProductCategory(
                        color: Colors.black.withValues(alpha: 0.5),
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 18.sp,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            clipBehavior: Clip.none,
            padding: HomeCatalogStripsMetrics.listPadding(),
            scrollDirection: Axis.horizontal,
            cacheExtent: 120,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemCount: itemCount,
            separatorBuilder: (_, __) =>
                SizedBox(width: itemGap),
            itemBuilder: (context, index) => itemBuilder(index),
          ),
        ),
      ],
    );
  }
}

/// مربع الفئة — اللون من لوحة التطبيق والصورة داخله والاسم أسفله
class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.onTap,
    this.imageUrl,
  });

  final String label;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = HomeCatalogStripsMetrics.categoryBoxSize();
    final radius = BorderRadius.circular(
      HomeCatalogStripsMetrics.categoryRadius(),
    );

    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: HomeCatalogStripsMetrics.categoryFill(),
                borderRadius: radius,
                boxShadow: HomeCatalogStripsMetrics.containerShadow(),
              ),
              padding: EdgeInsets.all(6.w),
              child: _CategoryVisual(label: label, imageUrl: imageUrl),
            ),
            SizedBox(height: HomeCatalogStripsMetrics.categoryLabelGap()),
            SizedBox(
              height: HomeCatalogStripsMetrics.categoryLabelHeight(),
              child: Text(
                label,
                style: AppTextStyles.homeProductCategory().copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.sp,
                  color: AppColors.homeSectionTitle,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _CategoryVisual extends StatelessWidget {
  const _CategoryVisual({required this.label, this.imageUrl});

  final String label;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    if (url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        fadeInDuration: Duration.zero,
        placeholder: (_, __) => SkeletonImagePlaceholder(
          borderRadius: BorderRadius.circular(
            HomeCatalogStripsMetrics.categoryRadius(),
          ),
          animated: false,
        ),
        errorWidget: (_, __, ___) => _LetterMark(label: label),
      );
    }
    return _LetterMark(label: label);
  }
}

/// كرت البراند — صورة كاملة إن وُجدت، وإلا الاسم
class _BrandItem extends StatelessWidget {
  const _BrandItem({
    required this.label,
    required this.onTap,
    this.imageUrl,
  });

  final String label;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(
      HomeCatalogStripsMetrics.brandRadius(),
    );
    final url = imageUrl?.trim() ?? '';
    final hasImage = url.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: HomeCatalogStripsMetrics.brandWidth(),
        height: HomeCatalogStripsMetrics.brandHeight(),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: radius,
          boxShadow: HomeCatalogStripsMetrics.containerShadow(),
        ),
        alignment: Alignment.center,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: url,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                fadeInDuration: Duration.zero,
                placeholder: (_, __) => SkeletonImagePlaceholder(
                  borderRadius: BorderRadius.circular(
                    HomeCatalogStripsMetrics.brandRadius(),
                  ),
                  animated: false,
                ),
                errorWidget: (_, __, ___) => _BrandName(label: label),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: _BrandName(label: label),
              ),
      ),
    );
  }
}

class _BrandName extends StatelessWidget {
  const _BrandName({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.exploreBrandLabel().copyWith(
        fontSize: 12.sp,
        color: AppColors.primary,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _LetterMark extends StatelessWidget {
  const _LetterMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final letter = label.trim().isEmpty ? '?' : label.trim().characters.first;
    return Center(
      child: Text(
        letter,
        style: AppTextStyles.homeSectionTitle().copyWith(
          fontSize: 22.sp,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
