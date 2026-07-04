import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/data/models/order_status.dart';
import '../../data/checkout_provider.dart';
import '../../data/local_orders_storage.dart';
import '../widgets/checkout_bottom_bar.dart';
import '../widgets/checkout_info_card.dart';
import '../widgets/checkout_product_row.dart';

/// الخطوة 2 — مراجعة وتأكيد الطلب
class CheckoutReviewPage extends ConsumerWidget {
  const CheckoutReviewPage({super.key});

  Future<void> _confirmOrder(BuildContext context, WidgetRef ref) async {
    final draft = ref.read(checkoutDraftProvider);
    if (draft == null || draft.selectedAddress == null) return;

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final address = draft.selectedAddress!;
    final firstItem = draft.items.first.product;

    final order = OrderDetailModel(
      id: orderId,
      orderName: 'طلب ${draft.totalQuantity} منتج',
      address: address.fullAddress,
      price: draft.subtotal,
      status: OrderStatus.reviewing,
      imageUrl: firstItem.imageUrl,
      imageBgColor: firstItem.imageBgColor,
      customerName: draft.customerName,
      phone: draft.phone,
      altPhone: draft.secondPhone.isEmpty ? null : draft.secondPhone,
      deliveryAddress: address.fullAddress,
      orderDate: DateTime.now(),
      deliveryPrice: 0,
      items: draft.items
          .map(
            (item) => OrderLineItem(
              productName: item.product.name,
              quantity: item.quantity,
              price: item.product.price,
              imageUrl: item.product.imageUrl,
              imageBgColor: item.product.imageBgColor,
            ),
          )
          .toList(),
    );

    await ref.read(localOrdersNotifierProvider.notifier).addOrder(order);
    ref.read(cartNotifierProvider.notifier).clearAll();
    ref.read(checkoutDraftProvider.notifier).clear();

    if (!context.mounted) return;
    context.go(AppRoutes.checkoutSuccessPath(orderId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(checkoutDraftProvider);
    if (draft == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: PageBackHeader(
            title: 'التأكد من المعلومات',
            onBack: () => context.pop(),
          ),
        ),
      );
    }

    final address = draft.selectedAddress;
    final orderDate = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageBackHeader(
              title: 'التأكد من المعلومات',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                children: [
                  CheckoutInfoCard(
                    rows: [
                      ('اسم الزبون', draft.customerName),
                      ('رقم الهاتف', draft.phone),
                      (
                        'رقم هاتف آخر',
                        draft.secondPhone.isEmpty ? 'لا يوجد' : draft.secondPhone,
                      ),
                      ('عنوان التوصيل', address?.fullAddress ?? ''),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  CheckoutInfoCard(
                    rows: [
                      (
                        'تاريخ الطلب',
                        '${orderDate.year} - ${orderDate.month} - ${orderDate.day}',
                      ),
                    ],
                    compact: true,
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'المنتجات المطلوبة ( ${draft.totalQuantity} )',
                      style: AppTextStyles.checkoutSectionTitle(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CheckoutInfoCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < draft.items.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 24.h,
                              color: AppColors.orderCardDivider,
                            ),
                          CheckoutProductRow(item: draft.items[i]),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'تفاصيل السعر',
                      style: AppTextStyles.checkoutSectionTitle(),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CheckoutInfoCard(
                    child: Column(
                      children: [
                        _PriceRow(
                          label: 'سعر الطلب :',
                          value: formatIraqiPrice(draft.subtotal),
                          valueColor: AppColors.primary,
                        ),
                        SizedBox(height: 10.h),
                        _PriceRow(
                          label: 'سعر التوصيل :',
                          value: 'مجاني',
                          valueColor: AppColors.orderStatusDeliveredText,
                        ),
                        SizedBox(height: 10.h),
                        _PriceRow(
                          label: 'السعر الكلي :',
                          value: formatIraqiPrice(draft.subtotal),
                          valueColor: AppColors.notificationDot,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CheckoutBottomBar(
              label: 'تأكيد الطلب',
              secondaryLabel: 'عودة',
              onTap: () => _confirmOrder(context, ref),
              onSecondaryTap: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.cartPriceLabel(
            weight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.cartPriceValue(
            color: valueColor,
            weight: bold ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
