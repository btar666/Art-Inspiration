import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_refresh_scroll_view.dart';
import '../../../checkout/data/checkout_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_checkout_footer.dart';
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
      CartConfirmType.removeItem,
    );
    if (!confirmed || !context.mounted) return;
    ref.read(cartNotifierProvider.notifier).removeAt(index);
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await CartConfirmDialog.show(
      context,
      CartConfirmType.clearCart,
    );
    if (!confirmed || !context.mounted) return;
    ref.read(cartNotifierProvider.notifier).clearAll();
  }

  void _startCheckout(BuildContext context, WidgetRef ref) {
    final items = ref.read(cartNotifierProvider);
    if (items.isEmpty) return;
    ref.read(checkoutDraftProvider.notifier).startFromCart(items);
    context.push(AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartNotifierProvider);
    final isEmpty = items.isEmpty;
    final totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);
    final subtotal = ref.watch(cartSubtotalProvider);
    final cart = ref.read(cartNotifierProvider.notifier);

    Future<void> onRefresh() => cart.reload();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CartPageHeader(
                    onBack: () => context.pop(),
                  ),
                  Expanded(
                    child: AppRefreshIndicator(
                      onRefresh: onRefresh,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: const CartEmptyState(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CartPageHeader(
                    onBack: () => context.pop(),
                    showClearAll: true,
                    onClearAll: () => _confirmClearAll(context, ref),
                  ),
                  Expanded(
                    child: AppRefreshIndicator(
                      onRefresh: onRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
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
                                onRemove: () => _confirmRemoveItem(
                                  context,
                                  ref,
                                  index,
                                ),
                                onIncrement: () =>
                                    cart.incrementQuantity(index),
                                onDecrement: () =>
                                    cart.decrementQuantity(index),
                              ),
                            );
                          }),
                          SizedBox(height: 8.h),
                          CartPriceSummary(
                            subtotal: _formatPrice(subtotal),
                          ),
                          SizedBox(height: 20.h),
                          CartCheckoutFooter(
                            onTap: () => _startCheckout(context, ref),
                            glassy: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
