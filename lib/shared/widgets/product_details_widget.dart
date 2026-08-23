import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/cart/presentation/cart_actions.dart';
import '../../features/favorites/presentation/favorites_actions.dart';
import '../../features/favorites/presentation/providers/favorites_provider.dart';
import '../../features/home/data/models/product_model.dart';
import '../../features/home/presentation/providers/user_price_policy_provider.dart';
import 'product_details_app_bar_metrics.dart';
import 'app_back_button.dart';
import 'add_to_cart_snackbar.dart';
import 'glass_favorite_button.dart';
import 'product_details_bottom_bar_metrics.dart';
import 'product_details_gallery_metrics.dart';
import 'product_image_fullscreen_viewer.dart';
import 'product_out_of_stock_badge.dart';

/// صفحة تفاصيل المنتج — ويدجت قابل لإعادة الاستخدام من أي مكان
class ProductDetailsWidget extends ConsumerStatefulWidget {
  const ProductDetailsWidget({
    super.key,
    required this.product,
    this.onAddToCart,
    this.initialQuantity = 1,
  });

  final ProductModel product;
  final void Function(int quantity)? onAddToCart;
  final int initialQuantity;

  /// فتح صفحة التفاصيل عبر GoRouter
  static void open(BuildContext context, ProductModel product) {
    context.push(
      AppRoutes.productDetailsPath(product.id),
      extra: product,
    );
  }

  @override
  ConsumerState<ProductDetailsWidget> createState() =>
      _ProductDetailsWidgetState();
}

class _ProductDetailsWidgetState extends ConsumerState<ProductDetailsWidget> {
  late int _quantity;
  late int _selectedImageIndex;
  final _quantitySelectorKey = GlobalKey<_QuantitySelectorState>();

  @override
  void initState() {
    super.initState();
    _quantity = _clampedQuantity(widget.initialQuantity);
    _selectedImageIndex = 0;
  }

  int _clampedQuantity(int value) {
    final max = product.maxOrderQuantity;
    var next = value < 1 ? 1 : value;
    if (max != null && next > max) next = max < 1 ? 1 : max;
    return next;
  }

  bool _blockIfOutOfStock() {
    if (product.isInStock) return false;
    showOutOfStockSnackBar(context);
    return true;
  }

  void _tryIncrement() {
    if (_blockIfOutOfStock()) return;
    final max = product.maxOrderQuantity;
    if (max != null && _quantity >= max) {
      showStockLimitSnackBar(context, max);
      return;
    }
    setState(() => _quantity++);
  }

