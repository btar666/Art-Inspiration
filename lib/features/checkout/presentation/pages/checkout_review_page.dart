import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/data/orders_repository.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../orders/presentation/pages/order_details_page.dart';
import '../../../orders/presentation/widgets/order_details_action_bar.dart';
import '../../data/checkout_provider.dart';
import '../../data/local_orders_storage.dart';

/// الخطوة 2 — مراجعة وتأكيد الطلب
class CheckoutReviewPage extends ConsumerStatefulWidget {
  const CheckoutReviewPage({super.key});

  @override
  ConsumerState<CheckoutReviewPage> createState() => _CheckoutReviewPageState();
}

class _CheckoutReviewPageState extends ConsumerState<CheckoutReviewPage> {
  bool _submitting = false;

  Future<void> _confirmOrder() async {
    if (_submitting) return;

    final draft = ref.read(checkoutDraftProvider);
    if (draft == null || draft.selectedAddress == null) return;

    setState(() => _submitting = true);

    try {
      final order =
          await ref.read(ordersRepositoryProvider).createInvoice(draft);

      unawaited(ref.read(ordersListProvider.notifier).refreshInBackground());

      await ref.read(localOrdersNotifierProvider.notifier).addOrder(order);
      ref.read(cartNotifierProvider.notifier).clearAll();
      ref.read(checkoutDraftProvider.notifier).clear();

      if (!mounted) return;
      context.go(AppRoutes.checkoutSuccessPath(order.id));
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تأكيد الطلب — حاول مجدداً')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(checkoutDraftProvider);
    if (draft == null) {
      return Scaffold(
        backgroundColor: OrderDetailsPageMetrics.pageBackground,
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
    final formattedDate =
        '${orderDate.year} - ${orderDate.month} - ${orderDate.day}';
    final screenHeight = MediaQuery.sizeOf(context).height;
    final footerHeight =
        screenHeight * OrderDetailsPageMetrics.footerHeightFraction;
    final bottomRadius = OrderDetailsPageMetrics.whiteContainerBottomRadius();

    return Scaffold(
      backgroundColor: OrderDetailsPageMetrics.pageBackground,
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
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    children: [
                      Text(
                        'التأكد من المعلومات',
                        style: AppTextStyles.ordersPageTitle(),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      _InfoCard(
                        children: [
                          _InlineInfoRow(
                            label: 'اسم الزبون :',
                            value: draft.customerName,
                          ),
                          _InlineInfoRow(
                            label: 'رقم الهاتف :',
                            value: draft.phone,
                          ),
                          _InlineInfoRow(
                            label: 'رقم هاتف آخر :',
                            value: draft.secondPhone.isEmpty
                                ? 'لا يوجد'
                                : draft.secondPhone,
                          ),
                          _InlineInfoRow(
                            label: 'عنوان التوصيل :',
                            value: address?.fullAddress ?? '',
                            isLast: true,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _InfoCard(
                        padding: EdgeInsets.fromLTRB(0, 16.h, 18.w, 16.h),
                        children: [
                          _OrderDateRow(date: formattedDate),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'المنتجات المطلوبة ( ${draft.totalQuantity} )',
                        style: AppTextStyles.ordersSectionTitle(),
                      ),
                      SizedBox(height: 12.h),
                      _InfoCard(
                        children: [
                          for (var i = 0; i < draft.items.length; i++) ...[
                            if (i > 0) ...[
                              SizedBox(height: 12.h),
                              Center(
                                child: Container(
                                  width: 168.w,
                                  height: 1.h,
                                  color: AppColors.dotGrid.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                            ],
                            _CheckoutLineItemRow(item: draft.items[i]),
                          ],
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'تفاصيل السعر',
                        style: AppTextStyles.ordersSectionTitle(),
                      ),
                      SizedBox(height: 12.h),
                      _InfoCard(
                        children: [
                          _InfoRow(
                            label: 'سعر الطلب :',
                            value: formatIraqiPrice(draft.subtotal),
                            valueColor: AppColors.primary,
                          ),
                          SizedBox(height: 10.h),
                          _InfoRow(
                            label: 'سعر التوصيل :',
                            value: 'مجاني',
                            valueColor: AppColors.orderFreeDelivery,
                          ),
                          SizedBox(height: 10.h),
                          _InfoRow(
                            label: 'السعر الكلي :',
                            value: formatIraqiPrice(draft.subtotal),
                            valueColor: AppColors.orderTotalPrice,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: footerHeight,
            child: ColoredBox(
              color: OrderDetailsPageMetrics.pageBackground,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: OrderDetailsPageMetrics.footerPadding(),
                  child: Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(0, 5.h),
                      child: OrderDetailsActionBar(
                        primaryLabel:
                            _submitting ? 'جاري التأكيد...' : 'تأكيد الطلب',
                        secondaryLabel: 'عودة',
                        onPrimary: _submitting ? () {} : _confirmOrder,
                        onSecondary: _submitting ? () {} : () => context.pop(),
                      ),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.children,
    this.padding,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: OrderDetailsPageMetrics.cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _OrderDateRow extends StatelessWidget {
  const _OrderDateRow({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: Text(
            date,
            style: AppTextStyles.ordersDetailValue(),
          ),
        ),
        const Spacer(),
        Text(
          'تاريخ الطلب :',
          style: AppTextStyles.ordersDetailLabel(),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

class _InlineInfoRow extends StatelessWidget {
  const _InlineInfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Align(
        alignment: Alignment.centerRight,
        child: Wrap(
          spacing: 6.w,
          runSpacing: 4.h,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.end,
          children: [
            Text(label, style: AppTextStyles.ordersDetailLabel()),
            Text(
              value,
              style: AppTextStyles.ordersDetailValue(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 6.w,
        runSpacing: 4.h,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.end,
        children: [
          Text(label, style: AppTextStyles.ordersDetailLabel()),
          Text(
            value,
            style: AppTextStyles.ordersDetailValue(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _CheckoutLineItemRow extends StatelessWidget {
  const _CheckoutLineItemRow({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: product.imageBgColor,
            borderRadius: BorderRadius.circular(14.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: product.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: product.imageUrl!,
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.spa_outlined,
                  size: 32.sp,
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: AppTextStyles.ordersCardTitle().copyWith(fontSize: 15.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                'الكمية المطلوبة : ${item.quantity}',
                style: AppTextStyles.ordersDetailLabel(
                  color: const Color(0xFF3D3E46).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.primary, width: 0.5),
          ),
          child: Text(
            product.formattedPrice,
            style: AppTextStyles.ordersItemPrice(),
          ),
        ),
      ],
    );
  }
}
