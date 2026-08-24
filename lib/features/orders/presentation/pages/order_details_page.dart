import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../cart/presentation/widgets/cart_checkout_footer.dart';
import '../../../cart/presentation/widgets/cart_page_metrics.dart';
import '../../../checkout/data/local_orders_storage.dart';
import '../../../checkout/presentation/widgets/checkout_review_overlay_metrics.dart';
import '../../data/models/order_model.dart';
import '../providers/orders_provider.dart';
import '../../../../core/network/connectivity_error_handler.dart';
import '../../../../shared/widgets/skeleton/order_details_skeleton.dart';

/// مقاييس صفحة تفاصيل الطلب — نفس آلية صفحة تفاصيل المنتج
abstract final class OrderDetailsPageMetrics {
  static const Color pageBackground = Color(0xFFEAECFC);

  static const double footerHeightFraction = 0.10;

  static double whiteContainerBottomRadius() => 44.r;

  static EdgeInsets footerPadding() => EdgeInsets.symmetric(horizontal: 24.w);

  static EdgeInsets checkoutFooterPadding() => EdgeInsets.fromLTRB(
        24.w,
        14.h,
        24.w,
        16.h,
      );

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
    final erpAsync = ref.watch(erpOrderDetailProvider(orderId));

    return erpAsync.when(
      loading: () => const OrderDetailsSkeleton(),
      error: (error, _) {
        final localOrder =
            ref.read(localOrdersNotifierProvider.notifier).orderById(orderId);
        if (localOrder != null) {
          return _OrderDetailsView(order: localOrder);
        }
        return ConnectivityErrorGate(
          error: error,
          onRetry: () async => ref.invalidate(erpOrderDetailProvider(orderId)),
          child: const OrderDetailsSkeleton(),
        );
      },
      data: (OrderDetailModel? order) {
        if (order == null) {
          final localOrder =
              ref.read(localOrdersNotifierProvider.notifier).orderById(orderId);
          if (localOrder != null) {
            return _OrderDetailsView(order: localOrder);
          }
          return const _OrderDetailsMissing(
            message: 'الطلب غير موجود',
          );
        }
        return _OrderDetailsView(order: order);
      },
    );
  }
}

class _OrderDetailsMissing extends StatelessWidget {
  const _OrderDetailsMissing({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            PageBackHeader(
              title: 'تفاصيل الطلب',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: Center(
                child: Text(
                  message,
                  style: AppTextStyles.ordersDetailValue(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailsView extends ConsumerWidget {
  const _OrderDetailsView({required this.order});

  final OrderDetailModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final customerName = _displayField(order.customerName, user?.name);
    final phone = _displayField(order.phone, user?.phone);
    final altPhone = order.altPhone?.trim().isNotEmpty == true
        ? order.altPhone!.trim()
        : 'لا يوجد';

    final footerPadding = CartPageMetrics.footerPadding();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                PageBackHeader(
                  title: 'تفاصيل الطلب',
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      0,
                      16.w,
                      CheckoutReviewOverlayMetrics.scrollBottomInset(context),
                    ),
                    children: [
                      _InfoCard(
                        children: [
                          _InlineInfoRow(
                            label: 'اسم الزبون :',
                            value: customerName,
                          ),
                          _InlineInfoRow(
                            label: 'رقم الهاتف :',
                            value: phone,
                          ),
                          _InlineInfoRow(
                            label: 'رقم هاتف آخر :',
                            value: altPhone,
                          ),
                          _InlineInfoRow(
                            label: 'طريقة الاستلام :',
                            value: order.displayDeliveryMethodLabel,
                            isLast: order.isPickupAtCompany,
                          ),
                          if (!order.isPickupAtCompany)
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
                        'المنتجات المطلوبة',
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
                            label: 'السعر الكلي :',
                            value: order.formattedPrice,
                            valueColor: AppColors.orderTotalPrice,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: footerPadding.left,
            right: footerPadding.right,
            bottom: CheckoutReviewOverlayMetrics.overlayBottomOffset(context),
            child: CartCheckoutFooter(
              label: 'إعادة الطلب',
              onTap: () => reorderToCart(context, ref, order),
              glassy: true,
            ),
          ),
        ],
      ),
    );
  }

  String _displayField(String value, String? fallback) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && trimmed != '—') return trimmed;
    final fb = fallback?.trim() ?? '';
    return fb.isEmpty ? '—' : fb;
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
    return _OrderDetailTextRow(
      label: 'تاريخ الطلب :',
      value: date,
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
      child: _OrderDetailTextRow(label: label, value: value),
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
    return _OrderDetailTextRow(
      label: label,
      value: value,
      valueColor: valueColor,
    );
  }
}

class _OrderDetailTextRow extends StatelessWidget {
  const _OrderDetailTextRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: AppTextStyles.ordersDetailLabel(),
          ),
          TextSpan(
            text: ' $value',
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
    final imageUrl = item.imageUrl?.trim();

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
          clipBehavior: Clip.antiAlias,
          child: imageUrl == null || imageUrl.isEmpty
              ? Icon(
                  Icons.spa_outlined,
                  size: 32.sp,
                  color: AppColors.primary.withValues(alpha: 0.35),
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  placeholder: (_, __) => Center(
                    child: Icon(
                      Icons.spa_outlined,
                      size: 32.sp,
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Center(
                    child: Icon(
                      Icons.spa_outlined,
                      size: 32.sp,
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
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