  void _tryDecrement() {
    if (_blockIfOutOfStock()) return;
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _setQuantity(int value) {
    if (_blockIfOutOfStock()) return;
    final max = product.maxOrderQuantity;
    if (max != null && value > max) {
      showStockLimitSnackBar(context, max);
      setState(() => _quantity = max < 1 ? 1 : max);
      return;
    }
    setState(() => _quantity = value < 1 ? 1 : value);
  }

  ProductModel get product => widget.product;

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(isProductFavoriteProvider(product.id));
    final priceLabel =
        product.formattedPriceFor(ref.watch(userPricePolicyProvider));
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomBarHeight =
        ProductDetailsBottomBarMetrics.occupiedHeight() + bottomInset;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: _ProductDetailsAppBar(
                  isFavorite: isFavorite,
                  onBack: () => context.pop(),
                  onFavoriteTap: () => toggleProductFavorite(ref, product),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    8.h,
                    20.w,
                    bottomBarHeight + 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProductDetailsGallery(
                        product: product,
                        selectedIndex: _selectedImageIndex,
                        onThumbnailTap: (i) =>
                            setState(() => _selectedImageIndex = i),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        product.name,
                        style: AppTextStyles.productDetailsName(),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 14.h),
                      _ProductDetailsDivider(),
                      SizedBox(height: 14.h),
                      Text(
                        'وصف المنتج',
                        style: AppTextStyles.productDetailsSectionTitle(),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        product.description,
                        style: AppTextStyles.productDetailsBody(),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: ProductDetailsBottomBarMetrics.bottomMargin() +
                bottomInset,
            child: _AddToCartBar(onAddToCart: _handleAddToCart),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: ProductDetailsBottomBarMetrics.priceRowBottom(
              safeBottom: bottomInset,
              keyboardInset: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: _PriceQuantityBar(
              quantitySelectorKey: _quantitySelectorKey,
              price: priceLabel,
              quantity: _quantity,
              onDecrement: _tryDecrement,
              onIncrement: _tryIncrement,
              onQuantitySet: _setQuantity,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart() {
    final pending =
        _quantitySelectorKey.currentState?.peekPendingQuantity();
    _quantitySelectorKey.currentState?.commitIfEditing();
    final quantity = pending ?? _quantity;
    if (widget.onAddToCart != null) {
      widget.onAddToCart!.call(quantity);
    } else {
      addProductToCart(
        context,
        ref,
        product,
        quantity: quantity,
      );
    }
  }
}

class _ProductDetailsAppBar extends StatelessWidget {
  const _ProductDetailsAppBar({
    required this.isFavorite,
    required this.onBack,
    required this.onFavoriteTap,
  });

  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          AppBackButton(onTap: onBack),
          Expanded(
            child: Text(
              'صفحة المنتج',
              style: AppTextStyles.productDetailsAppBarTitle(),
              textAlign: TextAlign.center,
            ),
          ),
          _ProductDetailsFavoriteButton(
            isFavorite: isFavorite,
            onTap: onFavoriteTap,
          ),
        ],
      ),
    );
  }
}

/// زر المفضلة في شريط صفحة التفاصيل
class _ProductDetailsFavoriteButton extends StatelessWidget {
  const _ProductDetailsFavoriteButton({
    required this.isFavorite,
    required this.onTap,
  });

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassFavoriteButton(
      isFavorite: isFavorite,
      onTap: onTap,
      width: ProductDetailsAppBarMetrics.favoriteWidth(),
      height: ProductDetailsAppBarMetrics.favoriteHeight(),
      iconSize: ProductDetailsAppBarMetrics.favoriteIconSize(),
      borderRadius: ProductDetailsAppBarMetrics.favoriteRadius(),
      iconColor: ProductDetailsAppBarMetrics.favoriteIconColor(),
    );
  }
}

class _ProductDetailsGallery extends StatelessWidget {
  const _ProductDetailsGallery({
    required this.product,
    required this.selectedIndex,
    required this.onThumbnailTap,
  });

  final ProductModel product;
  final int selectedIndex;
  final ValueChanged<int> onThumbnailTap;

  int get _imageCount {
    final gallery = product.galleryImageUrls;
    if (gallery.isNotEmpty) return gallery.length;
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) return 1;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final thumbWidth = ProductDetailsGalleryMetrics.thumbnailWidth();
    final thumbHeight = ProductDetailsGalleryMetrics.thumbnailHeight();
    final columnGap = ProductDetailsGalleryMetrics.columnGap();
    final visibleSlots = _imageCount > 4 ? 4 : _imageCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasThumbs = _imageCount > 1;
        final mainSide = ProductDetailsGalleryMetrics.mainImageSide(
          constraints.maxWidth,
          hasThumbs: hasThumbs,
        );
        final gap = ProductDetailsGalleryMetrics.thumbnailGapForCount(
          visibleSlots,
          mainSide,
        );

        if (!hasThumbs) {
          return SizedBox(
            width: mainSide,
            height: mainSide,
            child: _ProductDetailsMainImage(
              product: product,
              imageIndex: 0,
            ),
          );
        }

