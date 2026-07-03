import 'package:flutter/material.dart';

/// نموذج المنتج — يُستخدم في الصفحة الرئيسية وباقي الصفحات
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.description,
    required this.price,
    required this.rating,
    this.discountPercent,
    this.imageUrl,
    this.imageBgColor = const Color(0xFFE9E4F5),
  });

  final String id;
  final String name;
  final String categoryName;
  final String description;
  final int price;
  final double rating;
  final int? discountPercent;
  final String? imageUrl;
  final Color imageBgColor;

  String get formattedPrice {
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$formatted د.ع';
  }
}
