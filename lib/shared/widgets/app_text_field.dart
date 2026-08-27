import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_field_error_hint.dart';

/// حقل إدخال موحد لصفحات المصادقة
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.icon = Icons.person_outline,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.height,
    this.borderRadius,
    this.errorText,
    this.showErrorBorder = false,
    this.errorActionLabel,
    this.onErrorAction,
  });

  final String hint;
  final TextEditingController? controller;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final double? height;
  final double? borderRadius;
  final String? errorText;
  final bool showErrorBorder;
  final String? errorActionLabel;
  final VoidCallback? onErrorAction;

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
    final hasError = widget.showErrorBorder ||
        (widget.errorText != null && widget.errorText!.isNotEmpty);
    const errorSide = BorderSide(color: AppColors.fieldError, width: 1.2);
    const focusedErrorSide = BorderSide(color: AppColors.fieldError, width: 1.5);

    final field = TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
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
          borderSide: hasError ? errorSide : const BorderSide(color: AppColors.dotGrid, width: 1.2),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: hasError ? focusedErrorSide : const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: fieldBorder.copyWith(borderSide: errorSide),
        focusedErrorBorder: fieldBorder.copyWith(borderSide: focusedErrorSide),
        errorStyle: const TextStyle(height: 0, fontSize: 0),
      ),
    );

    final fieldWidget = fieldHeight == null
        ? field
        : SizedBox(height: fieldHeight, child: field);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        fieldWidget,
        if (hasError && widget.errorText != null && widget.errorText!.isNotEmpty)
          AppFieldErrorHint(
            message: widget.errorText!,
            actionLabel: widget.errorActionLabel,
            onAction: widget.onErrorAction,
          ),
      ],
    );
  }
}
