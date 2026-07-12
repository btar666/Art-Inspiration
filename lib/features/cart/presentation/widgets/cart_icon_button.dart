import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/shake_animation.dart';
import '../../../home/presentation/widgets/home_product_card_metrics.dart';

/// نقطة حمراء صغيرة على أيقونة السلة (بدون رقم)
class CartItemDot extends StatelessWidget {
  const CartItemDot({
    super.key,
    required this.visible,
    this.top,
    this.right,
    this.dotSize,
  });

  final bool visible;
  final double? top;
  final double? right;
  final double? dotSize;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final size = dotSize ?? 9.w;

    return Positioned(
      top: top ?? 0,
      right: right ?? 2.w,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.notificationDot,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }
}

/// شارة عدد المنتجات على زر السلة
class CartItemCountBadge extends StatelessWidget {
  const CartItemCountBadge({
    super.key,
    required this.count,
    this.top,
    this.right,
  });

  final int count;
  final double? top;
  final double? right;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final label = count > 99 ? '99+' : '$count';

    return Positioned(
      top: top ?? 6.h,
      right: right ?? 6.w,
      child: Container(
        constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppColors.notificationDot,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.background, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.cartBadgeCount(),
        ),
      ),
    );
  }
}

/// زر سلة دائري — للزر العائم وشريط صفحة التفاصيل
class CartCircleIconButton extends StatelessWidget {
  const CartCircleIconButton({
    super.key,
    required this.itemCount,
    required this.animationTick,
    this.onTap,
    this.size,
    this.iconSize,
    this.showShadow = true,
    this.blurred = false,
    this.showBadge = true,
    this.showDot = false,
  });

  final int itemCount;
  final int animationTick;
  final VoidCallback? onTap;
  final double? size;
  final double? iconSize;
  final bool showShadow;
  final bool blurred;
  final bool showBadge;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 56.w;
    final cartIconSize = iconSize ?? 28.w;

    final content = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: cartIconSize,
          height: cartIconSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Image.asset(
                AppAssets.shoppingCartIcon,
                width: cartIconSize,
                height: cartIconSize,
                fit: BoxFit.contain,
              ),
              if (showDot)
                CartItemDot(visible: itemCount > 0),
            ],
          ),
        ),
        if (showBadge)
          CartItemCountBadge(
            count: itemCount,
            top: blurred ? 2.h : null,
            right: blurred ? 2.w : null,
          ),
      ],
    );

    final Widget button;
    if (blurred) {
      button = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: content,
            ),
          ),
        ),
      );
    } else {
      button = Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: content,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: button.shakeOnTick(animationTick),
    );
  }
}

/// زر إضافة للسلة في كارد المنتج — مع أنيميشن عند الضغط
class ProductCardCartButton extends StatefulWidget {
  const ProductCardCartButton({
    super.key,
    required this.onAddToCart,
  });

  final VoidCallback? onAddToCart;

  @override
  State<ProductCardCartButton> createState() => _ProductCardCartButtonState();
}

class _ProductCardCartButtonState extends State<ProductCardCartButton> {
  int _animationTick = 0;

  void _handleTap() {
    if (widget.onAddToCart == null) return;
    setState(() => _animationTick++);
    widget.onAddToCart!.call();
  }

  @override
  Widget build(BuildContext context) {
    final size = HomeProductCardMetrics.cartButtonSize();
    final iconSize = HomeProductCardMetrics.cartIconSize();

    final button = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            AppAssets.logo,
            width: size,
            height: size,
            fit: BoxFit.fill,
          ),
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              AppAssets.shoppingCartIcon,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: _handleTap,
      child: button.shakeOnTick(_animationTick),
    );
  }
}

/// زر سلة مستطيل — لشريط صفحة تفاصيل المنتج
class ProductDetailsCartButton extends StatelessWidget {
  const ProductDetailsCartButton({
    super.key,
    required this.itemCount,
    required this.animationTick,
    required this.onTap,
  });

  final int itemCount;
  final int animationTick;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF659AB9).withValues(alpha: 0.38),
              blurRadius: 3.76.r,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Image.asset(
              AppAssets.shoppingCartIcon,
              width: 20.w,
              height: 20.w,
              fit: BoxFit.contain,
            ),
            CartItemCountBadge(
              count: itemCount,
              top: 2.h,
              right: 2.w,
            ),
          ],
        ),
      ),
    );

    return button.shakeOnTick(animationTick);
  }
}
