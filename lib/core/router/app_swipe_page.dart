import 'package:flutter/cupertino.dart';

/// صفحة تدعم السحب من الحافة للرجوع خطوة للخلف (iOS و Android)
class AppSwipePage<T> extends CupertinoPage<T> {
  const AppSwipePage({
    required super.child,
    super.key,
  });
}
