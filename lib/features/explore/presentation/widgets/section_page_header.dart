import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// رأس صفحة القسم — زر رجوع + عنوان
class SectionPageHeader extends StatelessWidget {
  const SectionPageHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          _BackButton(onTap: onBack),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.ordersPageTitle(),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.background,
          size: 24.sp,
        ),
      ),
    );
  }
}
