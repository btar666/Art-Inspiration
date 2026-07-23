import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/providers/products_provider.dart';
import '../../data/models/search_filter_state.dart';
import '../../data/search_mock_data.dart';

/// صفحة فلترة نتائج البحث
class SearchFilterPage extends ConsumerStatefulWidget {
  const SearchFilterPage({
    super.key,
    required this.initialFilter,
  });

  final SearchFilterState initialFilter;

  @override
  ConsumerState<SearchFilterPage> createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends ConsumerState<SearchFilterPage> {
  late RangeValues _priceRange;
  late String _selectedBrand;
  late String _selectedCategory;
  bool _brandsExpanded = true;
  bool _categoriesExpanded = true;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.initialFilter.minPrice,
      widget.initialFilter.maxPrice,
    );
    _selectedBrand = widget.initialFilter.selectedBrand;
    _selectedCategory = widget.initialFilter.selectedCategory;
  }

  SearchFilterState get _currentFilter => SearchFilterState(
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        selectedBrand: _selectedBrand,
        selectedCategory: _selectedCategory,
      );

  void _apply() => context.pop(_currentFilter);

  String _formatPrice(double value) {
    return value.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  List<String> _withAll(Iterable<String> values) {
    final unique = <String>{};
    for (final value in values) {
      final text = value.trim();
      if (text.isNotEmpty && text != 'الكل') unique.add(text);
    }
    return ['الكل', ...unique];
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final catalog = ref.watch(catalogProvider).value;
    final brandOptions = _withAll(
      catalog?.brands.isNotEmpty == true
          ? catalog!.brands
          : SearchMockData.brands,
    );
    final categoryOptions = _withAll(
      catalog?.categories.isNotEmpty == true
          ? catalog!.categories
          : SearchMockData.categories,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 0),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 24.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'فلترة نتائج البحث',
                      style: AppTextStyles.ordersPageTitle(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FilterSectionHeader(
                      title: 'حسب السعر',
                      expanded: true,
                      onToggle: null,
                    ),
                    SizedBox(height: 8.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.h,
                        rangeThumbShape: RoundRangeSliderThumbShape(
                          enabledThumbRadius: 10.r,
                        ),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 16.r),
                        activeTrackColor: AppColors.primarySoft,
                        inactiveTrackColor: const Color(0xFFF0E8DC),
                        thumbColor: AppColors.primary,
                      ),
                      child: RangeSlider(
                        values: _priceRange,
                        min: SearchFilterState.priceMin,
                        max: SearchFilterState.priceMax,
                        divisions: 26,
                        onChanged: (values) =>
                            setState(() => _priceRange = values),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_formatPrice(_priceRange.end)} د.ع',
                          style: AppTextStyles.searchFilterValue(),
                        ),
                        Text(
                          '${_formatPrice(_priceRange.start)} د.ع',
                          style: AppTextStyles.searchFilterValue(),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    _FilterSectionHeader(
                      title: 'حسب البراند',
                      expanded: _brandsExpanded,
                      onToggle: () =>
                          setState(() => _brandsExpanded = !_brandsExpanded),
                    ),
                    if (_brandsExpanded) ...[
                      SizedBox(height: 12.h),
                      _FilterChipGrid(
                        options: brandOptions,
                        selected: _selectedBrand,
                        onSelected: (value) =>
                            setState(() => _selectedBrand = value),
                      ),
                    ],
                    SizedBox(height: 24.h),
                    _FilterSectionHeader(
                      title: 'حسب القسم',
                      expanded: _categoriesExpanded,
                      onToggle: () => setState(
                        () => _categoriesExpanded = !_categoriesExpanded,
                      ),
                    ),
                    if (_categoriesExpanded) ...[
                      SizedBox(height: 12.h),
                      _FilterChipGrid(
                        options: categoryOptions,
                        selected: _selectedCategory,
                        onSelected: (value) =>
                            setState(() => _selectedCategory = value),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h + bottomInset),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.orderDetailsFooter,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(
                      child: Material(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(24.r),
                        child: InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(24.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            alignment: Alignment.center,
                            child: Text(
                              'عودة',
                              style: AppTextStyles.buttonPrimary(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 2,
                      child: Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24.r),
                        child: InkWell(
                          onTap: _apply,
                          borderRadius: BorderRadius.circular(24.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            alignment: Alignment.center,
                            child: Text(
                              'فلترة النتائج',
                              style: AppTextStyles.buttonPrimary(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSectionHeader extends StatelessWidget {
  const _FilterSectionHeader({
    required this.title,
    required this.expanded,
    required this.onToggle,
  });

  final String title;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onToggle != null)
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              expanded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_up_rounded,
              color: AppColors.textSecondary,
              size: 22.sp,
            ),
          ),
        const Spacer(),
        Text(title, style: AppTextStyles.searchSectionTitle()),
      ],
    );
  }
}

class _FilterChipGrid extends StatelessWidget {
  const _FilterChipGrid({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      alignment: WrapAlignment.end,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color:
                    isSelected ? AppColors.primary : AppColors.homeChipBorder,
                width: 1.2,
              ),
            ),
            child: Text(
              option,
              style: AppTextStyles.homeProductCategory(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
            ),
          ),
        );
      }).toList(),
    );
  }
}
