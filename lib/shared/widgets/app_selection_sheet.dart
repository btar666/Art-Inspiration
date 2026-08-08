import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// ورقة سفلية لاختيار عنصر من قائمة — مع بحث وتصميم موحّد
class AppSelectionSheet<T> extends StatefulWidget {
  const AppSelectionSheet({
    super.key,
    required this.title,
    required this.items,
    this.selected,
    this.labelBuilder,
    this.itemIcon = Icons.location_on_outlined,
  });

  final String title;
  final List<T> items;
  final T? selected;
  final String Function(T item)? labelBuilder;
  final IconData itemIcon;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    T? selected,
    String Function(T item)? labelBuilder,
    IconData itemIcon = Icons.location_on_outlined,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => AppSelectionSheet<T>(
        title: title,
        items: items,
        selected: selected,
        labelBuilder: labelBuilder,
        itemIcon: itemIcon,
      ),
    );
  }

  @override
  State<AppSelectionSheet<T>> createState() => _AppSelectionSheetState<T>();
}

class _AppSelectionSheetState<T> extends State<AppSelectionSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  String _label(T item) =>
      widget.labelBuilder?.call(item) ?? item.toString();

  List<T> get _filteredItems {
    final query = _query.trim();
    if (query.isEmpty) return widget.items;
    return widget.items
        .where((item) => _label(item).contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;
    final items = _filteredItems;

    return Padding(
      padding: EdgeInsets.only(top: 48.h),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.dotGrid,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
                child: Text(
                  widget.title,
                  style: AppTextStyles.authField(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 17.sp),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.authField(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'ابحث...',
                    hintStyle: AppTextStyles.authField(),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Flexible(
                child: items.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.h),
                        child: Text(
                          'لا توجد نتائج',
                          style: AppTextStyles.authField(),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          20.w,
                          0,
                          20.w,
                          16.h + bottomInset,
                        ),
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = item == widget.selected;
                          return _SelectionTile(
                            label: _label(item),
                            icon: widget.itemIcon,
                            isSelected: isSelected,
                            onTap: () => Navigator.of(context).pop(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? AppColors.primarySoft : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(
              children: [
                if (isSelected)
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.textOnPrimary,
                      size: 16.sp,
                    ),
                  )
                else
                  SizedBox(width: 24.w),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.authField(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ).copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 10.w),
                Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
