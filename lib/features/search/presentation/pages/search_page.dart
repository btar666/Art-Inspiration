import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/data/products_repository.dart';
import '../../../home/presentation/widgets/home_product_card.dart';
import '../../../home/presentation/widgets/home_product_card_metrics.dart';
import '../../data/models/search_filter_state.dart';
import '../../data/search_mock_data.dart';
import '../widgets/search_active_filters_row.dart';
import '../widgets/search_history_section.dart';
import '../widgets/search_input_bar.dart';
import '../widgets/search_page_header.dart';

/// صفحة البحث — مربوطة بـ أمان ERP (`q` + فلاتر)
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _queryController = TextEditingController();
  final _focusNode = FocusNode();

  List<String> _history = List.of(SearchMockData.defaultHistory);
  SearchFilterState _filter = const SearchFilterState();
  String _query = '';
  bool _showResults = false;
  bool _loading = false;
  List<ProductModel> _results = const [];

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCancel() {
    _queryController.clear();
    setState(() {
      _query = '';
      _showResults = false;
      _loading = false;
      _results = const [];
    });
    _focusNode.unfocus();
  }

  Future<void> _onSearch(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _query = trimmed;
      _showResults = true;
      _loading = true;
      _history.remove(trimmed);
      _history.insert(0, trimmed);
      if (_history.length > 8) {
        _history = _history.take(8).toList();
      }
    });

    try {
      final results =
          await ref.read(productsRepositoryProvider).searchProducts(
                query: trimmed,
                category: _filter.selectedCategory,
                brand: _filter.selectedBrand,
                minPrice: _filter.minPrice,
                maxPrice: _filter.maxPrice,
              );

      if (!mounted) return;
      setState(() {
        _results = results;
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

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      if (value.trim().isEmpty) {
        _showResults = false;
        _results = const [];
      }
    });
  }

  Future<void> _openFilter() async {
    final result = await context.push<SearchFilterState>(
      AppRoutes.searchFilter,
      extra: _filter,
    );
    if (result == null || !mounted) return;
    setState(() => _filter = result);
    if (_query.trim().isNotEmpty) {
      await _onSearch(_query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isSearching = _showResults && _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchPageHeader(onCancel: _onCancel),
            SearchInputBar(
              controller: _queryController,
              focusNode: _focusNode,
              onFilterTap: _openFilter,
              onChanged: _onQueryChanged,
              onSubmitted: _onSearch,
            ),
            if (isSearching && _filter.hasActiveFilters)
              SearchActiveFiltersRow(filter: _filter),
            Expanded(
              child: isSearching
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
      onClearAll: () => setState(() => _history = []),
      onRemoveItem: (index) {
        setState(() => _history.removeAt(index));
      },
      onItemTap: (term) {
        _queryController.text = term;
        _onSearch(term);
      },
    );
  }

  Widget _buildResults(double bottomInset) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Text(
          'لا توجد نتائج',
          style: AppTextStyles.searchEmptyState(),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'نتائج البحث (${_results.length})',
                style: AppTextStyles.searchSectionTitle(),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            0,
            20.w,
            100.h + bottomInset,
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
      ],
    );
  }
}
