import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// شريط بحث موحّد — باركود مدمج + نص + بحث
class UnifiedSearchBar extends StatelessWidget {
  const UnifiedSearchBar({
    super.key,
    required this.hintText,
    this.onScannerTap,
    this.onSearchTap,
    this.controller,
    this.onChanged,
    this.showScanner = true,
    this.height,
    this.blurred = false,
  });

  final String hintText;
  final VoidCallback? onScannerTap;
  final VoidCallback? onSearchTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool showScanner;
  final double? height;
  final bool blurred;

  bool get _isEditable => controller != null;

  @override
  Widget build(BuildContext context) {
    final barHeight = height ?? 50.h;
    final radius = BorderRadius.circular(28.r);
    final content = Row(
      children: [
        if (showScanner) SearchBarcodeButton(onTap: onScannerTap),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: showScanner ? 0 : 16.w),
            child: Transform.translate(
              offset: Offset(0, -2.h),
              child: Align(
              alignment: Alignment.centerRight,
              child: _isEditable
                  ? TextField(
                      controller: controller,
                      onChanged: onChanged,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.authField(),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: hintText,
                        hintStyle: AppTextStyles.authField(),
                        hintTextDirection: TextDirection.rtl,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Text(
                      hintText,
                      style: AppTextStyles.authField(),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Icon(
            Icons.search,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
        ),
      ],
    );

    final Widget bar;
    if (blurred) {
      bar = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: radius,
              ),
              child: content,
            ),
          ),
        ),
      );
    } else {
      bar = Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: radius,
          border: Border.all(color: AppColors.dotGrid, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: _isEditable
          ? bar
          : GestureDetector(
              onTap: onSearchTap,
              child: bar,
            ),
    );
  }
}

/// زر الباركود الزجاجي — ثلاث زوايا دائرية وزاوية حادة
class SearchBarcodeButton extends StatelessWidget {
  const SearchBarcodeButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: Radius.circular(28.r),
      bottomLeft: Radius.circular(28.r),
      bottomRight: Radius.circular(28.r),
      topRight: Radius.zero,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52.w,
        height: double.infinity,
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4D5DFF).withValues(alpha: 0.82),
                    AppColors.primary.withValues(alpha: 0.88),
                    const Color(0xFF000AA8).withValues(alpha: 0.92),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
