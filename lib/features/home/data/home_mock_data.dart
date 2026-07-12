import 'package:flutter/material.dart';

import 'models/product_model.dart';

/// بيانات تجريبية للصفحة الرئيسية
abstract final class HomeMockData {
  static const categories = [
    'الكل',
    'المكياج',
    'العطور',
    'العناية بالبشرة',
    'العناية بالجسم',
    'مرطبات',
    'صبغ الاظافر',
    'الرموش',
    'العناية بالشعر',
    'اصباغ الشعر',
    'التخفيضات',
  ];

  static const _detailsDescription =
      'فرشاة أسنان كهربائية مزودة بتقنية تنظيف متقدمة، تنظف بعمق بين الأسنان '
      'وعلى طول خط اللثة. تعمل بالشحن وتوفر عدة أوضاع للتنظيف.';

  static const products = [
    ProductModel(
      id: '1',
      name: 'سيروم البشرة ART Inspiration',
      categoryName: 'أسم الفئة',
      description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
      price: 26000,
      rating: 4.8,
      discountPercent: 20,
      imageBgColor: Color(0xFFE9E4F5),
      expiryDate: '1 / 5 / 2026',
      origin: 'FRANC',
    ),
    ProductModel(
      id: '2',
      name: 'سيروم البشرة ART Inspiration',
      categoryName: 'أسم الفئة',
      description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
      price: 26000,
      rating: 3.9,
      discountPercent: 20,
      imageBgColor: Color(0xFFE4EAF8),
      expiryDate: '1 / 5 / 2026',
      origin: 'FRANC',
    ),
    ProductModel(
      id: '3',
      name: 'سيروم البشرة ART Inspiration',
      categoryName: 'أسم الفئة',
      description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
      price: 26000,
      rating: 4.5,
      discountPercent: 20,
      imageBgColor: Color(0xFFF0E8F2),
      expiryDate: '1 / 5 / 2026',
      origin: 'FRANC',
    ),
    ProductModel(
      id: '4',
      name: 'سيروم البشرة ART Inspiration',
      categoryName: 'أسم الفئة',
      description: 'وصف وصف وصف وصف وصف وصف وصف وصف',
      price: 26000,
      rating: 4.2,
      discountPercent: 20,
      imageBgColor: Color(0xFFE8EDF5),
      expiryDate: '1 / 5 / 2026',
      origin: 'FRANC',
    ),
  ];

  /// وصف تفصيلي للمنتج — يُعرض في صفحة التفاصيل
  static String detailsDescriptionFor(ProductModel product) =>
      _detailsDescription;
}
