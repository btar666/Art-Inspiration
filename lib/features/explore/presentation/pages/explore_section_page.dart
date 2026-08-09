import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_refresh_scroll_view.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../home/presentation/providers/products_provider.dart';
import '../../../home/presentation/widgets/home_product_card.dart';
import '../../../home/presentation/widgets/home_product_card_metrics.dart';
import '../../data/models/explore_models.dart';
import '../../data/models/section_products_state.dart';
import '../providers/section_products_provider.dart';
import '../widgets/section_page_header.dart';

/// صفحة منتجات القسم أو البراند — تصفح من الخادم
class ExploreSectionPage extends ConsumerStatefulWidget {
  const ExploreSectionPage({super.key, required this.sectionId});

  final String sectionId;

  @override
  ConsumerState<ExploreSectionPage> createState() => _ExploreSectionPageState();
}

class _ExploreSectionPageState extends ConsumerState<ExploreSectionPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 320) return;
    ref.read(sectionProductsProvider(widget.sectionId).notifier).loadMore();
  }

  Future<void> _onRefresh() async {
    await ref.read(sectionProductsProvider(widget.sectionId).notifier).refresh();
  }

  ExploreSectionModel _resolveSection() {
    final catalog = ref.read(catalogProvider).value;
    final apiImage = catalog?.imageForCategory(widget.sectionId);

    return ExploreSectionModel(
      id: widget.sectionId,
      name: widget.sectionId,
      imageUrl: apiImage,
    );
  }

  List<Widget> _productSlivers({
    required SectionProductsState state,
    required ExploreSectionModel section,
    required double bottomInset,
  }) {
    if (state.products.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              'لا توجد منتجات لهذا القسم',
              style: TextStyle(fontSize: 15.sp),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14.h,
            crossAxisSpacing: 14.w,
            childAspectRatio: HomeProductCardMetrics.aspectRatio(),
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = state.products[index];
              return HomeProductCard(
                key: ValueKey('section_${section.id}_${product.id}_$index'),
                product: product,
                onTap: () => ProductDetailsWidget.open(context, product),
                onAddToCart: () => addProductToCart(context, ref, product),
              );
            },
            childCount: state.products.length,
          ),
        ),
      ),
      if (state.hasMore || state.isLoadingMore)
        SliverToBoxAdapter(
          child: PaginationFooter(
            currentPage: state.currentPage,
            lastPage: state.lastPage,
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
            onLoadMore: () => ref
                .read(sectionProductsProvider(widget.sectionId).notifier)
                .loadMore(),
          ),
        ),
      SliverToBoxAdapter(child: SizedBox(height: 24.h + bottomInset)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final section = _resolveSection();
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final productsAsync = ref.watch(sectionProductsProvider(widget.sectionId));

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
            Expanded(
              child: productsAsync.when(
                loading: () => AppRefreshScrollView(
                  onRefresh: _onRefresh,
                  controller: _scrollController,
                  slivers: const [
                    SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
                error: (error, _) => AppRefreshScrollView(
                  onRefresh: _onRefresh,
                  controller: _scrollController,
                  slivers: [
                    SliverFillRemaining(
                      child: Center(child: Text(error.toString())),
                    ),
                  ],
                ),
                data: (state) => AppRefreshScrollView(
                  onRefresh: _onRefresh,
                  controller: _scrollController,
                  slivers: _productSlivers(
                    state: state,
                    section: section,
                    bottomInset: bottomInset,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
