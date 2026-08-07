import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// سحب للتحديث — لون موحّد مع التطبيق
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

/// CustomScrollView مع سحب للتحديث وفيزياء تمرير تدعم المحتوى القصير
class AppRefreshScrollView extends StatelessWidget {
  const AppRefreshScrollView({
    super.key,
    required this.onRefresh,
    required this.slivers,
    this.controller,
  });

  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: slivers,
      ),
    );
  }
}
