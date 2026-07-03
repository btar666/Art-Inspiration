import 'package:flutter/material.dart';

/// تبويبات صفحة الاكسبلور
enum ExploreTab {
  general('عام'),
  brands('براندات'),
  sections('اقسام');

  const ExploreTab(this.label);

  final String label;
}

/// نموذج البراند
class ExploreBrandModel {
  const ExploreBrandModel({
    required this.id,
    required this.name,
    this.logoAsset,
  });

  final String id;
  final String name;
  final String? logoAsset;
}

/// نموذج قسم الاكسبلور
class ExploreSectionModel {
  const ExploreSectionModel({
    required this.id,
    required this.name,
    required this.iconAsset,
    required this.bgColor,
    this.filters = const ['كل المنتجات'],
  });

  final String id;
  final String name;
  final String iconAsset;
  final Color bgColor;
  final List<String> filters;
}
