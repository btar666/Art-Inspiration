import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../../cart/presentation/cart_actions.dart';
import '../../../home/presentation/widgets/home_product_card.dart';
import '../../../home/presentation/widgets/home_product_card_metrics.dart';
import '../../../settings/presentation/widgets/settings_bottom_bar.dart';
import '../providers/favorites_provider.dart';

/// صفحة المفضلات
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesNotifierProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageBackHeader(
              title: 'المفضلات',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? const SettingsEmptyState(
                      title: 'لا توجد منتجات في المفضلة',
                      icon: Icons.favorite_border_rounded,
                    )
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        20.w,
                        0,
                        20.w,
                        24.h + bottomInset,
                      ),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14.h,
                        crossAxisSpacing: 14.w,
                        childAspectRatio: HomeProductCardMetrics.aspectRatio(),
                      ),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final product = favorites[index];
                        return HomeProductCard(
                          key: ValueKey(product.id),
                          product: product,
                          onTap: () =>
                              ProductDetailsWidget.open(context, product),
                          onAddToCart: () =>
                              addProductToCart(context, ref, product),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
