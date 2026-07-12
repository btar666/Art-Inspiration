import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';

/// مقاييس كارد منتج السلة
abstract final class CartItemCardMetrics {
  static double cardHeight() => 106.h;

  static double borderRadius() => 20.r;

  static double imageInsetVertical() => 15.h;

  static double imageInsetEnd() => 15.w;

  static double productNameTopInset() => 26.h;

  static double contentPadding() => 12.w;

  static double thumbSize() => cardHeight() - imageInsetVertical() * 2;

  static double qtyButtonWidth() => 22.w;

  static double qtyButtonHeight() => 19.h;

  static double qtyButtonRadius() => 8.r;

  static double qtySymbolStrokeWidth() => 2;

  static double qtySymbolSize() => 10.w;

  static List<BoxShadow> cardShadow() => [
        BoxShadow(
          color: const Color(0xFF659AB9).withValues(alpha: 0.38),
          blurRadius: 3.75.r,
          offset: Offset.zero,
        ),
      ];
}

/// كارد منتج في السلة
class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final thumbSize = CartItemCardMetrics.thumbSize();

    return Container(
      height: CartItemCardMetrics.cardHeight(),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.circular(CartItemCardMetrics.borderRadius()),
        boxShadow: CartItemCardMetrics.cardShadow(),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(CartItemCardMetrics.borderRadius()),
        child: Row(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        CartItemCardMetrics.contentPadding(),
                        CartItemCardMetrics.productNameTopInset(),
                        8.w,
                        4.h,
                      ),
                      child: Row(
                        textDirection: TextDirection.ltr,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: onRemove,
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                              Icons.close_rounded,
                              size: 20.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              product.name,
                              style: AppTextStyles.cartItemName(),
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: CartItemCardMetrics.contentPadding(),
                      right: 8.w,
                    ),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.dotGrid.withValues(alpha: 0.45),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      CartItemCardMetrics.contentPadding(),
                      6.h,
                      8.w,
                      8.h,
                    ),
                    child: Row(
                      textDirection: TextDirection.ltr,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _QuantitySelector(
                          quantity: item.quantity,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                        ),
                        const Spacer(),
                        Text(
                          'السعر : ${product.formattedPrice}',
                          style: AppTextStyles.cartItemPrice(),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: CartItemCardMetrics.imageInsetVertical(),
                right: CartItemCardMetrics.imageInsetEnd(),
                bottom: CartItemCardMetrics.imageInsetVertical(),
              ),
              child: _ProductThumb(
                product: product,
                size: thumbSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({
    required this.product,
    required this.size,
  });

  final ProductModel product;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: product.imageBgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: product.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: product.imageUrl!,
              fit: BoxFit.cover,
            )
          : Center(
              child: Icon(
                Icons.image_outlined,
                color: AppColors.primarySoft,
                size: 24.sp,
              ),
            ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QtyButton(
          isPlus: false,
          filled: false,
          onTap: onDecrement,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            '$quantity',
            style: AppTextStyles.cartQuantity(),
          ),
        ),
        _QtyButton(
          isPlus: true,
          filled: true,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.isPlus,
    required this.filled,
    required this.onTap,
  });

  final bool isPlus;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: CartItemCardMetrics.qtyButtonWidth(),
        height: CartItemCardMetrics.qtyButtonHeight(),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : const Color(0xFFF0F2F8),
          borderRadius:
              BorderRadius.circular(CartItemCardMetrics.qtyButtonRadius()),
        ),
        alignment: Alignment.center,
        child: _QtySymbol(
          isPlus: isPlus,
          color: filled ? AppColors.background : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _QtySymbol extends StatelessWidget {
  const _QtySymbol({
    required this.isPlus,
    required this.color,
  });

  final bool isPlus;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = CartItemCardMetrics.qtySymbolSize();

    return CustomPaint(
      size: Size(size, size),
      painter: _QtySymbolPainter(
        isPlus: isPlus,
        color: color,
        strokeWidth: CartItemCardMetrics.qtySymbolStrokeWidth(),
      ),
    );
  }
}

class _QtySymbolPainter extends CustomPainter {
  _QtySymbolPainter({
    required this.isPlus,
    required this.color,
    required this.strokeWidth,
  });

  final bool isPlus;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final halfLen = size.width / 2 - strokeWidth / 2;

    canvas.drawLine(
      Offset(centerX - halfLen, centerY),
      Offset(centerX + halfLen, centerY),
      paint,
    );

    if (isPlus) {
      canvas.drawLine(
        Offset(centerX, centerY - halfLen),
        Offset(centerX, centerY + halfLen),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QtySymbolPainter oldDelegate) {
    return oldDelegate.isPlus != isPlus ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
