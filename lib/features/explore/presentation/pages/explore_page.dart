import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_refresh_scroll_view.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../home/data/erp_catalog_metadata.dart';
import '../../../home/data/home_mock_data.dart';
import '../../../home/presentation/providers/products_provider.dart';
import '../../data/models/explore_models.dart';
import '../providers/explore_tab_provider.dart';
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
    if ((offset - _scrollOffset).abs() < 0.5) {
      _maybeLoadMore();
      return;
    }
    setState(() => _scrollOffset = offset);
    _maybeLoadMore();
  }

  void _maybeLoadMore() {
    if (ref.read(exploreTabProvider) != ExploreTab.general) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 320) return;
    ref.read(catalogProvider.notifier).loadMore();
  }

  void _onTabSelected(ExploreTab tab) {
    if (tab == ref.read(exploreTabProvider)) return;
    ref.read(exploreTabProvider.notifier).state = tab;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(catalogProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final headerSpacer = ExploreScrollMetrics.pinnedHeaderHeight(topInset);
    final selectedTab = ref.watch(exploreTabProvider);
    final catalogAsync = ref.watch(catalogProvider);
    final catalog = catalogAsync.value;
    final mockTaxonomy =
        ErpCatalogMetadata.fromProducts(HomeMockData.products);
    final products = ref.watch(productsProvider).value ?? HomeMockData.products;
    final brands = catalog?.brands ?? mockTaxonomy.brands;
    final categories = catalog?.categories ?? mockTaxonomy.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          AppRefreshScrollView(
            onRefresh: _onRefresh,
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: headerSpacer)),
              ExploreTabSlivers.build(
                tab: selectedTab,
                bottomInset: bottomInset,
                products: products,
                brands: brands,
                categories: categories,
                catalog: catalog,
                onAddToCart: (product) =>
                    addProductToCart(context, ref, product),
                onLoadMore: () => ref.read(catalogProvider.notifier).loadMore(),
              ),
            ],
          ),
          ExploreHeaderOverlay(
            scrollOffset: _scrollOffset,
            selectedTab: selectedTab,
            onTabSelected: _onTabSelected,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }
}
