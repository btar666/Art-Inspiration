import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/models/product_model.dart';
import 'providers/favorites_provider.dart';

/// إضافة/إزالة منتج من المفضلة
void toggleProductFavorite(WidgetRef ref, ProductModel product) {
  ref.read(favoritesNotifierProvider.notifier).toggle(product);
}
