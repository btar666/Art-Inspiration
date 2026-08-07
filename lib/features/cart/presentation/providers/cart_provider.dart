import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/models/product_model.dart';
import '../../data/cart_storage.dart';
import '../../data/models/cart_item_model.dart';

/// حالة السلة المشتركة — تُحمّل من التخزين المحلي عند بدء التطبيق
class CartNotifier extends Notifier<List<CartItemModel>> {
  @override
  List<CartItemModel> build() {
    return ref.read(cartStorageProvider).loadItems();
  }

  Future<void> _persist() =>
      ref.read(cartStorageProvider).saveItems(state);

  void addProduct(ProductModel product, {int quantity = 1}) {
    if (quantity < 1) return;

    final items = [...state];
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + quantity,
      );
    } else {
      items.add(CartItemModel(product: product, quantity: quantity));
    }

    state = items;
    _persist();
    ref.read(cartAnimationTickProvider.notifier).state++;
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
    _persist();
  }

  void clearAll() {
    state = [];
    ref.read(cartStorageProvider).clear();
  }

  void incrementQuantity(int index) {
    if (index < 0 || index >= state.length) return;
    final items = [...state];
    items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    state = items;
    _persist();
  }

  void decrementQuantity(int index) {
    if (index < 0 || index >= state.length) return;
    if (state[index].quantity <= 1) {
      removeAt(index);
      return;
    }
    final items = [...state];
    items[index] = items[index].copyWith(quantity: items[index].quantity - 1);
    state = items;
    _persist();
  }

  Future<void> reload() async {
    state = ref.read(cartStorageProvider).loadItems();
  }
}

final cartNotifierProvider =
    NotifierProvider<CartNotifier, List<CartItemModel>>(CartNotifier.new);

final cartItemCountProvider = Provider<int>((ref) {
  return ref
      .watch(cartNotifierProvider)
      .fold(0, (sum, item) => sum + item.quantity);
});

final cartSubtotalProvider = Provider<int>((ref) {
  return ref
      .watch(cartNotifierProvider)
      .fold(0, (sum, item) => sum + item.lineTotal);
});

/// يزداد عند كل إضافة للسلة — لتشغيل أنيميشن الاهتزاز
final cartAnimationTickProvider = StateProvider<int>((ref) => 0);
