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

    return ref.read(productsRepositoryProvider).fetchCatalog();
  }

  Future<void> refresh() async {
    final category = state.value?.activeCategory ?? 'الكل';
    final previous = state.value;

    final result = await AsyncValue.guard(() async {
      final base = await ref
          .read(productsRepositoryProvider)
          .fetchCatalog(forceRefresh: true);
      if (category == 'الكل') return base;
      return ref
          .read(productsRepositoryProvider)
          .fetchProductsForCategory(category, base);
    });

    if (result.hasError && previous != null) {
      state = AsyncData(previous);
      return;
    }

    state = result;
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

    _isLoadingMore = true;
    state = AsyncData(
      current.copyWith(isLoadingMore: true, products: const []),
    );

    try {
      final updated = await ref
          .read(productsRepositoryProvider)
          .fetchProductsForCategory(category, current);
      state = AsyncData(updated);
    } finally {
      _isLoadingMore = false;
    }
  }
}

extension CatalogSnapshotX on CatalogSnapshot {
  List<ProductModel> get visibleProducts => products;
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
