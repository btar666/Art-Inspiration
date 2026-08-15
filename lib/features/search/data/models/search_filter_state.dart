/// حالة فلترة نتائج البحث — مطابقة لفلاتر `/products` في أمان ERP
class SearchFilterState {
  const SearchFilterState({
    this.selectedBrand = 'الكل',
    this.selectedCategory = 'الكل',
    this.onlyActive = false,
  });

  final String selectedBrand;
  final String selectedCategory;
  final bool onlyActive;

  bool get hasActiveFilters =>
      selectedBrand != 'الكل' || selectedCategory != 'الكل';

  List<String> get activeFilterLabels {
    final labels = <String>[];
    if (selectedCategory != 'الكل') {
      labels.add('قسم: $selectedCategory');
    }
    if (selectedBrand != 'الكل') {
      labels.add('براند: $selectedBrand');
    }
    return labels;
  }

  SearchFilterState copyWith({
    String? selectedBrand,
    String? selectedCategory,
    bool? onlyActive,
  }) {
    return SearchFilterState(
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      onlyActive: onlyActive ?? this.onlyActive,
    );
  }

  static const cleared = SearchFilterState();
}
