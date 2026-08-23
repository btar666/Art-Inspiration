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
    var urls = order.previewImageUrls;
    if (urls.isEmpty) {
      final fallback = ref.watch(orderPreviewImageProvider(order.id)).value;
      final trimmed = fallback?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        urls = [trimmed];
      }
    }

    return _OrderPreviewCollage(
      urls: urls.take(OrderModel.maxPreviewImages).toList(),
      background: order.imageBgColor,
    );
  }
}

/// شبكة صور الفاتورة: صورة واحدة، أو 2 / 3 / 4 كحد أقصى
class _OrderPreviewCollage extends StatelessWidget {
  const _OrderPreviewCollage({
    required this.urls,
    required this.background,
  });

  final List<String> urls;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      height: 96.w,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: urls.isEmpty
          ? _placeholderIcon()
          : urls.length == 1
              ? _thumb(urls.first)
              : ColoredBox(
                  color: Colors.white,
                  child: _grid(urls),
                ),
    );
  }

  Widget _grid(List<String> urls) {
    final gap = 1.5.w;
    switch (urls.length) {
      case 2:
        return Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(child: _thumb(urls[0])),
            SizedBox(width: gap),
            Expanded(child: _thumb(urls[1])),
          ],
        );
      case 3:
        return Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(child: _thumb(urls[0])),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _thumb(urls[1])),
                  SizedBox(height: gap),
                  Expanded(child: _thumb(urls[2])),
                ],
              ),
            ),
          ],
        );
      default:
        return Column(
          children: [
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(child: _thumb(urls[0])),
                  SizedBox(width: gap),
                  Expanded(child: _thumb(urls[1])),
                ],
              ),
            ),
            SizedBox(height: gap),
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(child: _thumb(urls[2])),
                  SizedBox(width: gap),
                  Expanded(child: _thumb(urls[3])),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _thumb(String url) {
    return ClipRect(
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, __) => _placeholderIcon(compact: true),
        errorWidget: (_, __, ___) => _placeholderIcon(compact: true),
      ),
    );
  }

  Widget _placeholderIcon({bool compact = false}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: compact ? 4.h : 12.h,
          child: Container(
            width: compact ? 28.w : 56.w,
            height: compact ? 28.w : 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
        Icon(
          Icons.spa_outlined,
          size: compact ? 22.sp : 40.sp,
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
