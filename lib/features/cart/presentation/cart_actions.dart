import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/add_to_cart_snackbar.dart';
import '../../home/data/models/product_model.dart';
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

  ref.read(cartNotifierProvider.notifier).addProduct(
        product,
        quantity: quantity,
      );

  if (!context.mounted) return;
  showAddToCartSnackBar(context, product.name);
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
