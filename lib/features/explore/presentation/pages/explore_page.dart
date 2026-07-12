import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../home/data/home_mock_data.dart';
import '../../../home/data/models/catalog_snapshot.dart';
import '../../../home/presentation/providers/products_provider.dart';
import '../../data/models/explore_models.dart';
import '../widgets/explore_header_overlay.dart';
import '../widgets/explore_scroll_metrics.dart';
import '../widgets/explore_tab_content.dart';

/// صفحة الاكسبلور — عام | براندات | اقسام
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _scrollController = ScrollController();
  ExploreTab _selectedTab = ExploreTab.general;
  double _scrollOffset = 0;

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
    final offset = _scrollController.offset;
    if ((offset - _scrollOffset).abs() < 0.5) return;
    setState(() => _scrollOffset = offset);
  }

  void _onTabSelected(ExploreTab tab) {
    if (tab == _selectedTab) return;
    setState(() => _selectedTab = tab);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final headerSpacer = ExploreScrollMetrics.pinnedHeaderHeight(topInset);
    final catalog = ref.watch(catalogProvider).value;
    final products = ref.watch(productsProvider).value ?? HomeMockData.products;
    final brands = catalog?.brands ?? const [];
    final categories = catalog != null && catalog.source != CatalogDataSource.mock
        ? catalog.categories
        : HomeMockData.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: headerSpacer)),
              ExploreTabSlivers.build(
                tab: _selectedTab,
                bottomInset: bottomInset,
                products: products,
                brands: brands,
                categories: categories,
                onAddToCart: (product) =>
                    addProductToCart(context, ref, product),
              ),
            ],
          ),
          ExploreHeaderOverlay(
            scrollOffset: _scrollOffset,
            selectedTab: _selectedTab,
            onTabSelected: _onTabSelected,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }
}
