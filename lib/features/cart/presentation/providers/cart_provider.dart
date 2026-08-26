import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/models/erp_price_policy.dart';
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

  int quantityOf(String productId) {
    for (final item in state) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  /// تعيين الكمية المطلقة لمنتج موجود في السلة (أو إضافته إن لم يكن موجوداً)
  void setProductQuantity(ProductModel product, int quantity) {
    if (quantity < 1) {
      final index = state.indexWhere((item) => item.product.id == product.id);
      if (index >= 0) removeAt(index);
      return;
    }

    final max = product.maxOrderQuantity;
    var next = quantity;
    if (max != null && next > max) next = max < 1 ? 1 : max;

    final items = [...state];
    final index = items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (items[index].quantity == next) return;
      items[index] = items[index].copyWith(
        product: product,
        quantity: next,
      );
    } else {
      items.add(CartItemModel(product: product, quantity: next));
      ref.read(cartAnimationTickProvider.notifier).state++;
    }

    state = items;
    _persist();
  }

  void addProduct(ProductModel product, {int quantity = 1}) {
    if (quantity < 1) return;

    final items = [...state];
    final index = items.indexWhere((item) => item.product.id == product.id);
    final current = index >= 0 ? items[index].quantity : 0;
    var next = current + quantity;
    final max = product.maxOrderQuantity;
    if (max != null && next > max) {
      next = max;
    }
    if (next < 1 || next == current) return;

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: next);
    } else {
      items.add(CartItemModel(product: product, quantity: next));
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

  /// استبدال محتوى السلة بالكامل — إعادة الطلب
  void replaceItems(List<CartItemModel> items) {
    state = [...items];
    _persist();
    ref.read(cartAnimationTickProvider.notifier).state++;
  }

  bool incrementQuantity(int index) {
    if (index < 0 || index >= state.length) return false;
    final item = state[index];
    final max = item.product.maxOrderQuantity;
    if (max != null && item.quantity >= max) return false;
    final items = [...state];
    items[index] = items[index].copyWith(quantity: item.quantity + 1);
    state = items;
    _persist();
    return true;
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

  /// تحديث أسعار السلة عند تغيّر سياسة التسعير من أمان ERP
  void repriceForPolicy(ErpPricePolicy policy) {
    if (state.isEmpty) return;

    final items = state
        .map(
          (item) => item.copyWith(
            product: item.product.withPriceFor(policy),
          ),
        )
        .toList();
    state = items;
    _persist();
  }
}

final cartNotifierProvider =
    NotifierProvider<CartNotifier, List<CartItemModel>>(CartNotifier.new);

final cartItemCountProvider = Provider<int>((ref) {
  return ref
      .watch(cartNotifierProvider)
      .fold(0, (sum, item) => sum + item.quantity);
});

/// كمية منتج معيّن في السلة (0 إن لم يكن موجوداً)
final cartQuantityOfProvider = Provider.family<int, String>((ref, productId) {
  final items = ref.watch(cartNotifierProvider);
  for (final item in items) {
    if (item.product.id == productId) return item.quantity;
  }
  return 0;
});

final cartSubtotalProvider = Provider<int>((ref) {
  return ref
      .watch(cartNotifierProvider)
      .fold(0, (sum, item) => sum + item.lineTotal);
});

/// يزداد عند كل إضافة للسلة — لتشغيل أنيميشن الاهتزاز
final cartAnimationTickProvider = StateProvider<int>((ref) => 0);
