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
import '../widgets/explore_pinned_header.dart';
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
  final _headerKey = GlobalKey();
  ExploreTab _selectedTab = ExploreTab.general;
  double _headerHeight = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabSelected(ExploreTab tab) {
    if (tab == _selectedTab) return;
    setState(() => _selectedTab = tab);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _updateHeaderHeight() {
    final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final height = box.size.height;
    if ((height - _headerHeight).abs() > 0.5) {
      setState(() => _headerHeight = height);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final fallbackHeader = ExploreScrollMetrics.pinnedHeaderHeight(topInset);
    final scrollTopPadding =
        _headerHeight > 0 ? _headerHeight : fallbackHeader;
    final catalogAsync = ref.watch(catalogProvider);
    final catalog = catalogAsync.value;
    final products = ref.watch(productsProvider).value ?? HomeMockData.products;
    final brands = catalog?.brands ?? const [];
    final categories = catalog != null && catalog.source != CatalogDataSource.mock
        ? catalog.categories
        : HomeMockData.categories;

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeaderHeight());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: scrollTopPadding)),
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
          ExplorePinnedHeader(
            headerKey: _headerKey,
            selectedTab: _selectedTab,
            onTabSelected: _onTabSelected,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }
}