        return SizedBox(
          height: mainSide,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: mainSide,
                height: mainSide,
                child: _ProductDetailsMainImage(
                  product: product,
                  imageIndex: selectedIndex,
                ),
              ),
              SizedBox(width: columnGap),
              SizedBox(
                width: thumbWidth,
                height: mainSide,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: _imageCount > 4
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemCount: _imageCount,
                  separatorBuilder: (_, __) => SizedBox(height: gap),
                  itemBuilder: (context, index) => _ProductDetailsThumbnail(
                    product: product,
                    index: index,
                    isSelected: selectedIndex == index,
                    onTap: () => onThumbnailTap(index),
                    width: thumbWidth,
                    height: thumbHeight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductDetailsMainImage extends StatelessWidget {
  const _ProductDetailsMainImage({
    required this.product,
    required this.imageIndex,
  });

  final ProductModel product;
  final int imageIndex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(
              ProductDetailsGalleryMetrics.mainImageRadius(),
            ),
            boxShadow: ProductDetailsGalleryMetrics.mainImageShadow(),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              ProductDetailsGalleryMetrics.mainImageRadius(),
            ),
            child: _ProductImageContent(
              product: product,
              imageIndex: imageIndex,
            ),
          ),
        ),
        if (!product.isInStock)
          Positioned(
            top: 10.h,
            left: 10.w,
            child: const ProductOutOfStockBadge(),
          ),
        Positioned(
          right: 10.w,
          bottom: 10.h,
          child: GestureDetector(
            onTap: () => ProductImageFullscreenViewer.open(
              context,
              product: product,
              initialIndex: imageIndex,
            ),
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.open_in_full_rounded,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductDetailsThumbnail extends StatelessWidget {
  const _ProductDetailsThumbnail({
    required this.product,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.width,
    required this.height,
  });

  final ProductModel product;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: product.imageBgColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: _ProductImageContent(
            product: product,
            imageIndex: index,
            compact: true,
          ),
        ),
      ),
    );
  }
}

class _ProductImageContent extends StatelessWidget {
  const _ProductImageContent({
    required this.product,
    required this.imageIndex,
    this.compact = false,
  });

  final ProductModel product;
  final int imageIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final gallery = product.galleryImageUrls;
    final url = gallery.isNotEmpty
        ? gallery[imageIndex % gallery.length]
        : product.imageUrl;

    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, __) => Center(
          child: SizedBox(
            width: compact ? 16.sp : 28.sp,
            height: compact ? 16.sp : 28.sp,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Center(
          child: Icon(
            Icons.spa_outlined,
            size: compact ? 24.sp : 80.sp,
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        Icons.spa_outlined,
        size: compact ? 24.sp : 80.sp,
        color: AppColors.primary.withValues(alpha: 0.35),
      ),
    );
  }
}

class _ProductDetailsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.dotGrid.withValues(alpha: 0.6),
    );
  }
}

class _PriceQuantityBar extends StatelessWidget {
  const _PriceQuantityBar({
    required this.quantitySelectorKey,
    required this.price,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onQuantitySet,
  });

