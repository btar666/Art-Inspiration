import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../checkout/data/checkout_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_confirm_dialog.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_page_header.dart';
import '../widgets/cart_price_summary.dart';

/// صفحة السلة
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  String _formatPrice(int value) {
    final formatted = value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$formatted د.ع';
  }

  Future<void> _confirmRemoveItem(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final confirmed = await CartConfirmDialog.show(
      context,
      title: 'حذف المنتج من السلة',
      confirmLabel: 'حذف المنتج',
    );
    if (!confirmed || !context.mounted) return;
    ref.read(cartNotifierProvider.notifier).removeAt(index);
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await CartConfirmDialog.show(
      context,
      title: 'أفرغ السلة',
      confirmLabel: 'أفرغ السلة',
    );
    if (!confirmed || !context.mounted) return;
    ref.read(cartNotifierProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartNotifierProvider);
    final isEmpty = items.isEmpty;
    final totalQuantity =
        items.fold(0, (sum, item) => sum + item.quantity);
    final subtotal = ref.watch(cartSubtotalProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final cart = ref.read(cartNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CartPageHeader(
              onBack: () => context.pop(),
              showClearAll: !isEmpty,
              onClearAll: () => _confirmClearAll(context, ref),
            ),
            Expanded(
              child: isEmpty
                  ? const CartEmptyState()
                  : ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'المنتجات ( $totalQuantity )',
                            style: AppTextStyles.cartSectionTitle(),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...List.generate(items.length, (index) {
                          final item = items[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: CartItemCard(
                              item: item,
                              onRemove: () =>
                                  _confirmRemoveItem(context, ref, index),
                              onIncrement: () => cart.incrementQuantity(index),
                              onDecrement: () => cart.decrementQuantity(index),
                            ),
                          );
                        }),
                        SizedBox(height: 8.h),
                        CartPriceSummary(
                          subtotal: _formatPrice(subtotal),
                          deliveryLabel: 'مجاني',
                          total: _formatPrice(subtotal),
                          isFreeDelivery: true,
                        ),
                      ],
                    ),
            ),
            if (!isEmpty)
              Container(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  12.h,
                  20.w,
                  12.h + bottomInset,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orderDetailsFooter,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orderCardShadow,
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Material(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(28.r),
                  child: InkWell(
                    onTap: () {
                      final items = ref.read(cartNotifierProvider);
                      if (items.isEmpty) return;
                      ref
                          .read(checkoutDraftProvider.notifier)
                          .startFromCart(items);
                      context.push(AppRoutes.checkout);
                    },
                    borderRadius: BorderRadius.circular(28.r),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      alignment: Alignment.center,
                      child: Text(
                        'أكمال الشراء',
                        style: AppTextStyles.cartCheckoutButton(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
