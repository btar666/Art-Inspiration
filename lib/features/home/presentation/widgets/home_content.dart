import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../data/home_mock_data.dart';
import 'home_category_chips.dart';
import 'home_product_card.dart';
import 'home_product_card_metrics.dart';
import 'home_promo_banner.dart';
import 'home_scroll_metrics.dart';
import 'home_top_section.dart';

/// محتوى الصفحة الرئيسية القابل للتمرير
class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final logoSpacerHeight = topInset + HomeScrollMetrics.logoBarHeight();

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: logoSpacerHeight),
        ),
        const SliverToBoxAdapter(
          child: HomeSearchBar(),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeCategoryChips(
                categories: HomeMockData.categories,
                selectedIndex: _selectedCategoryIndex,
                onSelected: (i) => setState(() => _selectedCategoryIndex = i),
              ),
              const HomePromoBanner(),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 12.h),
                child: Text(
                  'جميع المنتجات',
                  style: AppTextStyles.homeSectionTitle(),
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            0,
            20.w,
            120.h + MediaQuery.paddingOf(context).bottom,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14.h,
              crossAxisSpacing: 14.w,
              childAspectRatio: HomeProductCardMetrics.aspectRatio(),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product =
                    HomeMockData.products[index % HomeMockData.products.length];
                return HomeProductCard(
                  key: ValueKey('${product.id}_$index'),
                  product: product,
                  onTap: () => ProductDetailsWidget.open(context, product),
                  onAddToCart: () =>
                      addProductToCart(context, ref, product),
                );
              },
              childCount: HomeMockData.products.length,
            ),
          ),
        ),
      ],
    );
  }
}
