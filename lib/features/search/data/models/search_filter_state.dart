/// حالة فلترة نتائج البحث
class SearchFilterState {
  const SearchFilterState({
    this.minPrice = priceMin,
    this.maxPrice = priceMax,
    this.selectedBrand = 'الكل',
    this.selectedCategory = 'الكل',
  });

  final double minPrice;
  final double maxPrice;
  final String selectedBrand;
  final String selectedCategory;

  static const double priceMin = 0;
  static const double priceMax = 500000;

  bool get hasActiveFilters =>
      minPrice > priceMin ||
      maxPrice < priceMax ||
      selectedBrand != 'الكل' ||
      selectedCategory != 'الكل';

  String? get priceFilterLabel {
    if (minPrice <= priceMin && maxPrice >= priceMax) return null;
    return 'السعر ( ${_formatPrice(minPrice)} - ${_formatPrice(maxPrice)} )';
  }

  SearchFilterState copyWith({
    double? minPrice,
    double? maxPrice,
    String? selectedBrand,
    String? selectedCategory,
  }) {
    return SearchFilterState(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  static String _formatPrice(double value) {
    return value.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
