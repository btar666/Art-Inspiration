import 'package:flutter/material.dart';

/// سلوك تمرير بدون ارتداد أو تمديد عند نهاية الصفحة
class AppScrollBehavior extends ScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
