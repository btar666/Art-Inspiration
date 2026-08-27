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

/// صفحة بانتقال iOS القياسي مع إمكانية السحب من الحافتين للرجوع
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
      builder: (_) => _LeftEdgeBack(child: child),
    );
  }
}

/// رجوع بالسحب من الحافة اليسرى أيضاً
///
/// ‏`CupertinoPageRoute` يضع إيماءة الرجوع على حافة البداية، وهي في تطبيق
/// RTL الحافة **اليمنى**، بعرض 20 نقطة. هذا هو سلوك iOS الصحيح للعربية،
/// لكن كثيراً من الزبائن يسحبون من اليسار بحكم العادة فلا يحدث شيء.
///
/// هذه الطبقة تضيف الحافة اليسرى كذلك. لا تحرّك الصفحة مع الإصبع كإيماءة
/// النظام — تنفّذ `pop` عند انتهاء السحب — لكنها تفتح المخرج المتوقَّع.
/// ‏`translucent` تمرّر اللمس إلى ما تحتها، فلا تبتلع أزراراً.
class _LeftEdgeBack extends StatefulWidget {
  const _LeftEdgeBack({required this.child});

  final Widget child;

  @override
  State<_LeftEdgeBack> createState() => _LeftEdgeBackState();
}

class _LeftEdgeBackState extends State<_LeftEdgeBack> {
  /// نفس عرض شريط إيماءة النظام
  static const _edgeWidth = 20.0;

  /// سحبة مقصودة: مسافة كافية أو دفعة سريعة
  static const _minDistance = 60.0;
  static const _minVelocity = 300.0;

  var _dragged = 0.0;

  void _pop() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) => _dragged = 0,
            onHorizontalDragUpdate: (details) => _dragged += details.delta.dx,
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (_dragged >= _minDistance || velocity >= _minVelocity) {
                _pop();
              }
              _dragged = 0;
            },
          ),
        ),
      ],
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
