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
import '../widgets/order_details_action_bar.dart';

/// مقاييس صفحة تفاصيل الطلب — نفس آلية صفحة تفاصيل المنتج
abstract final class OrderDetailsPageMetrics {
  static const Color pageBackground = Color(0xFFEAECFC);

  static const double footerHeightFraction = 0.10;

  static double whiteContainerBottomRadius() => 44.r;

  static EdgeInsets footerPadding() => EdgeInsets.symmetric(horizontal: 24.w);

  static List<BoxShadow> cardShadow() => [
        BoxShadow(
          color: const Color(0xFF659AB9).withValues(alpha: 0.38),
          blurRadius: 3.76.r,
          offset: Offset.zero,
        ),
      ];
}

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
      return _OrderDetailsView(order: localOrder);
    }

    final erpAsync = ref.watch(erpOrderDetailProvider(orderId));

    return erpAsync.when(
      loading: () => const Scaffold(
        backgroundColor: OrderDetailsPageMetrics.pageBackground,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _OrderDetailsView(
        order: OrdersMockData.detailFor(orderId),
      ),
      data: (OrderDetailModel? order) => _OrderDetailsView(
        order: order ?? OrdersMockData.detailFor(orderId),
      ),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView({required this.order});

  final OrderDetailModel order;

  @override
  Widget build(BuildContext context) {
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
                        'تفاصيل الطلب',
                        style: AppTextStyles.ordersPageTitle(),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      _InfoCard(
                        children: [
                          _InlineInfoRow(
                            label: 'اسم الزبون :',
                            value: order.customerName,
                          ),
                          _InlineInfoRow(
                            label: 'رقم الهاتف :',
                            value: order.phone,
                          ),
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
                        padding: EdgeInsets.fromLTRB(0, 16.h, 18.w, 16.h),
                        children: [
                          _OrderDateRow(date: order.formattedOrderDate),
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
                              Center(
                                child: Container(
                                  width: 168.w,
                                  height: 1.h,
                                  color: AppColors.dotGrid
                                      .withValues(alpha: 0.5),
                                ),
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
                        onPrimary: () {},
                        onSecondary: () => context.pop(),
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
            item.formattedPrice,
            style: AppTextStyles.ordersItemPrice(),
          ),
        ),
      ],
    );
  }
}
