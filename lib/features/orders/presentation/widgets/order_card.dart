import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/order_model.dart';
import '../providers/orders_provider.dart';

/// كارد طلب في قائمة الفواتير
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final OrderModel order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 120.h),
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.orderCardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OrderImage(order: order),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    order.orderName,
                    style: AppTextStyles.ordersCardTitle(),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (order.formattedOrderDate.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      order.formattedOrderDate,
                      style: AppTextStyles.ordersCardSubtitle(),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 5.h),
                  const _DottedDivider(),
                  SizedBox(height: 5.h),
                  Text(
                    'السعر : ${order.formattedPrice}',
                    style: AppTextStyles.ordersCardPrice(),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderImage extends ConsumerWidget {
  const _OrderImage({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directUrl = order.imageUrl?.trim();
    final hasDirect = directUrl != null && directUrl.isNotEmpty;

    final resolvedUrl = hasDirect
        ? directUrl
        : ref.watch(orderPreviewImageProvider(order.id)).value;

    final imageUrl = (resolvedUrl != null && resolvedUrl.isNotEmpty)
        ? resolvedUrl
        : null;

    return Container(
      width: 96.w,
      height: 96.w,
      decoration: BoxDecoration(
        color: order.imageBgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => _placeholderIcon(),
              errorWidget: (_, __, ___) => _placeholderIcon(),
            )
          : _placeholderIcon(),
    );
  }

  Widget _placeholderIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 12.h,
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
        Icon(
          Icons.spa_outlined,
          size: 40.sp,
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ],
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dotWidth = 3.w;
        final gap = 2.4.w;
        final count =
            ((constraints.maxWidth + gap) / (dotWidth + gap)).floor().clamp(8, 48);

        return Row(
          children: List.generate(
            count,
            (index) => Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : gap),
              child: Container(
                width: dotWidth,
                height: 1.5.h,
                color: AppColors.dotGrid,
              ),
            ),
          ),
        );
      },
    );
  }
}
