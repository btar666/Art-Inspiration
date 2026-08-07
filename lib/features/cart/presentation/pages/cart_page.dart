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
import '../widgets/cart_page_metrics.dart';
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
    final totalQuantity =
        items.fold(0, (sum, item) => sum + item.quantity);
    final subtotal = ref.watch(cartSubtotalProvider);
    final cart = ref.read(cartNotifierProvider.notifier);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final footerHeight = screenHeight * CartPageMetrics.footerHeightFraction;
    final bottomRadius = CartPageMetrics.whiteContainerBottomRadius();

    Future<void> onRefresh() => cart.reload();

    return Scaffold(
      backgroundColor: CartPageMetrics.pageBackground,
      body: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(bottomRadius),
                  bottomRight: Radius.circular(bottomRadius),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(bottomRadius),
                  bottomRight: Radius.circular(bottomRadius),
                ),
                child: SafeArea(
                  bottom: false,
                  child: isEmpty
                      ? AppRefreshIndicator(
                          onRefresh: onRefresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: [
                              CartPageHeader(
                                onBack: () => context.pop(),
                              ),
                              const CartEmptyState(),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CartPageHeader(
                              onBack: () => context.pop(),
                              showClearAll: true,
                              onClearAll: () =>
                                  _confirmClearAll(context, ref),
                            ),
                            Expanded(
                              child: AppRefreshIndicator(
                                onRefresh: onRefresh,
                                child: ListView(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                    20.w,
                                    12.h,
                                    20.w,
                                    16.h,
                                  ),
                                  children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'المنتجات ( $totalQuantity )',
                                      style:
                                          AppTextStyles.cartSectionTitle(),
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
                                    deliveryLabel: 'مجاني',
                                    total: _formatPrice(subtotal),
                                    isFreeDelivery: true,
                                  ),
                                ],
                              ),
                            ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          if (!isEmpty)
            SizedBox(
              height: footerHeight,
              child: ColoredBox(
                color: CartPageMetrics.pageBackground,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: CartPageMetrics.footerPadding(),
                    child: Transform.translate(
                      offset: CartPageMetrics.footerButtonOffset(),
                      child: CartCheckoutFooter(
                        onTap: () => _startCheckout(context, ref),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
