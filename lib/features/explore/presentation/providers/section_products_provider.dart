import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/models/product_model.dart';
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
    final repo = ref.read(productsRepositoryProvider);
    final cached = repo.peekSectionProductsPage(sectionName);
    if (cached != null) {
      final state = SectionProductsState.fromResult(
        sectionName,
        cached.products,
        currentPage: cached.currentPage,
        lastPage: cached.lastPage,
        total: cached.total,
      );
      _scheduleBackgroundSync(state);
      return state;
    }

    final result = await repo.fetchSectionProductsPage(1, sectionName);
    return SectionProductsState.fromResult(
      sectionName,
      result.products,
      currentPage: result.currentPage,
      lastPage: result.lastPage,
      total: result.total,
    );
  }

  void _scheduleBackgroundSync(SectionProductsState displayed) {
    ref.read(productsRepositoryProvider).refreshSectionProducts(
      arg,
      loadedPageCount: displayed.currentPage,
      lastPage: displayed.lastPage,
    ).then((page) {
      if (state.value?.sectionName != arg) return;
      final updated = SectionProductsState.fromResult(
        arg,
        page.products,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        total: page.total,
      );
      state = AsyncData(updated);
      ref.read(productsRepositoryProvider).cacheSectionProducts(
            arg,
            updated.products,
            currentPage: updated.currentPage,
            lastPage: updated.lastPage,
          );
    });
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

      final byId = {for (final p in current.products) p.id: p};
      for (final product in result.products) {
        byId[product.id] = product;
      }

      final merged = <ProductModel>[];
      final seen = <String>{};
      for (final product in current.products) {
        final updated = byId[product.id];
        if (updated == null) continue;
        merged.add(updated);
        seen.add(updated.id);
      }
      for (final product in result.products) {
        if (!seen.contains(product.id)) {
          merged.add(product);
        }
      }

      final updated = current.copyWith(
        products: merged,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
        isLoadingMore: false,
      );

      ref.read(productsRepositoryProvider).cacheSectionProducts(
            arg,
            updated.products,
            currentPage: updated.currentPage,
            lastPage: updated.lastPage,
          );

      state = AsyncData(updated);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    final previous = state.value;
    if (previous == null) return;

    final result = await AsyncValue.guard(() async {
      final page = await ref.read(productsRepositoryProvider).refreshSectionProducts(
            arg,
            loadedPageCount: previous.currentPage,
            lastPage: previous.lastPage,
          );
      return SectionProductsState.fromResult(
        arg,
        page.products,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        total: page.total,
      );
    });

    if (result.hasError) {
      state = AsyncData(previous);
      return;
    }

    final updated = result.value;
    if (updated != null) {
      ref.read(productsRepositoryProvider).cacheSectionProducts(
            arg,
            updated.products,
            currentPage: updated.currentPage,
            lastPage: updated.lastPage,
          );
    }

    state = result;
  }
}
