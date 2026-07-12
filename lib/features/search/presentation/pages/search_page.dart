import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../home/data/home_mock_data.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/providers/products_provider.dart';
import '../../../home/presentation/widgets/home_product_card.dart';
import '../../../home/presentation/widgets/home_product_card_metrics.dart';
import '../../data/models/search_filter_state.dart';
import '../../data/search_mock_data.dart';
import '../widgets/search_active_filters_row.dart';
import '../widgets/search_history_section.dart';
import '../widgets/search_input_bar.dart';
import '../widgets/search_page_header.dart';

/// صفحة البحث
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

  List<ProductModel> get _allProducts {
    return ref.watch(productsProvider).value ?? HomeMockData.products;
  }

  List<ProductModel> get _filteredProducts {
    if (!_showResults || _query.trim().isEmpty) return [];

    return _allProducts.where((product) {
      final inPriceRange = product.price >= _filter.minPrice &&
          product.price <= _filter.maxPrice;
      if (!inPriceRange) return false;

      if (_filter.selectedCategory != 'الكل' &&
          !product.categoryName.contains(_filter.selectedCategory) &&
          _filter.selectedCategory != 'مكياج') {
        // mock: allow all unless strict filter with high min price
      }

      final q = _query.trim().toLowerCase();
      if (q == 'لايوجد' || q == 'empty') return false;

      return product.name.contains(q) ||
          product.description.contains(q) ||
          product.categoryName.contains(q) ||
          q.isNotEmpty;
    }).toList();
  }

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
    });
    _focusNode.unfocus();
  }

  void _onSearch(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _query = trimmed;
      _showResults = true;
      _history.remove(trimmed);
      _history.insert(0, trimmed);
      if (_history.length > 8) {
        _history = _history.take(8).toList();
      }
    });
  }

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      if (value.trim().isEmpty) {
        _showResults = false;
      }
    });
  }

  Future<void> _openFilter() async {
    final result = await context.push<SearchFilterState>(
      AppRoutes.searchFilter,
      extra: _filter,
    );
    if (result == null || !mounted) return;
    setState(() {
      _filter = result;
      if (_query.trim().isNotEmpty) _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final products = _filteredProducts;
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
                  ? _buildResults(products, bottomInset)
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

  Widget _buildResults(List<ProductModel> products, double bottomInset) {
    if (products.isEmpty) {
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
                'نتائج البحث',
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
                final product = products[index];
                return HomeProductCard(
                  key: ValueKey('search_${product.id}_$index'),
                  product: product,
                  onAddToCart: () => addProductToCart(context, ref, product),
                );
              },
              childCount: products.length,
            ),
          ),
        ),
      ],
    );
  }
}
