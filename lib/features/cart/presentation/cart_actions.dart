import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/add_to_cart_snackbar.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../home/data/models/product_model.dart';
import '../../home/presentation/providers/user_price_policy_provider.dart';
import '../../orders/data/models/order_model.dart';
import 'cart_availability.dart';
import 'providers/cart_provider.dart';
import 'widgets/cart_confirm_dialog.dart';

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

/// إعادة طلب — تفريغ السلة وإضافة منتجات هذا الطلب فقط مع مراجعة المخزون
Future<void> reorderToCart(
  BuildContext context,
  WidgetRef ref,
  OrderDetailModel order,
) async {
  if (order.items.isEmpty) return;

  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    ),
  );

  try {
    await ref.read(authNotifierProvider.notifier).syncPricePolicyFromErp();
    final items = await resolveReorderCartItems(ref, order);
    ref.read(cartNotifierProvider.notifier).replaceItems(items);

    if (!context.mounted) return;
    Navigator.of(context).pop();

    await context.push(AppRoutes.cart);

    if (!context.mounted) return;
    if (cartContainsOutOfStock(items)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تمت إضافة المنتجات — يوجد منتجات نافذة في السلة',
          ),
        ),
      );
    }
  } catch (_) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تعذر إعادة الطلب، حاول مرة أخرى')),
    );
  }
}

/// يمنع إكمال الشراء إذا وُجدت منتجات نافذة — يعرض تحذيراً
Future<bool> ensureCartReadyForCheckout(BuildContext context, WidgetRef ref) async {
  final items = ref.read(cartNotifierProvider);
  if (items.isEmpty) return false;
  if (!cartContainsOutOfStock(items)) return true;

  await CartConfirmDialog.showOutOfStockCheckoutWarning(context);
  return false;
}
