import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/add_to_cart_snackbar.dart';
import '../../home/data/models/product_model.dart';
import 'providers/cart_provider.dart';

/// إضافة منتج للسلة مع رسالة تأكيد
void addProductToCart(
  BuildContext context,
  WidgetRef ref,
  ProductModel product, {
  int quantity = 1,
}) {
  ref.read(cartNotifierProvider.notifier).addProduct(
        product,
        quantity: quantity,
      );

  if (!context.mounted) return;
  showAddToCartSnackBar(context, product.name);
}
