import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/products_repository.dart';
import '../../data/models/section_products_state.dart';

final sectionProductsProvider = AsyncNotifierProvider.family<
    SectionProductsNotifier, SectionProductsState, String>(
  SectionProductsNotifier.new,
);

class SectionProductsNotifier
    extends FamilyAsyncNotifier<SectionProductsState, String> {
  bool _isLoadingMore = false;

  @override
  Future<SectionProductsState> build(String sectionName) async {
    final result = await ref
        .read(productsRepositoryProvider)
        .fetchSectionProductsPage(1, sectionName);
    return SectionProductsState.fromResult(
      sectionName,
      result.products,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
      total: result.total,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.currentPage + 1;
      final result = await ref
          .read(productsRepositoryProvider)
          .fetchSectionProductsPage(nextPage, arg);

      final ids = current.products.map((p) => p.id).toSet();
      final merged = [...current.products];
      for (final product in result.products) {
        if (!ids.contains(product.id)) {
          merged.add(product);
          ids.add(product.id);
        }
      }

      state = AsyncData(
        current.copyWith(
          products: merged,
          currentPage: result.currentPage,
          lastPage: result.lastPage,
          total: result.total,
          isLoadingMore: false,
        ),
      );
    } finally {
      _isLoadingMore = false;
    }
  }
}
