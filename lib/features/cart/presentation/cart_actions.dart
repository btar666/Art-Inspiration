import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/add_to_cart_snackbar.dart';
import '../../home/data/models/product_model.dart';
import '../../home/presentation/providers/user_price_policy_provider.dart';
import '../../orders/data/models/order_model.dart';
import 'providers/cart_provider.dart';

/// إضافة منتج للسلة مع رسالة تأكيد
void addProductToCart(
  BuildContext context,
  WidgetRef ref,
  ProductModel product, {
  int quantity = 1,
}) {
  if (!product.isInStock) {
    if (context.mounted) showOutOfStockSnackBar(context);
    return;
  }

  final cart = ref.read(cartNotifierProvider.notifier);
  final max = product.maxOrderQuantity;
  var qtyToAdd = quantity;
  var hitStockLimit = false;
  if (max != null) {
    final current = cart.quantityOf(product.id);
    if (current + qtyToAdd > max) {
      hitStockLimit = true;
      if (context.mounted) showStockLimitSnackBar(context, max);
      final remaining = max - current;
      if (remaining <= 0) return;
      qtyToAdd = remaining;
    }
  }

  cart.addProduct(
    product.withPriceFor(ref.read(userPricePolicyProvider)),
    quantity: qtyToAdd,
  );

  if (!context.mounted || hitStockLimit) return;
  showAddToCartSnackBar(context);
}

/// تحويل عنصر طلب إلى منتج للسلة
ProductModel orderLineItemToProduct(OrderLineItem item) {
  return ProductModel(
    id: item.productId ?? 'reorder-${item.productName.hashCode}',
    name: item.productName,
    categoryName: '',
    description: '',
    price: item.price,
    rating: 0,
    imageUrl: item.imageUrl,
    imageBgColor: item.imageBgColor,
  );
}

/// إعادة طلب — إضافة منتجات الطلب للسلة والانتقال لصفحة السلة
void reorderToCart(
  BuildContext context,
  WidgetRef ref,
  OrderDetailModel order,
) {
  if (order.items.isEmpty) return;

  final cart = ref.read(cartNotifierProvider.notifier);
  for (final item in order.items) {
    cart.addProduct(
      orderLineItemToProduct(item),
      quantity: item.quantity,
    );
  }

  if (!context.mounted) return;
  context.push(AppRoutes.cart);
}
