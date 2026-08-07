import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_field_error_hint.dart';
import 'app_selection_sheet.dart';

/// حقل اختيار من قائمة — يفتح ورقة سفلية احترافية بدل القائمة الافتراضية
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.icon = Icons.map_outlined,
    this.validator,
    this.labelBuilder,
  });

  final String hint;
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final String? Function(T?)? validator;
  final String Function(T item)? labelBuilder;

  String _label(T item) => labelBuilder?.call(item) ?? item.toString();

  Future<void> _openPicker(BuildContext context, FormFieldState<T> field) async {
    final selected = await AppSelectionSheet.show<T>(
      context: context,
      title: hint,
      items: items,
      selected: value ?? field.value,
      labelBuilder: labelBuilder,
      itemIcon: icon,
    );

    if (selected == null) return;

    field.didChange(selected);
    onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        final displayValue = value ?? field.value;
        final hasError = field.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openPicker(context, field),
                borderRadius: BorderRadius.circular(28.r),
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                    prefixIcon: Icon(
                      icon,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 26.sp,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28.r),
                      borderSide: BorderSide(
                        color: hasError
                            ? AppColors.fieldError
                            : AppColors.dotGrid,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28.r),
                      borderSide: BorderSide(
                        color: hasError
                            ? AppColors.fieldError
                            : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28.r),
                      borderSide: const BorderSide(
                        color: AppColors.fieldError,
                        width: 1.2,
                      ),
                    ),
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      displayValue != null ? _label(displayValue) : hint,
                      style: AppTextStyles.authField(
                        color: displayValue != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            if (hasError && field.errorText != null)
              AppFieldErrorHint(message: field.errorText!),
          ],
        );
      },
    );
  }
}
