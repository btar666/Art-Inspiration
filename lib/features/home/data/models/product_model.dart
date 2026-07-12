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
    this.brandName = '',
    this.expiryDate = '',
    this.origin = '',
    this.galleryImageUrls = const [],
    this.categoryIds = const [],
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
  final String brandName;
  final String expiryDate;
  final String origin;
  final List<String> galleryImageUrls;
  final List<String> categoryIds;

  bool matchesCategoryOrBrand(String selected) {
    if (selected == 'الكل') return true;
    if (categoryName == selected || brandName == selected) return true;
    return categoryIds.contains(selected);
  }

  String get formattedPrice {
    final formatted = price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$formatted د.ع';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'categoryName': categoryName,
        'description': description,
        'price': price,
        'rating': rating,
        'discountPercent': discountPercent,
        'imageUrl': imageUrl,
        'imageBgColor': imageBgColor.toARGB32(),
        'brandName': brandName,
        'expiryDate': expiryDate,
        'origin': origin,
        'galleryImageUrls': galleryImageUrls,
        'categoryIds': categoryIds,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        name: json['name'] as String,
        categoryName: json['categoryName'] as String,
        description: json['description'] as String,
        price: json['price'] as int,
        rating: (json['rating'] as num).toDouble(),
        discountPercent: json['discountPercent'] as int?,
        imageUrl: json['imageUrl'] as String?,
        imageBgColor: Color(json['imageBgColor'] as int? ?? 0xFFE9E4F5),
        brandName: json['brandName'] as String? ?? '',
        expiryDate: json['expiryDate'] as String? ?? '',
        origin: json['origin'] as String? ?? '',
        galleryImageUrls: (json['galleryImageUrls'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        categoryIds: (json['categoryIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}
