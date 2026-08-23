import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/home_featured_sections_repository.dart';
import '../../data/models/home_featured_section.dart';

/// أقسام وبراندات مميزة مع منتجاتها — للعرض في الرئيسية
final homeFeaturedSectionsProvider =
    FutureProvider<List<HomeFeaturedSection>>((ref) async {
  return ref.watch(homeFeaturedSectionsRepositoryProvider).fetchSections();
});
