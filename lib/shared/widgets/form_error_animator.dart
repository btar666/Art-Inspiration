import 'package:flutter/material.dart';

import 'shake_animation.dart';

/// يلفّ المحتوى ويشغّل أنيميشن اهتزاز + تكبير/تصغير عند خطأ التحقق
class FormErrorAnimator extends StatelessWidget {
  const FormErrorAnimator({
    super.key,
    required this.tick,
    required this.child,
  });

  /// يزداد عند كل فشل في التحقق لإعادة تشغيل الأنيميشن
  final int tick;
  final Widget child;

  @override
  Widget build(BuildContext context) => child.shakeOnTick(tick);
}
