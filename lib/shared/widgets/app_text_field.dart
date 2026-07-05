import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// حقل إدخال موحد لصفحات المصادقة
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.icon = Icons.person_outline,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.height,
    this.borderRadius,
  });

  final String hint;
  final TextEditingController? controller;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final double? height;
  final double? borderRadius;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final fieldHeight = widget.height;
    final verticalPadding = fieldHeight == null ? 18.h : 0.0;
    final radius = widget.borderRadius ?? 28.r;
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    final field = TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: AppTextStyles.authField(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.authField(),
        filled: true,
        fillColor: AppColors.background,
        isDense: fieldHeight != null,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 20.w, vertical: verticalPadding),
        prefixIcon: Icon(widget.icon, color: AppColors.textSecondary, size: 22.sp),
        suffixIcon: widget.suffix ??
            (widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                  )
                : null),
        enabledBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.dotGrid, width: 1.2),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );

    if (fieldHeight == null) return field;

    return SizedBox(
      height: fieldHeight,
      child: field,
    );
  }
}
