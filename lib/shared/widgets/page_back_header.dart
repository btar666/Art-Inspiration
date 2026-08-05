import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_text_styles.dart';
import 'app_back_button.dart';

/// رأس صفحة فرعية — زر رجوع يسار + عنوان وسط
class PageBackHeader extends StatelessWidget {
  const PageBackHeader({
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
          AppBackButton(onTap: onBack),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.ordersPageTitle(),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: AppBackButtonMetrics.width()),
        ],
      ),
    );
  }
}
