import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// تلميح خطأ أحمر أسفل حقل الإدخال
class AppFieldErrorHint extends StatelessWidget {
  const AppFieldErrorHint({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, right: 10.w, left: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 16.w,
            height: 16.w,
            decoration: const BoxDecoration(
              color: AppColors.fieldError,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 11.sp,
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              message.startsWith('!') ? message : '! $message',
              style: AppTextStyles.authField(color: AppColors.fieldError),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
