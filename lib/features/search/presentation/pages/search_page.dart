import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_refresh_scroll_view.dart';
import '../../../../shared/widgets/pagination_footer.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/data/models/product_page_result.dart';
import '../../../home/data/products_repository.dart';
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
  final _queryController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _history = ref.read(searchHistoryStorageProvider).load();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _consumePendingFilterOpen();
    });
  }

  void _consumePendingFilterOpen() {
    if (!ref.read(openSearchFilterOnLoadProvider)) return;
    ref.read(openSearchFilterOnLoadProvider.notifier).state = false;

    _queryController.clear();
    setState(() {
      _query = '';
      _showResults = false;
      _loading = false;
      _isLoadingMore = false;
      _results = const [];
      _currentPage = 1;
      _lastPage = 1;
      _total = 0;
      _filter = const SearchFilterState();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openFilter();
    });
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
  int _total = 0;

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
    _queryController.clear();
    setState(() {
      _query = '';
      _showResults = false;
      _loading = false;
      _isLoadingMore = false;
      _results = const [];
      _currentPage = 1;
      _lastPage = 1;
      _total = 0;
      _filter = const SearchFilterState();
    });
    _focusNode.unfocus();
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
      if (_history.length > 8) {
        _history = _history.take(8).toList();
      }
      await _persistHistory();
    }

    setState(() {
      _filter = activeFilter;
      _showResults = true;
      _loading = true;
      _isLoadingMore = false;
      _results = const [];
      _currentPage = 1;
      _lastPage = 1;
      _total = 0;
    });

    try {
      final result = await _fetchPage(1, filter: activeFilter);

      if (!mounted) return;
      setState(() {
        _results = result.products;
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _total = result.total;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
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
        _total = result.total;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshResults() async {
    if (!_canSearch) return;

    try {
      final result = await _fetchPage(1);

      if (!mounted) return;
      setState(() {
        _results = result.products;
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _total = result.total;
        _loading = false;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      if (value.trim().isEmpty && !_filter.hasActiveFilters) {
        _showResults = false;
        _results = const [];
        _currentPage = 1;
        _lastPage = 1;
        _total = 0;
      }
    });
  }

  Future<void> _openFilter() async {
    ref.read(appliedSearchFilterProvider.notifier).state = null;

    final popResult = await context.push<SearchFilterState>(
      AppRoutes.searchFilter,
      extra: _filter,
    );

    if (!mounted) return;

    final applied =
        ref.read(appliedSearchFilterProvider) ?? popResult;
    ref.read(appliedSearchFilterProvider.notifier).state = null;

    if (applied == null) return;

    await _runSearch(filter: applied);
  }

  Future<void> _onScannerTap() async {
    final barcode = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('بحث بالباركود'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              hintText: 'أدخل أو امسح الباركود',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('بحث'),
            ),
          ],
        );
      },
    );

    if (!mounted || barcode == null || barcode.isEmpty) return;

    _queryController.text = barcode;
    setState(() => _query = barcode);
    await _runSearch(updateHistory: true);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(openSearchFilterOnLoadProvider, (previous, next) {
      if (next) _consumePendingFilterOpen();
    });

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
              onFilterTap: _openFilter,
              onScannerTap: _onScannerTap,
              onChanged: _onQueryChanged,
              onSubmitted: _onSearch,
            ),
            if (_isShowingResults && _filter.hasActiveFilters)
              SearchActiveFiltersRow(filter: _filter),
            Expanded(
              child: _isShowingResults
                  ? _buildResults(bottomInset)
                  : _buildHistory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return SearchHistorySection(
      history: _history,
      onClearAll: () {
        setState(() => _history = []);
        _persistHistory();
      },
      onRemoveItem: (index) {
        setState(() => _history.removeAt(index));
        _persistHistory();
      },
      onItemTap: (term) {
        _queryController.text = term;
        _onSearch(term);
      },
    );
  }

  Widget _buildResults(double bottomInset) {
    if (_loading) {
      return AppRefreshScrollView(
        onRefresh: _refreshResults,
        controller: _scrollController,
        slivers: const [
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
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

    final countLabel = _total > 0
        ? '${_results.length} من $_total'
        : '${_results.length}';

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
                'نتائج البحث ($countLabel)',
                style: AppTextStyles.searchSectionTitle(),
              ),
            ),
          ),
        ),
        SliverPadding(
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
                final product = _results[index];
                return HomeProductCard(
                  key: ValueKey('search_${product.id}_$index'),
                  product: product,
                  onAddToCart: () => addProductToCart(context, ref, product),
                );
              },
              childCount: _results.length,
            ),
          ),
        ),
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
