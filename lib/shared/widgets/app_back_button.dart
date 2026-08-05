import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';

/// مقاييس زر الرجوع الموحّد — نفس أبعاد كونتينر المفضلة
abstract final class AppBackButtonMetrics {
  static double width() => 33.82.w;
  static double height() => 29.85.h;
}

/// زر الرجوع الدائري الموحّد في التطبيق
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    required this.onTap,
    this.width,
    this.height,
  });

  final VoidCallback onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        AppAssets.backIcon,
        width: width ?? AppBackButtonMetrics.width(),
        height: height ?? AppBackButtonMetrics.height(),
        fit: BoxFit.contain,
      ),
    );
  }
}
