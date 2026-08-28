import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// شريط بحث موحّد — باركود مدمج + نص + بحث
class UnifiedSearchBar extends StatelessWidget {
  const UnifiedSearchBar({
    super.key,
    this.hintText = '',
    this.hintChild,
    this.onScannerTap,
    this.onSearchTap,
    this.controller,
    this.onChanged,
    this.showScanner = true,
    this.height,
    this.blurred = false,
    this.showBorder = true,
    this.dense = false,
    this.searchIconAsset,
    this.fontSize,
    this.textOffsetY,
  });

  final String hintText;
  final Widget? hintChild;
  final VoidCallback? onScannerTap;
  final VoidCallback? onSearchTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool showScanner;
  final double? height;
  final bool blurred;
  final bool showBorder;
  final bool dense;
  final String? searchIconAsset;
  final double? fontSize;
  final double? textOffsetY;

  bool get _isEditable => controller != null;

  @override
  Widget build(BuildContext context) {
    final barHeight = height ?? (dense ? 42.h : 50.h);
    final radius = BorderRadius.circular(dense ? 24.r : 28.r);
    final searchIconSize = dense ? 24.sp : 28.sp;
    final textStyle = AppTextStyles.authField().copyWith(
      fontSize: fontSize ?? (dense ? 13.5.sp : null),
    );
    final content = Row(
      children: [
        if (showScanner)
          SearchBarcodeButton(onTap: onScannerTap, dense: dense),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: showScanner ? 0 : (dense ? 12.w : 16.w)),
            child: Transform.translate(
              offset: Offset(0, textOffsetY ?? (dense ? -1.h : -2.h)),
              child: SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _isEditable
                      ? TextField(
                          controller: controller,
                          onChanged: onChanged,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: textStyle,
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: hintText,
                            hintStyle: textStyle,
                            hintTextDirection: TextDirection.rtl,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                      : (hintChild ??
                          Text(
                            hintText,
                            style: textStyle,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          )),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: dense ? 16.w : 14.w,
            right: dense ? 12.w : 16.w,
          ),
          child: searchIconAsset != null
              ? Image.asset(
                  searchIconAsset!,
                  width: searchIconSize,
                  height: searchIconSize,
                  fit: BoxFit.contain,
                )
              : Icon(
                  Icons.search,
                  color: AppColors.textPrimary,
                  size: searchIconSize,
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
          border: showBorder
              ? Border.all(color: AppColors.dotGrid, width: 1.2)
              : null,
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

/// زر الباركود — شكل مربع بزاوية أعلى يمين حادة وباقي الزوايا دائرية
class SearchBarcodeButton extends StatelessWidget {
  const SearchBarcodeButton({
    super.key,
    this.onTap,
    this.dense = false,
    this.width,
  });

  final VoidCallback? onTap;
  final bool dense;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = (width ?? (dense ? 42.w : 52.w)) + 4.w;
    final iconSize = dense ? 18.sp : 22.sp;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: Offset(-1.w, 0),
        child: SizedBox(
          width: buttonWidth,
          height: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final round = Radius.circular(constraints.maxHeight / 2);
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: round,
                    bottomLeft: round,
                    bottomRight: round,
                    topRight: Radius.zero,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
