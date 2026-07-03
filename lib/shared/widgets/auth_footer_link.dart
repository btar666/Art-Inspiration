import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// رابط تذييل صفحات المصادقة
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prefix,
    required this.linkText,
    required this.onTap,
  });

  final String prefix;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text.rich(
        TextSpan(
          style: AppTextStyles.authSubtitle(color: AppColors.textPrimary),
          children: [
            TextSpan(text: '$prefix '),
            TextSpan(
              text: linkText,
              style: AppTextStyles.authLink(),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
