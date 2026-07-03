import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import 'models/explore_models.dart';

/// بيانات تجريبية لصفحة الاكسبلور
abstract final class ExploreMockData {
  static const brands = [
    ExploreBrandModel(id: '1', name: 'Dior'),
    ExploreBrandModel(id: '2', name: 'Dior'),
    ExploreBrandModel(id: '3', name: 'Dior'),
    ExploreBrandModel(id: '4', name: 'Dior'),
    ExploreBrandModel(id: '5', name: 'Dior'),
    ExploreBrandModel(id: '6', name: 'Dior'),
    ExploreBrandModel(id: '7', name: 'Dior'),
    ExploreBrandModel(id: '8', name: 'Dior'),
    ExploreBrandModel(id: '9', name: 'Dior'),
    ExploreBrandModel(id: '10', name: 'Dior'),
    ExploreBrandModel(id: '11', name: 'Dior'),
    ExploreBrandModel(id: '12', name: 'Dior'),
  ];

  static const sections = [
    ExploreSectionModel(
      id: '1',
      name: 'المكياج',
      iconAsset: AppAssets.sectionMakeup,
      bgColor: Color(0xFFFFF0F5),
      filters: ['كل المنتجات', 'شفاه', 'عيون', 'بشرة'],
    ),
    ExploreSectionModel(
      id: '2',
      name: 'العطور',
      iconAsset: AppAssets.sectionPerfumes,
      bgColor: Color(0xFFF3EEFF),
      filters: ['كل المنتجات', 'رجالي', 'نسائي', 'عائلي'],
    ),
    ExploreSectionModel(
      id: '3',
      name: 'العناية بالبشرة',
      iconAsset: AppAssets.sectionSkincare,
      bgColor: Color(0xFFEEFAF7),
      filters: ['كل المنتجات', 'واقي', 'غسول', 'سيروم'],
    ),
    ExploreSectionModel(
      id: '4',
      name: 'العناية بالجسم',
      iconAsset: AppAssets.sectionBodyCare,
      bgColor: Color(0xFFEEF5FF),
      filters: ['كل المنتجات', 'لوشن', 'سكراب', 'كريم'],
    ),
    ExploreSectionModel(
      id: '5',
      name: 'مرطبات',
      iconAsset: AppAssets.sectionMoisturizers,
      bgColor: Color(0xFFE8F7FC),
      filters: ['كل المنتجات', 'وجه', 'جسم', 'يدين'],
    ),
    ExploreSectionModel(
      id: '6',
      name: 'صبغ الاظافر',
      iconAsset: AppAssets.sectionNailPolish,
      bgColor: Color(0xFFFFF0F6),
      filters: ['كل المنتجات', 'لامع', 'مطفي', 'جل'],
    ),
    ExploreSectionModel(
      id: '7',
      name: 'الرموش',
      iconAsset: AppAssets.sectionLashes,
      bgColor: Color(0xFFF0EEFF),
      filters: ['كل المنتجات', 'طبيعي', 'كثيف', 'طويل'],
    ),
    ExploreSectionModel(
      id: '8',
      name: 'العناية بالشعر',
      iconAsset: AppAssets.sectionHairCare,
      bgColor: Color(0xFFFFF6E8),
      filters: ['كل المنتجات', 'شامبو', 'بلسم', 'زيوت'],
    ),
    ExploreSectionModel(
      id: '9',
      name: 'اصباغ الشعر',
      iconAsset: AppAssets.sectionHairDyes,
      bgColor: Color(0xFFF8EEFF),
      filters: ['كل المنتجات', 'داكن', 'فاتح', 'أشقر'],
    ),
    ExploreSectionModel(
      id: '10',
      name: 'التخفيضات',
      iconAsset: AppAssets.sectionDiscounts,
      bgColor: Color(0xFFFFF0EE),
      filters: ['كل المنتجات', '50%', '30%', '20%'],
    ),
  ];

  static ExploreSectionModel sectionById(String id) {
    return sections.firstWhere((section) => section.id == id);
  }
}
