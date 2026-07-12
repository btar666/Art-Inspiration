import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../home/data/home_mock_data.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/providers/products_provider.dart';
import '../../../home/presentation/widgets/home_product_card.dart';
import '../../../home/presentation/widgets/home_product_card_metrics.dart';
import '../../data/explore_mock_data.dart';
import '../../data/models/explore_models.dart';
import '../widgets/section_filter_chips.dart';
import '../widgets/section_page_header.dart';

/// صفحة منتجات القسم أو البراند
class ExploreSectionPage extends ConsumerStatefulWidget {
  const ExploreSectionPage({super.key, required this.sectionId});

  final String sectionId;

  @override
  ConsumerState<ExploreSectionPage> createState() => _ExploreSectionPageState();
}

class _ExploreSectionPageState extends ConsumerState<ExploreSectionPage> {
  int _selectedFilterIndex = 0;

  ExploreSectionModel _resolveSection() {
    for (final section in ExploreMockData.sections) {
      if (section.id == widget.sectionId || section.name == widget.sectionId) {
        return section;
      }
    }

    return ExploreSectionModel(
      id: widget.sectionId,
      name: widget.sectionId,
      iconAsset: AppAssets.sectionMakeup,
      bgColor: AppColors.background,
      filters: const ['كل المنتجات'],
    );
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    final sectionName = widget.sectionId;
    return products
        .where((p) => p.matchesCategoryOrBrand(sectionName))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final section = _resolveSection();
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final allProducts = ref.watch(productsProvider).value ?? HomeMockData.products;
    final products = _filterProducts(allProducts);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionPageHeader(
              title: section.name,
              onBack: () => context.pop(),
            ),
            SectionFilterChips(
              filters: section.filters,
              selectedIndex: _selectedFilterIndex,
              onSelected: (index) {
                setState(() => _selectedFilterIndex = index);
              },
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد منتجات لهذا القسم',
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        20.w,
                        0,
                        20.w,
                        24.h + bottomInset,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14.h,
                        crossAxisSpacing: 14.w,
                        childAspectRatio: HomeProductCardMetrics.aspectRatio(),
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return HomeProductCard(
                          key: ValueKey('section_${section.id}_${product.id}_$index'),
                          product: product,
                          onAddToCart: () =>
                              addProductToCart(context, ref, product),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
