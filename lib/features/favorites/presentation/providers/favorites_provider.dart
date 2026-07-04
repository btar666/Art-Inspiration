import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/models/product_model.dart';
import '../../data/favorites_storage.dart';

/// حالة المفضلات المشتركة — تُحمّل من التخزين المحلي
class FavoritesNotifier extends Notifier<List<ProductModel>> {
  @override
  List<ProductModel> build() {
    return ref.read(favoritesStorageProvider).loadProducts();
  }

  Future<void> _persist() =>
      ref.read(favoritesStorageProvider).saveProducts(state);

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
}

final favoritesNotifierProvider =
    NotifierProvider<FavoritesNotifier, List<ProductModel>>(
  FavoritesNotifier.new,
);

final isProductFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(favoritesNotifierProvider).any((p) => p.id == productId);
});
