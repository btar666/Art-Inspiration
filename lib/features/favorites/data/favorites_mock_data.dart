import 'package:flutter/material.dart';

import '../../home/data/models/product_model.dart';

/// بيانات تجريبية لصفحة المفضلات
abstract final class FavoritesMockData {
  static List<ProductModel> initial() => const [
        ProductModel(
          id: 'fav-1',
          name: 'أسم المنتج',
          categoryName: 'أسم الفئة',
          description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
          price: 26000,
          rating: 4.8,
          discountPercent: 20,
          imageBgColor: Color(0xFFE9E4F5),
        ),
        ProductModel(
          id: 'fav-2',
          name: 'أسم المنتج',
          categoryName: 'أسم الفئة',
          description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
          price: 26000,
          rating: 3.9,
          imageBgColor: Color(0xFFE4EAF8),
        ),
        ProductModel(
          id: 'fav-3',
          name: 'أسم المنتج',
          categoryName: 'أسم الفئة',
          description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
          price: 26000,
          rating: 4.5,
          discountPercent: 20,
          imageBgColor: Color(0xFFF0E8F2),
        ),
        ProductModel(
          id: 'fav-4',
          name: 'أسم المنتج',
          categoryName: 'أسم الفئة',
          description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
          price: 26000,
          rating: 4.2,
          imageBgColor: Color(0xFFE8EDF5),
        ),
      ];
}
