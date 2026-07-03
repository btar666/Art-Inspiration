import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

/// شبكة النقاط الزخرفية في الخلفية
class DecorativeDotGrid extends StatelessWidget {
  const DecorativeDotGrid({
    super.key,
    this.rows = 4,
    this.columns = 7,
    this.alignment = Alignment.topLeft,
    this.padding,
  });

  final int rows;
  final int columns;
  final Alignment alignment;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding ?? EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(rows, (row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(columns, (col) {
                return Container(
                  width: 5.w,
                  height: 5.w,
                  margin: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: AppColors.dotGrid,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
