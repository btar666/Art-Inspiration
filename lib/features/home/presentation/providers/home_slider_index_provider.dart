import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/home_mock_data.dart';
import '../../data/models/catalog_snapshot.dart';
import 'home_featured_sections_provider.dart';
import 'products_provider.dart';

/// شريحة السلايدر الظاهرة — للنقاط وتشغيل الفيديو فقط
final homeSliderPageIndexProvider = StateProvider<int>((ref) => 0);

/// عدّاد يزيد مع كل انتقال شريحة، مستقل عن رقم السلايد
final homeSearchHintCycleProvider = StateProvider<int>((ref) => 0);

List<String> _uniqueTerms(Iterable<String> names) {
  final seen = <String>{};
  final terms = <String>[];
  for (final raw in names) {
    final name = raw.trim();
    if (name.isEmpty || name == 'الكل' || !seen.add(name)) continue;
    terms.add(name);
  }
  return terms;
}

List<String> _hintTermsFor({
  CatalogSnapshot? catalog,
  Iterable<String> featuredNames = const [],
}) {
  final fromCatalog = _uniqueTerms([
    ...?catalog?.sectionNames,
    ...?catalog?.brands,
    ...featuredNames,
  ]);
  if (fromCatalog.length >= 2) return fromCatalog;
  return _uniqueTerms([
    ...fromCatalog,
    ...HomeMockData.categories,
  ]);
}

/// اسم يُعرض بجانب «بحث عن» ويتغيّر مع كل شريحة
final homeSearchHintTermProvider = Provider<String>((ref) {
  final cycle = ref.watch(homeSearchHintCycleProvider);
  final catalog = ref.watch(catalogProvider).valueOrNull;
  final featuredNames = ref
          .watch(homeFeaturedSectionsProvider)
          .valueOrNull
          ?.map((section) => section.name) ??
      const <String>[];
  final terms = _hintTermsFor(
    catalog: catalog,
    featuredNames: featuredNames,
  );

  if (terms.isEmpty) return 'منتج محدد';
  final safeCycle = cycle < 0 ? 0 : cycle;
  return terms[safeCycle % terms.length];
});
