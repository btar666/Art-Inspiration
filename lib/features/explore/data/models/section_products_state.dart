import '../../../home/data/models/product_model.dart';

/// حالة منتجات قسم أو براند مع التصفح
class SectionProductsState {
  const SectionProductsState({
    required this.sectionName,
    this.products = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.isLoadingMore = false,
  });

  final String sectionName;
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingMore;

  bool get hasMore => currentPage < lastPage;

  SectionProductsState copyWith({
    List<ProductModel>? products,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingMore,
  }) {
    return SectionProductsState(
      sectionName: sectionName,
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  static SectionProductsState fromResult(
    String sectionName,
    List<ProductModel> products, {
    required int currentPage,
    required int lastPage,
    required int total,
  }) {
    return SectionProductsState(
      sectionName: sectionName,
      products: products,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
    );
  }
}