  final GlobalKey<_QuantitySelectorState> quantitySelectorKey;
  final String price;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<int> onQuantitySet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ProductDetailsBottomBarMetrics.horizontalMargin(),
      ),
      child: _GlassPill(
        width: ProductDetailsBottomBarMetrics.priceRowWidth(),
        height: ProductDetailsBottomBarMetrics.priceRowHeight(),
        child: Padding(
          padding: ProductDetailsBottomBarMetrics.priceRowPadding(),
          child: Row(
            children: [
              Text(price, style: AppTextStyles.productDetailsPrice()),
              const Spacer(),
              _QuantitySelector(
                key: quantitySelectorKey,
                quantity: quantity,
                onDecrement: onDecrement,
                onIncrement: onIncrement,
                onQuantitySet: onQuantitySet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.onAddToCart});

  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ProductDetailsBottomBarMetrics.horizontalMargin(),
      ),
      child: _GlassPill(
        width: ProductDetailsBottomBarMetrics.addToCartWidth(),
        height: ProductDetailsBottomBarMetrics.addToCartHeight(),
        onTap: onAddToCart,
        child: Center(
          child: Text(
            'اضافة الى السلة',
            style: AppTextStyles.productDetailsAddToCart().copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// كبسولة زجاجية بنفس تصميم زر إكمال الشراء
class _GlassPill extends StatefulWidget {
  const _GlassPill({
    required this.width,
    required this.height,
    required this.child,
    this.onTap,
  });

  final double width;
  final double height;
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_GlassPill> createState() => _GlassPillState();
}

class _GlassPillState extends State<_GlassPill> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.height);
    final pressable = widget.onTap != null;

    Widget pill = AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                width: widget.width,
                height: widget.height,
                color: const Color(0xFFEAECFC).withValues(alpha: 0.12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _WhiteInnerShadow(borderRadius: radius),
                    SizedBox.expand(child: widget.child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!pressable) return pill;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: pill,
    );
  }
}

class _QuantitySelector extends StatefulWidget {
  const _QuantitySelector({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onQuantitySet,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<int> onQuantitySet;

  @override
  State<_QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<_QuantitySelector>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  var _editing = false;
  double _lastKeyboardInset = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final inset = View.of(context).viewInsets.bottom;
    if (_editing && _lastKeyboardInset > 0 && inset <= 0) {
      commitIfEditing();
    }
    _lastKeyboardInset = inset;
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      commitIfEditing();
    }
  }

  void _startEditing() {
    _controller.text = '${widget.quantity}';
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  int? peekPendingQuantity() {
    if (!_editing) return null;
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed < 1) return 1;
    return parsed;
  }

  void commitIfEditing() {
    if (!_editing) return;
    final parsed = int.tryParse(_controller.text.trim());
    final next = (parsed == null || parsed < 1) ? 1 : parsed;
    _editing = false;
    _focusNode.unfocus();
    if (mounted) setState(() {});
    widget.onQuantitySet(next);
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = ProductDetailsBottomBarMetrics.quantityButtonSize();
    final iconSize = ProductDetailsBottomBarMetrics.quantityButtonIconSize();
    final gap = ProductDetailsBottomBarMetrics.quantityGap();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlassIconButton(
          size: buttonSize,
          icon: Icons.remove_rounded,
          iconSize: iconSize,
          onTap: () {
            commitIfEditing();
            widget.onDecrement();
          },
        ),
        SizedBox(width: gap),
        GestureDetector(
          onTap: _editing ? null : _startEditing,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: ProductDetailsBottomBarMetrics.quantityValueWidth(),
                child: _editing
                    ? TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        cursorColor: AppColors.primary,
                        style: AppTextStyles.productDetailsQuantity(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        onSubmitted: (_) => commitIfEditing(),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${widget.quantity}',
                          style: AppTextStyles.productDetailsQuantity()
                              .copyWith(height: 1),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
              ),
              SizedBox(height: 2.h),
              Container(
                width: ProductDetailsBottomBarMetrics.quantityUnderlineWidth(),
                height: ProductDetailsBottomBarMetrics.quantityUnderlineHeight(),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.r),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      ProductDetailsBottomBarMetrics.quantityUnderlineColor(),
                      AppColors.primary.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: gap),
        _GlassIconButton(
          size: buttonSize,
          icon: Icons.add_rounded,
          iconSize: iconSize,
          onTap: () {
            commitIfEditing();
            widget.onIncrement();
          },
        ),
      ],
    );
  }
}

/// زر دائري بنفس تصميم زر إكمال الشراء
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.size,
    required this.icon,
    required this.iconSize,
    required this.onTap,
  });

  final double size;
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: ColoredBox(
                color: const Color(0xFFEAECFC).withValues(alpha: 0.82),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _WhiteInnerShadow(circle: true),
                    Center(
                      child: Icon(
                        icon,
                        color: AppColors.primary,
                        size: iconSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ظل داخلي أبيض خفيف على حواف الزجاج
class _WhiteInnerShadow extends StatelessWidget {
  const _WhiteInnerShadow({
    this.borderRadius,
    this.circle = false,
  });

  final BorderRadius? borderRadius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final shape = circle ? BoxShape.circle : BoxShape.rectangle;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: shape,
              borderRadius: circle ? null : borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.38),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0, 0.5],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: shape,
              borderRadius: circle ? null : borderRadius,
              gradient: RadialGradient(
                radius: 1.08,
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.28),
                ],
                stops: const [0.68, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
