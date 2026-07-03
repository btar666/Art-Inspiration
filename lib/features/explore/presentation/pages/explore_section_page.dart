import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/data/home_mock_data.dart';
import '../../../home/data/models/product_model.dart';
import '../../../../shared/widgets/product/product_card.dart';
import '../../data/explore_mock_data.dart';
import '../widgets/section_filter_chips.dart';
import '../widgets/section_page_header.dart';

/// صفحة منتجات القسم
class ExploreSectionPage extends StatefulWidget {
  const ExploreSectionPage({super.key, required this.sectionId});

  final String sectionId;

  @override
  State<ExploreSectionPage> createState() => _ExploreSectionPageState();
}

class _ExploreSectionPageState extends State<ExploreSectionPage> {
  int _selectedFilterIndex = 0;

  List<ProductModel> get _products => [
        ...HomeMockData.products,
        ...HomeMockData.products,
        ...HomeMockData.products,
      ];

  @override
  Widget build(BuildContext context) {
    final section = ExploreMockData.sectionById(widget.sectionId);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
              child: GridView.builder(
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
                  childAspectRatio: 0.54,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductCard(
                    key: ValueKey('section_${section.id}_${product.id}_$index'),
                    product: product,
                    onAddToCart: () {},
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
