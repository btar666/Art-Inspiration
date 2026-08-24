import 'package:flutter/cupertino.dart';

/// مدة انتقال الصفحات — أسرع من الافتراضي (~400ms)
abstract final class AppPageTransition {
  static const Duration duration = Duration(milliseconds: 180);
  static const Duration reverseDuration = Duration(milliseconds: 160);
}

/// صفحة بانتقال سريع مع إمكانية السحب من الحافة للرجوع
class AppSwipePage<T> extends Page<T> {
  const AppSwipePage({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return _FastCupertinoPageRoute<T>(
      settings: this,
      builder: (_) => child,
    );
  }
}

class _FastCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  _FastCupertinoPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Duration get transitionDuration => AppPageTransition.duration;

  @override
  Duration get reverseTransitionDuration => AppPageTransition.reverseDuration;
}
