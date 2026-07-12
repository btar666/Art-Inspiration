import 'package:flutter/material.dart';

import '../../../core/network/api_response_parser.dart';
import '../../../core/network/erp_media_url.dart';
import 'erp_product_fields.dart';
import 'models/product_model.dart';

/// تحويل سجلات ERP إلى ProductModel
abstract final class ErpProductMapper {
  static List<ProductModel> fromRecords(List<Map<String, dynamic>> records) {
    return records.map(fromRecord).whereType<ProductModel>().toList();
  }

  static ProductModel? fromRecord(Map<String, dynamic> record) {
    final main = ApiResponseParser.decodeJsonField(record['main']) ?? {};

    final id = (record['id'] ?? record['elementNumber'] ?? '').toString();
    if (id.isEmpty) return null;

    final name = _firstNonEmpty([
      main['name'],
      main['productName'],
      main['title'],
      record['name'],
      record['elementNumber'],
    ]);

    if (name.isEmpty) return null;

    final price = _parsePrice(
      main['sellingPrice'] ??
          main['salePrice'] ??
          main['price'] ??
          main['unitPrice'] ??
          main['totalAmount'] ??
          record['price'],
    );

    final brandName = ErpProductFields.brandValue(main);
    final category = ErpProductFields.primaryCategory(main);
    final categoryIds = ErpProductFields.categoryMatchKeys(main);

    final description = _firstNonEmpty([
      main['description'],
      main['notes'],
      main['details'],
      record['description'],
    ]);

    final imageUrl = ErpMediaUrl.resolve(record: record, main: main);

    final rating = _parseDouble(main['rating'] ?? record['rating'], fallback: 4.5);
    final discount = _parseInt(main['discountPercent'] ?? main['discount']);

    return ProductModel(
      id: id,
      name: name,
      categoryName: category.isEmpty ? 'منتج' : category,
      description: description.isEmpty ? name : description,
      price: price,
      rating: rating,
      discountPercent: discount,
      imageUrl: imageUrl,
      imageBgColor: _colorFromSeed(id),
      brandName: brandName,
      expiryDate: _firstNonEmpty([main['expiryDate'], main['expiry']]),
      origin: _firstNonEmpty([main['origin'], main['country']]),
      galleryImageUrls: _gallery(main, record),
      categoryIds: categoryIds,
    );
  }

  static List<String> _gallery(
    Map<String, dynamic> main,
    Map<String, dynamic> record,
  ) {
    final urls = <String>{};
    final raw = main['gallery'] ?? main['galleryImageUrls'] ?? main['images'];

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final url = ErpMediaUrl.resolve(
            record: record,
            main: Map<String, dynamic>.from(item),
          );
          if (url != null) urls.add(url);
        } else {
          final text = item?.toString().trim() ?? '';
          if (text.isEmpty) continue;
          final url = text.startsWith('http')
              ? text
              : ErpMediaUrl.resolve(
                  record: record,
                  main: {'imageName': text},
                );
          if (url != null) urls.add(url);
        }
      }
    }

    return urls.toList();
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
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

  static double _parseDouble(dynamic value, {required double fallback}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.replaceAll('%', ''));
    return null;
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

