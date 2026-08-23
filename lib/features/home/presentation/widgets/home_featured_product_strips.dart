import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/connectivity_error_handler.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../data/models/home_featured_section.dart';
import '../providers/home_featured_sections_provider.dart';
import '../../../../shared/widgets/skeleton/home_page_skeleton.dart';
import 'home_product_card.dart';
import 'home_product_card_metrics.dart';

/// شرائط أفقية — قسم/براند مميز + منتجاته من art-inspiration.com
class HomeFeaturedProductStrips extends ConsumerWidget {
  const HomeFeaturedProductStrips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(homeFeaturedSectionsProvider);

    return sectionsAsync.when(
      skipLoadingOnReload: false,
      loading: () => const HomeFeaturedSectionsLoadingSkeleton(),
      error: (error, _) => ConnectivityErrorGate(
        error: error,
        onRetry: () async => ref.invalidate(homeFeaturedSectionsProvider),
        child: const HomeFeaturedSectionsLoadingSkeleton(),
      ),
      data: (sections) {
        if (sections.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < sections.length; i++)
              _FeaturedSectionStrip(
                section: sections[i],
                titleTop: i == 0 ? 8.h : 4.h,
              ),
          ],
        );
      },
    );
  }
}

class _FeaturedSectionStrip extends ConsumerWidget {
  const _FeaturedSectionStrip({
    required this.section,
    required this.titleTop,
  });

  final HomeFeaturedSection section;
  final double titleTop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardWidth = HomeProductCardMetrics.width();
    final cardHeight = HomeProductCardMetrics.height();
    final itemGap = 12.w;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, titleTop, 20.w, 10.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  section.name,
                  style: AppTextStyles.homeSectionTitle(),
                ),
              ),
              GestureDetector(
                onTap: () => context.push(
                  AppRoutes.exploreSectionPath(section.name),
                ),
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
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: section.products.length,
            separatorBuilder: (_, __) => SizedBox(width: itemGap),
            itemBuilder: (context, index) {
              final product = section.products[index];
              return SizedBox(
                width: cardWidth,
                child: HomeProductCard(
                  key: ValueKey(
                    'featured_${section.kind.name}_${section.erpId}_${product.id}',
                  ),
                  product: product,
                  onTap: () => ProductDetailsWidget.open(context, product),
                  onAddToCart: () =>
                      addProductToCart(context, ref, product),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
