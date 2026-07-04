import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('تمت إضافة "${product.name}" إلى السلة'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}
