import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/user_cache_key_provider.dart';
import '../../../home/data/models/product_model.dart';
import '../../data/favorites_storage.dart';

/// حالة المفضلات المشتركة — تُحمّل من التخزين المحلي
class FavoritesNotifier extends Notifier<List<ProductModel>> {
  @override
  List<ProductModel> build() {
    final userKey = ref.watch(activeUserCacheKeyProvider);
    return ref.read(favoritesStorageProvider).loadProducts(userKey);
  }

  Future<void> _persist() => ref.read(favoritesStorageProvider).saveProducts(
        ref.read(activeUserCacheKeyProvider),
        state,
      );

  bool isFavorite(String productId) =>
      state.any((product) => product.id == productId);

  void toggle(ProductModel product) {
    if (isFavorite(product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
    _persist();
  }

  void remove(String productId) {
    if (!isFavorite(productId)) return;
    state = state.where((p) => p.id != productId).toList();
    _persist();
  }

  Future<void> reload() async {
    state = ref
        .read(favoritesStorageProvider)
        .loadProducts(ref.read(activeUserCacheKeyProvider));
  }
}

final favoritesNotifierProvider =
    NotifierProvider<FavoritesNotifier, List<ProductModel>>(
  FavoritesNotifier.new,
);

final isProductFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(favoritesNotifierProvider).any((p) => p.id == productId);
});
