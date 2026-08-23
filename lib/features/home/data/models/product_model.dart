import 'package:flutter/material.dart';

import '../../../../core/network/models/erp_price_policy.dart';

/// نموذج المنتج — يُستخدم في الصفحة الرئيسية وباقي الصفحات
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.description,
    required int price,
    int? priceRetail,
    this.priceHalfWholesale = 0,
    this.priceWholesale = 0,
    required this.rating,
    this.discountPercent,
    this.imageUrl,
    this.imageBgColor = const Color(0xFFE9E4F5),
    this.brandName = '',
    this.expiryDate = '',
    this.origin = '',
    this.galleryImageUrls = const [],
    this.categoryIds = const [],
    this.stockQuantity,
    this.trackStock = true,
    this.sku,
    this.barcode,
    this.isActive = true,
  })  : price = price,
        priceRetail = priceRetail ?? price;

  final String id;
  final String name;
  final String categoryName;
  final String description;
  /// سعر الوحدة المحلّ — يُستخدم في السلة والفاتورة
  final int price;
  /// سعر المفرق من أمان ERP
  final int priceRetail;
  /// سعر نصف الجملة من أمان ERP
  final int priceHalfWholesale;
  /// سعر الجملة من أمان ERP
  final int priceWholesale;
  final double rating;
  final int? discountPercent;
  final String? imageUrl;
  final Color imageBgColor;
  final String brandName;
  final String expiryDate;
  final String origin;
  final List<String> galleryImageUrls;
  final List<String> categoryIds;
  /// الكمية المتوفرة في المخزن — null إذا غير معروفة
  final int? stockQuantity;
  /// تتبع المخزون — إن false لا يُخفى المنتج حتى لو الكمية 0
  final bool trackStock;
  final String? sku;
  final String? barcode;
  final bool isActive;

  /// متوفر للبيع — نافذ إذا trackStock وكمية ≤ 0
  bool get isInStock {
    if (!trackStock) return true;
    if (stockQuantity == null) return true;
    return stockQuantity! > 0;
  }

  /// أقصى كمية يمكن طلبها — null إذا لا يوجد حد معروف
  int? get maxOrderQuantity {
    if (!trackStock) return null;
    return stockQuantity;
  }

  bool matchesCategoryOrBrand(String selected) {
    if (selected == 'الكل') return true;
    if (categoryName == selected || brandName == selected) return true;
    return categoryIds.contains(selected);
  }

  /// السعر حسب سياسة العميل في أمان ERP
  int priceFor(ErpPricePolicy policy) {
    return switch (policy) {
      ErpPricePolicy.retail => priceRetail,
      ErpPricePolicy.halfWholesale =>
        priceHalfWholesale > 0 ? priceHalfWholesale : priceRetail,
      ErpPricePolicy.wholesale =>
        priceWholesale > 0 ? priceWholesale : priceRetail,
    };
  }

  String formattedPriceFor(ErpPricePolicy policy) =>
      _formatIraqiPrice(priceFor(policy));

  /// نسخة بسعر وحدة محدد — للسلة والطلب
  ProductModel withUnitPrice(int unitPrice) => ProductModel(
        id: id,
        name: name,
        categoryName: categoryName,
        description: description,
        price: unitPrice,
        priceRetail: priceRetail,
        priceHalfWholesale: priceHalfWholesale,
        priceWholesale: priceWholesale,
        rating: rating,
        discountPercent: discountPercent,
        imageUrl: imageUrl,
        imageBgColor: imageBgColor,
        brandName: brandName,
        expiryDate: expiryDate,
        origin: origin,
        galleryImageUrls: galleryImageUrls,
        categoryIds: categoryIds,
        stockQuantity: stockQuantity,
        trackStock: trackStock,
        sku: sku,
        barcode: barcode,
        isActive: isActive,
      );

  ProductModel withPriceFor(ErpPricePolicy policy) =>
      withUnitPrice(priceFor(policy));

  String get formattedPrice => _formatIraqiPrice(price);

  static String _formatIraqiPrice(int value) {
    final formatted = value.toString().replaceAllMapped(
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
        'priceRetail': priceRetail,
        'priceHalfWholesale': priceHalfWholesale,
        'priceWholesale': priceWholesale,
        'rating': rating,
        'discountPercent': discountPercent,
        'imageUrl': imageUrl,
        'imageBgColor': imageBgColor.toARGB32(),
        'brandName': brandName,
        'expiryDate': expiryDate,
        'origin': origin,
        'galleryImageUrls': galleryImageUrls,
        'categoryIds': categoryIds,
        'stockQuantity': stockQuantity,
        'trackStock': trackStock,
        'sku': sku,
        'barcode': barcode,
        'isActive': isActive,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final retail = json['priceRetail'] as int? ?? json['price'] as int? ?? 0;
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryName: json['categoryName'] as String,
      description: json['description'] as String,
      price: json['price'] as int? ?? retail,
      priceRetail: retail,
      priceHalfWholesale: json['priceHalfWholesale'] as int? ?? 0,
      priceWholesale: json['priceWholesale'] as int? ?? 0,
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
      stockQuantity: json['stockQuantity'] as int?,
      trackStock: json['trackStock'] as bool? ?? true,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
