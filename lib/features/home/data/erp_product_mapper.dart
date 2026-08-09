import 'package:flutter/material.dart';

import 'models/product_model.dart';

/// تحويل سجلات أمان ERP (/products) إلى ProductModel
abstract final class ErpProductMapper {
  static List<ProductModel> fromRecords(
    List<Map<String, dynamic>> records, {
    Map<int, String> categoryNames = const {},
    Map<int, String> brandNames = const {},
  }) {
    return records
        .map(
          (record) => fromRecord(
            record,
            categoryNames: categoryNames,
            brandNames: brandNames,
          ),
        )
        .whereType<ProductModel>()
        .toList();
  }

  static ProductModel? fromRecord(
    Map<String, dynamic> record, {
    Map<int, String> categoryNames = const {},
    Map<int, String> brandNames = const {},
  }) {
    final id = (record['id'] ?? '').toString();
    if (id.isEmpty) return null;

    final name = (record['name'] ?? '').toString().trim();
    if (name.isEmpty) return null;

    final categoryId = _asInt(record['category_id']);
    final brandId = _asInt(record['brand_id']);

    final categoryName = categoryId != null
        ? (categoryNames[categoryId] ?? 'قسم #$categoryId')
        : 'منتج';
    final brandName = brandId != null ? (brandNames[brandId] ?? '') : '';

    final price = _parsePrice(
      record['price_retail'] ??
          record['catalog_price'] ??
          record['price_wholesale'] ??
          record['price_half_wholesale'],
    );

    final description = (record['description'] ?? '').toString().trim();
    final image = record['image']?.toString().trim();
    final imageUrl =
        (image != null && image.isNotEmpty && image.startsWith('http'))
            ? image
            : null;

    final sku = record['sku']?.toString().trim();
    final barcode = record['barcode']?.toString().trim();
    final isActive = record['is_active'] != false;
    final trackStock = record['track_stock'] != false;
    final stockQuantity = _parseQuantity(
      record['quantity'] ?? record['stock_quantity'] ?? record['stock'],
    );

    final matchKeys = <String>{
      categoryName,
      if (categoryId != null) categoryId.toString(),
      if (brandName.isNotEmpty) brandName,
      if (brandId != null) brandId.toString(),
    };

    return ProductModel(
      id: id,
      name: name,
      categoryName: categoryName,
      description: description.isEmpty ? name : description,
      price: price,
      rating: 4.5,
      imageUrl: imageUrl,
      imageBgColor: _colorFromSeed(id),
      brandName: brandName,
      categoryIds: matchKeys.toList(),
      sku: sku != null && sku.isNotEmpty ? sku : null,
      barcode: barcode != null && barcode.isNotEmpty ? barcode : null,
      isActive: isActive,
      stockQuantity: stockQuantity,
      trackStock: trackStock,
    );
  }

  static int? _parseQuantity(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.floor();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      return parsed?.floor();
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int _parsePrice(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned)?.round() ?? 0;
    }
    return 0;
  }

  static Color _colorFromSeed(String seed) {
    const colors = [
      Color(0xFFE9E4F5),
      Color(0xFFE4EAF8),
      Color(0xFFF0E8F2),
      Color(0xFFE8EDF5),
    ];
    return colors[seed.hashCode.abs() % colors.length];
  }
}
