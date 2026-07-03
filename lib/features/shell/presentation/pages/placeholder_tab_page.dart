import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// صفحة مؤقتة للتبويبات قيد التطوير
class PlaceholderTabPage extends StatelessWidget {
  const PlaceholderTabPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.ordersPageTitle(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
