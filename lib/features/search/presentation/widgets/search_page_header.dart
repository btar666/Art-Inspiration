import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';

/// رأس صفحة البحث — إلغاء يسار + عنوان
class SearchPageHeader extends StatelessWidget {
  const SearchPageHeader({
    super.key,
    required this.onCancel,
    this.showCancel = false,
  });

  final VoidCallback onCancel;
  final bool showCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          if (showCancel)
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                minimumSize: Size(48.w, 36.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'الغاء',
                style: AppTextStyles.searchCancel(),
              ),
            )
          else
            SizedBox(width: 48.w),
          Expanded(
            child: Text(
              'البحث',
              style: AppTextStyles.ordersPageTitle(),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}
