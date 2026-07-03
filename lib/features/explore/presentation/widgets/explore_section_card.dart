import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/explore_models.dart';

/// كارد قسم في تبويب الاقسام
class ExploreSectionCard extends StatelessWidget {
  const ExploreSectionCard({
    super.key,
    required this.section,
    this.onTap,
  });

  final ExploreSectionModel section;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.orderCardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: section.bgColor,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                alignment: Alignment.center,
                child: Image.asset(
                  section.iconAsset,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(6.w, 8.h, 6.w, 12.h),
              child: Text(
                section.name,
                style: AppTextStyles.exploreSectionLabel(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
