import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../checkout/data/local_orders_storage.dart';
import '../../data/models/order_model.dart';
import '../../data/orders_mock_data.dart';
import '../providers/orders_provider.dart';

/// صفحة تفاصيل الطلب
class OrderDetailsPage extends ConsumerWidget {
  const OrderDetailsPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    OrderDetailModel? localOrder;
    for (final item in ref.watch(localOrdersNotifierProvider)) {
      if (item.id == orderId) {
        localOrder = item;
        break;
      }
    }

    if (localOrder != null) {
      return _OrderDetailsBody(order: localOrder);
    }

    final erpAsync = ref.watch(erpOrderDetailProvider(orderId));

    return erpAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _OrderDetailsBody(
        order: OrdersMockData.detailFor(orderId),
      ),
      data: (OrderDetailModel? order) => _OrderDetailsBody(
        order: order ?? OrdersMockData.detailFor(orderId),
      ),
    );
  }
}

class _OrderDetailsBody extends StatelessWidget {
  const _OrderDetailsBody({required this.order});

  final OrderDetailModel order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                'تفاصيل الطلب',
                style: AppTextStyles.ordersPageTitle(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                children: [
                  _InfoCard(
                    children: [
                      _InlineInfoRow(
                        label: 'اسم الزبون :',
                        value: order.customerName,
                      ),
                      _InlineInfoRow(label: 'رقم الهاتف :', value: order.phone),
                      _InlineInfoRow(
                        label: 'رقم هاتف آخر :',
                        value: order.altPhone ?? 'لا يوجد',
                      ),
                      _InlineInfoRow(
                        label: 'عنوان التوصيل :',
                        value: order.deliveryAddress,
                        isLast: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        label: 'تاريخ الطلب :',
                        value: order.formattedOrderDate,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'المنتجات المطلوبة ( ${order.items.length} )',
                    style: AppTextStyles.ordersSectionTitle(),
                  ),
                  SizedBox(height: 12.h),
                  _InfoCard(
                    children: [
                      for (var i = 0; i < order.items.length; i++) ...[
                        if (i > 0) ...[
                          SizedBox(height: 12.h),
                          Divider(
                            color: AppColors.dotGrid,
                            height: 1,
                          ),
                          SizedBox(height: 12.h),
                        ],
                        _OrderLineItemRow(item: order.items[i]),
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
                        value: order.formattedPrice,
                        valueColor: AppColors.primary,
                      ),
                      SizedBox(height: 10.h),
                      _InfoRow(
                        label: 'سعر التوصيل :',
                        value: order.formattedDeliveryPrice,
                        valueColor: order.deliveryPrice == 0
                            ? AppColors.orderFreeDelivery
                            : AppColors.textPrimary,
                      ),
                      SizedBox(height: 10.h),
                      _InfoRow(
                        label: 'السعر الكلي :',
                        value: order.formattedTotalPrice,
                        valueColor: AppColors.orderTotalPrice,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _OrderDetailsFooter(
              onBack: () => context.pop(),
              onReorder: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
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

class _OrderLineItemRow extends StatelessWidget {
  const _OrderLineItemRow({required this.item});

  final OrderLineItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: item.imageBgColor,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
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
                item.productName,
                style: AppTextStyles.ordersCardTitle().copyWith(fontSize: 15.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                'الكمية المطلوبة : ${item.quantity}',
                style: AppTextStyles.ordersDetailLabel(),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.primary, width: 1.2),
          ),
          child: Text(
            item.formattedPrice,
            style: AppTextStyles.ordersItemPrice(),
          ),
        ),
      ],
    );
  }
}

class _OrderDetailsFooter extends StatelessWidget {
  const _OrderDetailsFooter({
    required this.onBack,
    required this.onReorder,
  });

  final VoidCallback onBack;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.orderDetailsFooter,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(28.r),
              child: InkWell(
                onTap: onReorder,
                borderRadius: BorderRadius.circular(28.r),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  alignment: Alignment.center,
                  child: Text(
                    'أعادة الطلب',
                    style: AppTextStyles.buttonPrimary(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Material(
              color: AppColors.orderBackButton,
              borderRadius: BorderRadius.circular(28.r),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(28.r),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  alignment: Alignment.center,
                  child: Text(
                    'العودة',
                    style: AppTextStyles.buttonPrimary(
                      color: AppColors.textOnPrimary,
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
