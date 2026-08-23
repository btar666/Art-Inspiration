import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_api/data/app_api_service.dart';
import 'models/home_featured_section.dart';
import 'products_repository.dart';

final homeFeaturedSectionsRepositoryProvider =
    Provider<HomeFeaturedSectionsRepository>((ref) {
  return HomeFeaturedSectionsRepository(
    appApi: ref.watch(appApiServiceProvider),
    productsRepository: ref.watch(productsRepositoryProvider),
  );
});

/// يجمع الأقسام/البراندات المميزة من art-inspiration.com مع منتجاتها من ERP
class HomeFeaturedSectionsRepository {
  HomeFeaturedSectionsRepository({
    required AppApiService appApi,
    required ProductsRepository productsRepository,
  })  : _appApi = appApi,
        _productsRepository = productsRepository;

  final AppApiService _appApi;
  final ProductsRepository _productsRepository;

  Future<List<HomeFeaturedSection>> fetchSections() async {
    final results = await Future.wait([
      _fetchCategorySections(),
      _fetchBrandSections(),
    ]);

    return [
      ...results[0],
      ...results[1],
    ];
  }

  Future<List<HomeFeaturedSection>> _fetchCategorySections() async {
    try {
      final ids = await _appApi.fetchFeaturedCategoryIds();
      if (ids.isEmpty) return const [];

      final sections = await Future.wait(
        ids.map(_productsRepository.fetchFeaturedCategorySection),
      );

      return sections.whereType<HomeFeaturedSection>().toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<HomeFeaturedSection>> _fetchBrandSections() async {
    try {
      final ids = await _appApi.fetchFeaturedBrandIds();
      if (ids.isEmpty) return const [];

      final sections = await Future.wait(
        ids.map(_productsRepository.fetchFeaturedBrandSection),
      );

      return sections.whereType<HomeFeaturedSection>().toList();
    } catch (_) {
      return const [];
    }
  }
}
