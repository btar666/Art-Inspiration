import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/home/data/home_mock_data.dart';
import '../../features/home/data/models/product_model.dart';
import 'product_details_app_bar_metrics.dart';
import 'product_details_bottom_bar_metrics.dart';
import 'product_details_gallery_metrics.dart';

/// صفحة تفاصيل المنتج — ويدجت قابل لإعادة الاستخدام من أي مكان
class ProductDetailsWidget extends StatefulWidget {
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
  State<ProductDetailsWidget> createState() => _ProductDetailsWidgetState();
}

class _ProductDetailsWidgetState extends State<ProductDetailsWidget> {
  late int _quantity;
  late int _selectedImageIndex;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _selectedImageIndex = 0;
    _isFavorite = false;
  }

  ProductModel get product => widget.product;

  String get _detailsDescription =>
      HomeMockData.detailsDescriptionFor(product);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final whiteHeight =
        screenHeight * ProductDetailsBottomBarMetrics.whiteContainerHeightFraction;
    final bottomRadius =
        ProductDetailsBottomBarMetrics.whiteContainerBottomRadius();

    return Scaffold(
      backgroundColor: ProductDetailsBottomBarMetrics.pageBackground,
      body: Column(
        children: [
          SizedBox(
            height: whiteHeight,
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
                child: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: _ProductDetailsAppBar(
                        isFavorite: _isFavorite,
                        onBack: () => context.pop(),
                        onFavoriteTap: () =>
                            setState(() => _isFavorite = !_isFavorite),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 8.h),
                            _ProductDetailsGallery(
                              product: product,
                              selectedIndex: _selectedImageIndex,
                              onThumbnailTap: (i) =>
                                  setState(() => _selectedImageIndex = i),
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: AppTextStyles.productDetailsName(),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      product.rating.toStringAsFixed(1),
                                      style:
                                          AppTextStyles.productDetailsRating(),
                                    ),
                                    SizedBox(width: 3.w),
                                    Icon(
                                      Icons.star_rounded,
                                      color: AppColors.homeRating,
                                      size: 16.sp,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            _ProductDetailsDivider(),
                            SizedBox(height: 14.h),
                            Text(
                              'وصف المنتج',
                              style:
                                  AppTextStyles.productDetailsSectionTitle(),
                              textAlign: TextAlign.right,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _detailsDescription,
                              style: AppTextStyles.productDetailsBody(),
                              textAlign: TextAlign.right,
                            ),
                            SizedBox(height: 16.h),
                            _ProductDetailsDivider(),
                            SizedBox(height: 14.h),
                            _ProductDetailsMetaRow(
                              label: 'تاريخ الأنتهاء :',
                              value: product.expiryDate,
                            ),
                            SizedBox(height: 10.h),
                            _ProductDetailsMetaRow(
                              label: 'المنشأ :',
                              value: product.origin,
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: ProductDetailsBottomBarMetrics.pageBackground,
              child: SafeArea(
                top: false,
                child: _ProductDetailsBottomBar(
                  price: product.formattedPrice,
                  quantity: _quantity,
                  onDecrement: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  onIncrement: () => setState(() => _quantity++),
                  onAddToCart: () => widget.onAddToCart?.call(_quantity),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        children: [
          _ProductDetailsFavoriteButton(
            isFavorite: isFavorite,
            onTap: onFavoriteTap,
          ),
          Expanded(
            child: Text(
              'صفحة المنتج',
              style: AppTextStyles.productDetailsAppBarTitle(),
              textAlign: TextAlign.center,
            ),
          ),
          _ShapeIconButton(
            size: 36.w,
            color: AppColors.primary,
            icon: Icons.arrow_back_ios_new_rounded,
            iconColor: AppColors.textOnPrimary,
            iconSize: 16.sp,
            iconRotation: math.pi,
            onTap: onBack,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ProductDetailsAppBarMetrics.favoriteWidth(),
        height: ProductDetailsAppBarMetrics.favoriteHeight(),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(
            ProductDetailsAppBarMetrics.favoriteRadius(),
          ),
          boxShadow: ProductDetailsAppBarMetrics.favoriteShadow(),
        ),
        alignment: Alignment.center,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: ProductDetailsAppBarMetrics.favoriteIconColor(),
          size: ProductDetailsAppBarMetrics.favoriteIconSize(),
        ),
      ),
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
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final mainHeight = ProductDetailsGalleryMetrics.mainImageHeight();
    final thumbWidth = ProductDetailsGalleryMetrics.thumbnailWidth();
    final thumbHeight = ProductDetailsGalleryMetrics.thumbnailHeight();
    final columnGap = ProductDetailsGalleryMetrics.columnGap();
    final visibleSlots = _imageCount > 4 ? 4 : _imageCount;
    final gap = ProductDetailsGalleryMetrics.thumbnailGapForCount(visibleSlots);

    return SizedBox(
      height: mainHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ProductDetailsMainImage(
              product: product,
              imageIndex: selectedIndex,
            ),
          ),
          SizedBox(width: columnGap),
          SizedBox(
            width: thumbWidth,
            height: mainHeight,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: _imageCount > 4
                  ? const BouncingScrollPhysics()
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
            color: product.imageBgColor,
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
        Positioned(
          right: 10.w,
          bottom: 10.h,
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

class _ProductDetailsMetaRow extends StatelessWidget {
  const _ProductDetailsMetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        style: AppTextStyles.productDetailsMeta(),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: AppTextStyles.productDetailsMetaValue(),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailsBottomBar extends StatelessWidget {
  const _ProductDetailsBottomBar({
    required this.price,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onAddToCart,
  });

  final String price;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ProductDetailsBottomBarMetrics.padding(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              ProductDetailsBottomBarMetrics.priceRowRadius(),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: ProductDetailsBottomBarMetrics.priceRowBlurSigma(),
                sigmaY: ProductDetailsBottomBarMetrics.priceRowBlurSigma(),
              ),
              child: Container(
                width: ProductDetailsBottomBarMetrics.priceRowWidth(),
                height: ProductDetailsBottomBarMetrics.priceRowHeight(),
                padding: ProductDetailsBottomBarMetrics.priceRowPadding(),
                decoration: BoxDecoration(
                  color: ProductDetailsBottomBarMetrics.priceRowBackground(),
                  borderRadius: BorderRadius.circular(
                    ProductDetailsBottomBarMetrics.priceRowRadius(),
                  ),
                  border: Border.all(
                    color: ProductDetailsBottomBarMetrics.priceRowBorderColor(),
                    width: ProductDetailsBottomBarMetrics.priceRowBorderWidth(),
                  ),
                ),
                child: Row(
                  children: [
                    Text(price, style: AppTextStyles.productDetailsPrice()),
                    const Spacer(),
                    _QuantitySelector(
                      quantity: quantity,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: ProductDetailsBottomBarMetrics.gapBetweenRows()),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              ProductDetailsBottomBarMetrics.addToCartRadius(),
            ),
            child: InkWell(
              onTap: onAddToCart,
              borderRadius: BorderRadius.circular(
                ProductDetailsBottomBarMetrics.addToCartRadius(),
              ),
              child: Ink(
                width: ProductDetailsBottomBarMetrics.addToCartWidth(),
                height: ProductDetailsBottomBarMetrics.addToCartHeight(),
                decoration: BoxDecoration(
                  color: ProductDetailsBottomBarMetrics.addToCartBackground(),
                  borderRadius: BorderRadius.circular(
                    ProductDetailsBottomBarMetrics.addToCartRadius(),
                  ),
                ),
                child: Center(
                  child: Text(
                    'اضافة الى السلة',
                    style: AppTextStyles.productDetailsAddToCart(),
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

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = ProductDetailsBottomBarMetrics.quantityButtonWidth();
    final buttonHeight = ProductDetailsBottomBarMetrics.quantityButtonHeight();
    final iconSize = ProductDetailsBottomBarMetrics.quantityButtonIconSize();
    final gap = ProductDetailsBottomBarMetrics.quantityGap();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ShapeIconButton(
          width: buttonWidth,
          height: buttonHeight,
          borderRadius: BorderRadius.circular(
            ProductDetailsBottomBarMetrics.quantityButtonRadius(),
          ),
          border: Border.all(
            color: ProductDetailsBottomBarMetrics.quantityButtonBorderColor(),
            width: ProductDetailsBottomBarMetrics.quantityButtonBorderWidth(),
          ),
          color: AppColors.primary,
          icon: Icons.remove_rounded,
          iconColor: AppColors.textOnPrimary,
          iconSize: iconSize,
          onTap: onDecrement,
        ),
        SizedBox(width: gap),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$quantity',
              style: AppTextStyles.productDetailsQuantity(),
            ),
            SizedBox(height: 2.h),
            Container(
              width: ProductDetailsBottomBarMetrics.quantityUnderlineWidth(),
              height: ProductDetailsBottomBarMetrics.quantityUnderlineHeight(),
              color: ProductDetailsBottomBarMetrics.quantityUnderlineColor(),
            ),
          ],
        ),
        SizedBox(width: gap),
        _ShapeIconButton(
          width: buttonWidth,
          height: buttonHeight,
          borderRadius: BorderRadius.circular(
            ProductDetailsBottomBarMetrics.quantityButtonRadius(),
          ),
          border: Border.all(
            color: ProductDetailsBottomBarMetrics.quantityButtonBorderColor(),
            width: ProductDetailsBottomBarMetrics.quantityButtonBorderWidth(),
          ),
          color: AppColors.primary,
          icon: Icons.add_rounded,
          iconColor: AppColors.textOnPrimary,
          iconSize: iconSize,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _ShapeIconButton extends StatelessWidget {
  const _ShapeIconButton({
    this.size,
    this.width,
    this.height,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.onTap,
    this.borderRadius,
    this.border,
    this.iconRotation = 0,
  });

  final double? size;
  final double? width;
  final double? height;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final double iconRotation;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size!;
    final h = height ?? size!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: borderRadius,
          border: border,
        ),
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: iconRotation,
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}
