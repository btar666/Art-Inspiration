import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/presentation/widgets/cart_icon_button.dart';
import '../../../favorites/presentation/favorites_actions.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/product_model.dart';
import 'home_product_card_metrics.dart';

/// كارت منتج بحجم ثابت — مطابق لأبعاد التصميم
class HomeProductCard extends ConsumerStatefulWidget {
  const HomeProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  @override
  ConsumerState<HomeProductCard> createState() => _HomeProductCardState();
}

class _HomeProductCardState extends ConsumerState<HomeProductCard> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isFavorite = ref.watch(isProductFavoriteProvider(product.id));

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: HomeProductCardMetrics.width(),
        height: HomeProductCardMetrics.height(),
        child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(HomeProductCardMetrics.radius()),
          boxShadow: [
            BoxShadow(
              color: HomeProductCardMetrics.shadowColor.withValues(alpha: 0.38),
              blurRadius: HomeProductCardMetrics.shadowBlur(),
              offset: Offset.zero,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(HomeProductCardMetrics.radius()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: HomeProductCardMetrics.imagePadding(),
                child: _HomeProductImageSection(
                  product: product,
                  isFavorite: isFavorite,
                  onFavoriteTap: () =>
                      toggleProductFavorite(ref, product),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: HomeProductCardMetrics.padding().left,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: HomeProductCardMetrics.imageToNameGap()),
                      Expanded(
                        child: _HomeProductInfoSection(product: product),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: HomeProductCardMetrics.descriptionToPriceGap()),
              Padding(
                padding: HomeProductCardMetrics.priceBarMargin(),
                child: _HomeProductPriceBar(
                  price: product.formattedPrice,
                  onAddToCart: widget.onAddToCart,
                ),
              ),
              SizedBox(height: HomeProductCardMetrics.padding().bottom),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _HomeProductImageSection extends StatelessWidget {
  const _HomeProductImageSection({
    required this.product,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final ProductModel product;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: HomeProductCardMetrics.imageHeight(),
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: product.imageBgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: -12.h,
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                _HomeProductImage(product: product),
              ],
            ),
          ),
          Positioned(
            top: 6.w,
            left: 6.w,
            child: GestureDetector(
              onTap: onFavoriteTap,
              child: Container(
                width: HomeProductCardMetrics.favoriteWidth(),
                height: HomeProductCardMetrics.favoriteHeight(),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(
                    HomeProductCardMetrics.favoriteRadius(),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: HomeProductCardMetrics.favoriteIconSize(),
                  color: HomeProductCardMetrics.favoriteHeartColor(),
                ),
              ),
            ),
          ),
          if (product.discountPercent != null)
            Positioned(
              top: 6.w,
              right: 6.w,
              child: Container(
                width: HomeProductCardMetrics.discountWidth(),
                height: HomeProductCardMetrics.discountHeight(),
                decoration: BoxDecoration(
                  color: HomeProductCardMetrics.discountBackground(),
                  borderRadius: BorderRadius.circular(
                    HomeProductCardMetrics.discountRadius(),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '-${product.discountPercent}%',
                  style: AppTextStyles.homeProductCardDiscount(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeProductImage extends StatelessWidget {
  const _HomeProductImage({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: product.imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }

    return Icon(
      Icons.spa_outlined,
      size: 64.sp,
      color: AppColors.primary.withValues(alpha: 0.35),
    );
  }
}

class _HomeProductInfoSection extends StatelessWidget {
  const _HomeProductInfoSection({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: AppTextStyles.homeProductCardName(),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.rating.toStringAsFixed(1),
                  style: AppTextStyles.homeProductRating(),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.star_rounded,
                  color: AppColors.homeRating,
                  size: 13.sp,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: HomeProductCardMetrics.nameToCategoryGap()),
        Text(
          product.categoryName,
          style: AppTextStyles.homeProductCardCategory(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: HomeProductCardMetrics.categoryToDescriptionGap()),
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: Text(
              product.description,
              style: AppTextStyles.homeProductCardDescription(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeProductPriceBar extends StatelessWidget {
  const _HomeProductPriceBar({
    required this.price,
    this.onAddToCart,
  });

  final String price;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeProductCardMetrics.priceBarHeight(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: HomeProductCardMetrics.priceBarBackground(),
                borderRadius: BorderRadius.circular(
                  HomeProductCardMetrics.priceBarRadius(),
                ),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    price,
                    style: AppTextStyles.homeProductCardPrice(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: ProductCardCartButton(onAddToCart: onAddToCart),
            ),
          ),
        ],
      ),
    );
  }
}
