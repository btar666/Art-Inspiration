import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// سحب للتحديث — لون موحّد مع التطبيق
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.edgeOffset = 0,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  /// كم ينزل المؤشر عن أعلى الشاشة. الصفحات التي ترسم هيدراً عائماً فوق
  /// قائمتها (الرئيسية) تمرّر ارتفاع الهيدر، وإلا ظهر المؤشر خلف شريط البحث.
  final double edgeOffset;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      edgeOffset: edgeOffset,
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
    this.edgeOffset = 0,
  });

  final Future<void> Function() onRefresh;
  final List<Widget> slivers;
  final ScrollController? controller;

  /// انظر [AppRefreshIndicator.edgeOffset]
  final double edgeOffset;

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: onRefresh,
      edgeOffset: edgeOffset,
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        cacheExtent: 480,
        slivers: slivers,
      ),
    );
  }
}
