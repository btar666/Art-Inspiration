import 'package:flutter/material.dart';

import 'models/product_model.dart';

/// بيانات تجريبية للصفحة الرئيسية
abstract final class HomeMockData {
  static const categories = [
    'الكل',
    'حشوات',
    'حشوات',
    'حشوات',
    'حشوات',
    'حشوات',
  ];

  static const products = [
    ProductModel(
      id: '1',
      name: 'أسم المنتج',
      categoryName: 'أسم الفئة',
      description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
      price: 26000,
      rating: 4.8,
      discountPercent: 20,
      imageBgColor: Color(0xFFE9E4F5),
    ),
    ProductModel(
      id: '2',
      name: 'أسم المنتج',
      categoryName: 'أسم الفئة',
      description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
      price: 26000,
      rating: 3.9,
      discountPercent: 20,
      imageBgColor: Color(0xFFE4EAF8),
    ),
    ProductModel(
      id: '3',
      name: 'أسم المنتج',
      categoryName: 'أسم الفئة',
      description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
      price: 26000,
      rating: 4.5,
      discountPercent: 20,
      imageBgColor: Color(0xFFF0E8F2),
    ),
    ProductModel(
      id: '4',
      name: 'أسم المنتج',
      categoryName: 'أسم الفئة',
      description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
      price: 26000,
      rating: 4.2,
      discountPercent: 20,
      imageBgColor: Color(0xFFE8EDF5),
    ),
  ];
}
