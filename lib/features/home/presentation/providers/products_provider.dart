import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/catalog_snapshot.dart';
import '../../data/models/product_model.dart';
import '../../data/products_repository.dart';

/// مصدر واحد للمنتجات والفئات
final catalogProvider =
    AsyncNotifierProvider<CatalogNotifier, CatalogSnapshot>(CatalogNotifier.new);

class CatalogNotifier extends AsyncNotifier<CatalogSnapshot> {
  bool _isLoadingMore = false;

  @override
  Future<CatalogSnapshot> build() async {
    final link = ref.keepAlive();

    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.isLoggedIn != next.isLoggedIn) {
        ref.read(productsRepositoryProvider).clearCache();
        ref.invalidateSelf();
      }
    });

    ref.onDispose(link.close);

    final repo = ref.read(productsRepositoryProvider);
    final cached = repo.peekDefaultCatalog();
    if (cached != null) {
      _scheduleBackgroundCatalogSync(cached);
      _scheduleTaxonomySync();
      return cached;
    }

    final snapshot = await repo.fetchCatalog();
    _scheduleTaxonomySync();
    return snapshot;
  }

  void _scheduleTaxonomySync({bool force = false}) {
    ref
        .read(productsRepositoryProvider)
        .syncTaxonomyIfStale(force: force)
        .then((updated) {
      if (updated == null) return;
      final current = state.value;
      if (current == null) return;
      state = AsyncData(
        current.copyWith(
          categories: updated.categories,
          brands: updated.brands,
          stats: updated.stats,
          categoryImages: updated.categoryImages,
          brandImages: updated.brandImages,
          warningMessage: updated.warningMessage,
          clearWarning: updated.warningMessage == null,
        ),
      );
    });
  }

  void _scheduleBackgroundCatalogSync(CatalogSnapshot displayed) {
    ref
        .read(productsRepositoryProvider)
        .syncCatalogInBackground(displayed)
        .then((updated) {
      if (updated == null) return;
      final current = state.value;
      if (current == null || current.activeCategory != updated.activeCategory) {
        return;
      }
      state = AsyncData(updated);
    });
  }

  void _scheduleCategoryBackgroundSync(CatalogSnapshot displayed) {
    ref
        .read(productsRepositoryProvider)
        .syncCatalogInBackground(displayed)
        .then((updated) {
      if (updated == null) return;
      final current = state.value;
      if (current == null || current.activeCategory != updated.activeCategory) {
        return;
      }
      state = AsyncData(updated);
    });
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;

    final previous = current;

    final result = await AsyncValue.guard(() async {
      return ref.read(productsRepositoryProvider).refreshCatalog(current);
    });

    if (result.hasError) {
      state = AsyncData(previous);
      return;
    }

    state = result;
    _scheduleTaxonomySync(force: true);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final updated =
          await ref.read(productsRepositoryProvider).loadMoreProducts(current);
      state = AsyncData(updated);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> selectCategory(String category) async {
    final current = state.value;
    if (current == null || current.activeCategory == category) return;

    final repo = ref.read(productsRepositoryProvider);
    final cached = repo.peekCategoryCatalog(category, current);
    if (cached != null) {
      state = AsyncData(cached);
      _scheduleCategoryBackgroundSync(cached);
      return;
    }

    _isLoadingMore = true;
    state = AsyncData(
      current.copyWith(isLoadingMore: true, products: const []),
    );

    try {
      final updated = await repo.fetchProductsForCategory(category, current);
      state = AsyncData(updated);
    } finally {
      _isLoadingMore = false;
    }
  }
}

final productsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  return ref.watch(catalogProvider).whenData((s) => s.products);
});

final categoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  return ref.watch(catalogProvider).whenData((s) => s.categories);
});

final brandsProvider = Provider<AsyncValue<List<String>>>((ref) {
  return ref.watch(catalogProvider).whenData((s) => s.brands);
});

final catalogWarningProvider = Provider<String?>((ref) {
  return ref.watch(catalogProvider).value?.warningMessage;
});

final catalogHasMoreProvider = Provider<bool>((ref) {
  return ref.watch(catalogProvider).value?.hasMore ?? false;
});

final catalogLoadingMoreProvider = Provider<bool>((ref) {
  return ref.watch(catalogProvider).value?.isLoadingMore ?? false;
});
