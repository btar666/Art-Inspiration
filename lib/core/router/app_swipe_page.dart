import 'package:flutter/cupertino.dart';

/// مدة تلاشي تبويبات الشريط السفلي
///
/// للتبويبات فقط. تبديل تبويب حركة فورية في iOS، فالسرعة هنا صحيحة.
/// أما دفع صفحة (منتج، إعدادات، سلة) فيتركها لـ `CupertinoPageRoute`
/// بمدتها الأصلية — انظر `_FastCupertinoPageRoute`.
abstract final class AppPageTransition {
  static const Duration duration = Duration(milliseconds: 180);
  static const Duration reverseDuration = Duration(milliseconds: 160);
}

/// صفحة بانتقال iOS القياسي مع إمكانية السحب من الحافة للرجوع
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

/// ‏🚩 لا تُعِد تقصير المدة هنا.
///
/// كانت الصفحة تُدفع في 180ms وترجع في 160ms، أي أقل من ثلث مدة
/// `CupertinoPageRoute` الأصلية (500ms). انزلاق الصفحة، وحركة الصفحة
/// السابقة خلفها، والظل على حافتها، كلها تُضغط في تلك الفترة فتبدو نطّة
/// لا انتقالاً. المدة الافتراضية هي سلوك iOS القياسي، فنتركها.
///
/// التلاشي السريع للتبويبات شيء آخر ولم يتغيّر.
class _FastCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  _FastCupertinoPageRoute({
    required super.builder,
    super.settings,
  });
}
