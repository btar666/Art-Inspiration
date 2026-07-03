import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// قائمة منسدلة موحدة لصفحات المصادقة
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.icon = Icons.map_outlined,
    this.validator,
  });

  final String hint;
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: AppTextStyles.authField(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.authField(),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22.sp),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: const BorderSide(color: AppColors.dotGrid, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 26.sp),
      borderRadius: BorderRadius.circular(20.r),
      isExpanded: true,
    );
  }
}
