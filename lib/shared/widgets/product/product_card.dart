import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/home/data/models/product_model.dart';

/// كارد منتج قابل لإعادة الاستخدام في كل الصفحات
class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onFavoriteTap,
    this.onAddToCart,
    this.isFavorite = false,
  });

  final ProductModel product;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCart;
  final bool isFavorite;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProductImageSection(
            product: product,
            isFavorite: _isFavorite,
            onFavoriteTap: () {
              setState(() => _isFavorite = !_isFavorite);
              widget.onFavoriteTap?.call();
            },
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.homeRating,
                        size: 15.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: AppTextStyles.homeProductCategory(
                          color: AppColors.textPrimary,
                        ).copyWith(fontSize: 11.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.name,
                    style: AppTextStyles.homeProductName().copyWith(fontSize: 13.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    product.categoryName,
                    style: AppTextStyles.homeProductCategory(
                      color: AppColors.primary,
                    ).copyWith(fontSize: 10.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Expanded(
                    child: Text(
                      product.description,
                      style: AppTextStyles.homeProductDescription().copyWith(fontSize: 9.5.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _ProductPriceBar(
            price: product.formattedPrice,
            onAddToCart: widget.onAddToCart,
          ),
        ],
      ),
    );
  }
}

class _ProductImageSection extends StatelessWidget {
  const _ProductImageSection({
    required this.product,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final ProductModel product;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 130.h,
          width: double.infinity,
          color: product.imageBgColor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: -16.h,
                child: Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
              _ProductImage(product: product),
            ],
          ),
        ),
        Positioned(
          top: 8.h,
          left: 8.w,
          child: GestureDetector(
            onTap: onFavoriteTap,
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 15.sp,
                color: isFavorite ? AppColors.homeDiscount : AppColors.homeHeart,
              ),
            ),
          ),
        ),
        if (product.discountPercent != null)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.homeDiscount,
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Text(
                '-${product.discountPercent}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: product.imageUrl!,
        height: 90.h,
        fit: BoxFit.contain,
      );
    }

    return Icon(
      Icons.spa_outlined,
      size: 52.sp,
      color: AppColors.primary.withValues(alpha: 0.35),
    );
  }
}

class _ProductPriceBar extends StatelessWidget {
  const _ProductPriceBar({
    required this.price,
    this.onAddToCart,
  });

  final String price;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        Container(
          margin: EdgeInsets.only(left: 20.w),
          padding: EdgeInsets.fromLTRB(32.w, 8.h, 12.w, 8.h),
          decoration: BoxDecoration(
            color: AppColors.homePriceBar,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              price,
              style: AppTextStyles.homeProductPrice().copyWith(fontSize: 12.sp),
            ),
          ),
        ),
        Positioned(
          left: 6.w,
          top: -4.h,
          child: GestureDetector(
            onTap: onAddToCart,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
