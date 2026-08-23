import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/skeleton/skeleton_image_placeholder.dart';
import '../../../../shared/widgets/glass_favorite_button.dart';
import '../../../../shared/widgets/product_out_of_stock_badge.dart';
import '../../../cart/presentation/widgets/cart_icon_button.dart';
import '../../../favorites/presentation/favorites_actions.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/product_model.dart';
import '../providers/user_price_policy_provider.dart';
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
    final priceLabel =
        product.formattedPriceFor(ref.watch(userPricePolicyProvider));

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: HomeProductCardMetrics.width(),
          height: HomeProductCardMetrics.height(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(HomeProductCardMetrics.radius()),
              boxShadow: [
                BoxShadow(
                  color: HomeProductCardMetrics.shadowColor
                      .withValues(alpha: 0.22),
                  blurRadius: HomeProductCardMetrics.shadowBlur(),
                  offset: Offset.zero,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(HomeProductCardMetrics.radius()),
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
                          SizedBox(
                            height: HomeProductCardMetrics.imageToNameGap(),
                          ),
                          Expanded(
                            child: _HomeProductInfoSection(product: product),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: HomeProductCardMetrics.descriptionToPriceGap(),
                  ),
                  Padding(
                    padding: HomeProductCardMetrics.priceBarMargin(),
                    child: _HomeProductPriceBar(
                      price: priceLabel,
                      isOutOfStock: !product.isInStock,
                      onAddToCart: widget.onAddToCart,
                    ),
                  ),
                  SizedBox(height: HomeProductCardMetrics.padding().bottom),
                ],
              ),
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
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox.expand(
              child: _HomeProductImage(product: product),
            ),
          ),
          Positioned(
            top: 6.w,
            left: 6.w,
            child: GlassFavoriteButton(
              isFavorite: isFavorite,
              onTap: onFavoriteTap,
              width: HomeProductCardMetrics.favoriteWidth(),
              height: HomeProductCardMetrics.favoriteHeight(),
              iconSize: HomeProductCardMetrics.favoriteIconSize(),
              borderRadius: HomeProductCardMetrics.favoriteRadius(),
              iconColor: HomeProductCardMetrics.favoriteHeartColor(),
            ),
          ),
          if (product.discountPercent != null &&
              product.discountPercent! > 0)
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
          if (!product.isInStock)
            Positioned(
              bottom: 6.w,
              right: 6.w,
              child: const ProductOutOfStockBadge(compact: true),
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
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final cacheW =
          (HomeProductCardMetrics.width() * dpr).round().clamp(1, 2048);
      final cacheH =
          (HomeProductCardMetrics.imageHeight() * dpr).round().clamp(1, 2048);

      return CachedNetworkImage(
        imageUrl: product.imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        memCacheWidth: cacheW,
        memCacheHeight: cacheH,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, __) => SkeletonImagePlaceholder(
          borderRadius: BorderRadius.circular(12.r),
          animated: false,
        ),
        errorWidget: (_, __, ___) => ColoredBox(
          color: product.imageBgColor,
          child: Center(
            child: Icon(
              Icons.spa_outlined,
              size: 64.sp,
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: product.imageBgColor,
      child: Center(
        child: Icon(
          Icons.spa_outlined,
          size: 64.sp,
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
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
        Text(
          product.name,
          style: AppTextStyles.homeProductCardName(),
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: HomeProductCardMetrics.nameToCategoryGap()),
        Text(
          product.brandName.isNotEmpty
              ? product.brandName
              : product.categoryName,
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
    required this.isOutOfStock,
    this.onAddToCart,
  });

  final String price;
  final bool isOutOfStock;
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    HomeProductCardMetrics.priceBarLeftRadius(),
                  ),
                  bottomLeft: Radius.circular(
                    HomeProductCardMetrics.priceBarLeftRadius(),
                  ),
                  topRight: Radius.circular(
                    HomeProductCardMetrics.priceBarRadius(),
                  ),
                  bottomRight: Radius.circular(
                    HomeProductCardMetrics.priceBarRadius(),
                  ),
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
              child: Opacity(
                opacity: isOutOfStock ? 0.45 : 1,
                child: ProductCardCartButton(onAddToCart: onAddToCart),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
