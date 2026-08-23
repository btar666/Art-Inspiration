import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_refresh_scroll_view.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../../../shared/widgets/skeleton/product_grid_skeleton.dart';
import '../../../../shared/widgets/skeleton/skeleton_shimmer.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/data/models/product_page_result.dart';
import '../../../home/data/products_repository.dart';
import '../../../home/presentation/providers/products_provider.dart';
import '../../../home/presentation/widgets/home_product_card.dart';
import '../../../home/presentation/widgets/home_product_card_metrics.dart';
import '../../data/models/search_filter_state.dart';
import '../../data/search_history_storage.dart';
import '../providers/search_filter_provider.dart';
import '../widgets/search_active_filters_row.dart';
import '../widgets/search_history_section.dart';
import '../widgets/search_input_bar.dart';
import '../widgets/search_page_header.dart';

/// صفحة البحث — أمان ERP: `q` + `category_id` + `brand_id` + `is_active`
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  static const _suggestedCount = 10;

  final _queryController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  List<String> _history = [];
  List<ProductModel> _suggestedProducts = const [];
  bool _loadingSuggestions = false;
  int _searchRequestId = 0;
  int _suggestRequestId = 0;

  @override
  void initState() {
    super.initState();
    _history = ref.read(searchHistoryStorageProvider).load();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consumePendingAppliedFilter();
      _consumePendingSearchQuery();
      _loadSuggestions();
    });
  }

  void _consumePendingSearchQuery() {
    final pending = ref.read(pendingSearchQueryProvider);
    if (pending == null || pending.isEmpty) return;
    ref.read(pendingSearchQueryProvider.notifier).state = null;

    setState(() {
      _query = pending;
      _queryController.text = pending;
      _filter = const SearchFilterState();
      _showResults = true;
      _loading = false;
      _isLoadingMore = false;
      _results = const [];
      _currentPage = 1;
      _lastPage = 1;
    });

    _runSearch(updateHistory: true);
  }

  void _consumePendingAppliedFilter() {
    final applied = ref.read(appliedSearchFilterProvider);
    if (applied == null) return;
    ref.read(appliedSearchFilterProvider.notifier).state = null;

    setState(() {
      _query = '';
      _queryController.clear();
      _filter = applied;
      _showResults = false;
      _loading = false;
      _isLoadingMore = false;
      _results = const [];
      _currentPage = 1;
      _lastPage = 1;
    });

    _runSearch(filter: applied);
  }

  Future<void> _persistHistory() {
    return ref.read(searchHistoryStorageProvider).save(_history);
  }

  SearchFilterState _filter = const SearchFilterState();
  String _query = '';
  bool _showResults = false;
  bool _loading = false;
  bool _isLoadingMore = false;
  List<ProductModel> _results = const [];
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loading || _isLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 320) return;
    _loadMore();
  }

  bool get _hasMore => _currentPage < _lastPage;

  bool _canSearchWith(SearchFilterState filter) =>
      _query.trim().isNotEmpty || filter.hasActiveFilters;

  bool get _canSearch => _canSearchWith(_filter);

  bool get _isShowingResults => _showResults && _canSearch;

  Future<ProductPageResult> _fetchPage(
    int page, {
    SearchFilterState? filter,
  }) {
    final active = filter ?? _filter;
    return ref.read(productsRepositoryProvider).searchProductsPage(
          page: page,
          query: _query,
          category: active.selectedCategory,
          brand: active.selectedBrand,
          onlyActive: active.onlyActive,
        );
  }

  void _onCancel() {
    _searchRequestId++;
    _queryController.clear();
    setState(() {
      _query = '';
      _showResults = false;
      _loading = false;
      _isLoadingMore = false;
      _results = const [];
      _currentPage = 1;
      _lastPage = 1;
      _filter = const SearchFilterState();
    });
    _focusNode.unfocus();
    _loadSuggestions();
  }

  Future<void> _runSearch({
    bool updateHistory = false,
    SearchFilterState? filter,
  }) async {
    final activeFilter = filter ?? _filter;
    if (!_canSearchWith(activeFilter)) return;

    final trimmed = _query.trim();
    if (updateHistory && trimmed.isNotEmpty) {
      _history.remove(trimmed);
      _history.insert(0, trimmed);
      if (_history.length > AppConstants.maxSearchHistoryItems) {
        _history = _history.take(AppConstants.maxSearchHistoryItems).toList();
      }
      await _persistHistory();
    }

    final requestId = ++_searchRequestId;

    setState(() {
      _filter = activeFilter;
      _showResults = true;
      _loading = true;
      _isLoadingMore = false;
      _results = const [];
      _currentPage = 1;
      _lastPage = 1;
    });
    _scrollToTop();

    try {
      final result = await _fetchPage(1, filter: activeFilter);

      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _results = result.products;
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _results = const [];
        _loading = false;
      });
    }
  }

  Future<void> _onSearch(String value) async {
    setState(() => _query = value.trim());
    await _runSearch(updateHistory: true);
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore || _loading) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await _fetchPage(nextPage);

      if (!mounted) return;

      final ids = _results.map((p) => p.id).toSet();
      final merged = [..._results];
      for (final product in result.products) {
        if (!ids.contains(product.id)) {
          merged.add(product);
          ids.add(product.id);
        }
      }

      setState(() {
        _results = merged;
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshResults() async {
    if (!_canSearch) return;

    await ref.read(authNotifierProvider.notifier).syncPricePolicyFromErp();

    try {
      final result = await _fetchPage(1);

      if (!mounted) return;
      setState(() {
        _results = result.products;
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _loading = false;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  void _onQueryChanged(String value) {
    final trimmed = value.trim();

    setState(() {
      _query = value;
      if (trimmed.isEmpty && !_filter.hasActiveFilters) {
        _showResults = false;
        _loading = false;
        _isLoadingMore = false;
        _results = const [];
        _currentPage = 1;
        _lastPage = 1;
      }
    });

    if (trimmed.isEmpty) {
      _searchRequestId++;
      if (!_filter.hasActiveFilters) {
        _loadSuggestions();
      }
      return;
    }

    _runSearch();
  }

  void _onScannerTap() => context.push(AppRoutes.barcodeScanner);

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final showCancel = _isShowingResults ||
        _query.trim().isNotEmpty ||
        _filter.hasActiveFilters;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchPageHeader(
              showCancel: showCancel,
              onCancel: _onCancel,
            ),
            SearchInputBar(
              controller: _queryController,
              focusNode: _focusNode,
              onScannerTap: _onScannerTap,
              onChanged: _onQueryChanged,
              onSubmitted: _onSearch,
            ),
            if (_isShowingResults && _filter.hasActiveFilters)
              SearchActiveFiltersRow(filter: _filter),
            Expanded(
              child: _isShowingResults
                  ? _buildResults(bottomInset)
                  : _buildIdle(bottomInset),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSuggestions() async {
    if (_isShowingResults) return;

    final requestId = ++_suggestRequestId;
    setState(() => _loadingSuggestions = _suggestedProducts.isEmpty);

    try {
      final products = await _fetchSuggestedProducts();
      if (!mounted || requestId != _suggestRequestId) return;
      setState(() {
        _suggestedProducts = products;
        _loadingSuggestions = false;
      });
    } catch (_) {
      if (!mounted || requestId != _suggestRequestId) return;
      setState(() => _loadingSuggestions = false);
    }
  }

  Future<List<ProductModel>> _fetchSuggestedProducts() async {
    if (_history.isNotEmpty) {
      final fromHistory = await _productsForHistory();
      if (fromHistory.isNotEmpty) return fromHistory;
    }
    return _randomProducts();
  }

  Future<List<ProductModel>> _productsForHistory() async {
    final repo = ref.read(productsRepositoryProvider);
    final terms = _history
        .map((term) => term.trim())
        .where((term) => term.isNotEmpty)
        .take(3)
        .toList();
    if (terms.isEmpty) return const [];

    final pages = await Future.wait(
      terms.map(
        (term) => repo.searchProductsPage(page: 1, query: term),
      ),
    );

    final seen = <String>{};
    final matched = <ProductModel>[];
    for (final page in pages) {
      for (final product in page.products) {
        if (!seen.add(product.id)) continue;
        matched.add(product);
        if (matched.length >= _suggestedCount) {
          return matched;
        }
      }
    }
    return matched;
  }

  Future<List<ProductModel>> _randomProducts() async {
    var pool =
        ref.read(productsRepositoryProvider).peekDefaultCatalog()?.products;
    if (pool == null || pool.isEmpty) {
      try {
        pool = (await ref.read(catalogProvider.future)).products;
      } catch (_) {
        pool = const [];
      }
    }
    if (pool.isEmpty) return const [];

    final source = List<ProductModel>.from(pool);
    source.shuffle();
    return source.take(_suggestedCount).toList();
  }

  Widget _buildIdle(double bottomInset) {
    return AppRefreshScrollView(
      onRefresh: () async {
        await Future.wait([
          ref.read(authNotifierProvider.notifier).syncPricePolicyFromErp(),
          ref.read(catalogProvider.notifier).refresh(),
        ]);
        await _loadSuggestions();
      },
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: SearchHistorySection(
            history: _history,
            onClearAll: () {
              setState(() => _history = []);
              _persistHistory();
              _loadSuggestions();
            },
            onRemoveItem: (index) {
              setState(() => _history.removeAt(index));
              _persistHistory();
              _loadSuggestions();
            },
            onItemTap: (term) {
              _queryController.text = term;
              _onSearch(term);
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              _history.isEmpty ? 20.h : 16.h,
              20.w,
              12.h,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'منتجات مقترحة',
                style: AppTextStyles.searchSectionTitle(),
              ),
            ),
          ),
        ),
        if (_loadingSuggestions && _suggestedProducts.isEmpty)
          ProductGridSkeletonSliver(
            bottomSpacing: 100.h + bottomInset,
          )
        else if (_suggestedProducts.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 100.h),
                child: Text(
                  'لا توجد منتجات مقترحة حالياً',
                  style: AppTextStyles.searchEmptyState(),
                ),
              ),
            ),
          )
        else ...[
          _productsGridSliver(_suggestedProducts, keyPrefix: 'suggest'),
          SliverToBoxAdapter(child: SizedBox(height: 100.h + bottomInset)),
        ],
      ],
    );
  }

  Widget _productsGridSliver(
    List<ProductModel> products, {
    required String keyPrefix,
  }) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: HomeProductCardMetrics.aspectRatio(),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return HomeProductCard(
              key: ValueKey('${keyPrefix}_${product.id}_$index'),
              product: product,
              onTap: () => ProductDetailsWidget.open(context, product),
              onAddToCart: () => addProductToCart(context, ref, product),
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildResults(double bottomInset) {
    if (_loading) {
      return AppRefreshScrollView(
        onRefresh: _refreshResults,
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                _filter.hasActiveFilters ? 4.h : 20.h,
                20.w,
                12.h,
              ),
              child: SkeletonShimmer(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SkeletonLine(width: 100.w, height: 18.h),
                ),
              ),
            ),
          ),
          ProductGridSkeletonSliver(
            bottomSpacing: 100.h + bottomInset,
          ),
        ],
      );
    }

    if (_results.isEmpty) {
      return AppRefreshScrollView(
        onRefresh: _refreshResults,
        controller: _scrollController,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'لا توجد نتائج',
                style: AppTextStyles.searchEmptyState(),
              ),
            ),
          ),
        ],
      );
    }

    return AppRefreshScrollView(
      onRefresh: _refreshResults,
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              _filter.hasActiveFilters ? 4.h : 20.h,
              20.w,
              12.h,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'نتائج البحث',
                style: AppTextStyles.searchSectionTitle(),
              ),
            ),
          ),
        ),
        _productsGridSliver(_results, keyPrefix: 'search'),
        if (_hasMore || _isLoadingMore)
          SliverToBoxAdapter(
            child: PaginationFooter(
              currentPage: _currentPage,
              lastPage: _lastPage,
              hasMore: _hasMore,
              isLoadingMore: _isLoadingMore,
              onLoadMore: _loadMore,
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 100.h + bottomInset)),
      ],
    );
  }
}
