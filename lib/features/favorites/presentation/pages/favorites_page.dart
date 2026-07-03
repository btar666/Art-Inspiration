import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/page_back_header.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/widgets/home_product_card.dart';
import '../../../home/presentation/widgets/home_product_card_metrics.dart';
import '../../../settings/presentation/widgets/settings_bottom_bar.dart';
import '../../data/favorites_mock_data.dart';

/// صفحة المفضلات
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<ProductModel> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = List.of(FavoritesMockData.initial());
  }

  void _removeFavorite(String id) {
    setState(() => _favorites.removeWhere((p) => p.id == id));
  }

  @override
  Widget build(BuildContext context) {
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
              child: _favorites.isEmpty
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
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        final product = _favorites[index];
                        return HomeProductCard(
                          key: ValueKey(product.id),
                          product: product,
                          isFavorite: true,
                          onTap: () =>
                              ProductDetailsWidget.open(context, product),
                          onFavoriteTap: () => _removeFavorite(product.id),
                          onAddToCart: () {},
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
