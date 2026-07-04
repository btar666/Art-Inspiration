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
    this.expiryDate = '',
    this.origin = '',
    this.galleryImageUrls = const [],
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
  final String expiryDate;
  final String origin;
  final List<String> galleryImageUrls;

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
        'expiryDate': expiryDate,
        'origin': origin,
        'galleryImageUrls': galleryImageUrls,
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
        expiryDate: json['expiryDate'] as String? ?? '',
        origin: json['origin'] as String? ?? '',
        galleryImageUrls: (json['galleryImageUrls'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
}
