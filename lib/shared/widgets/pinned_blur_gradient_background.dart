import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// إعدادات التدرج والتلاشي المشتركة لرؤوس الصفحات الثابتة
abstract final class PinnedBlurHeaderStyle {
  static List<Color> gradientColors() => [
        AppColors.primarySoft.withValues(alpha: 0.92),
        AppColors.primarySoft.withValues(alpha: 0.72),
        AppColors.primaryLight.withValues(alpha: 0.28),
        AppColors.background.withValues(alpha: 0.04),
      ];

  static const List<double> gradientStops = [0.0, 0.35, 0.70, 1.0];

  static const List<double> exploreFadeStops = [0.0, 0.55, 0.85, 1.0];

  static const List<double> homeFadeStops = [0.0, 0.40, 0.75, 1.0];

  /// تلاشي أخف من الأسفل — للهيدر المثبت بعد السكرول
  static const List<double> compactFadeStops = [0.0, 0.50, 0.82, 1.0];

  static const List<Color> defaultFadeMaskColors = [
        Color(0xFFFFFFFF),
        Color(0xFFFFFFFF),
        Color(0xAAFFFFFF),
        Color(0x00FFFFFF),
      ];

  static const List<Color> compactFadeMaskColors = [
        Color(0xFFFFFFFF),
        Color(0xFFFFFFFF),
        Color(0xE6FFFFFF),
        Color(0x88FFFFFF),
      ];

  /// تغويش الهيدر — قيمة واحدة، انظر التعليق في [PinnedBlurGradientBackground]
  static const double defaultBlurSigma = 28;

  static Shader fadeMaskShader(
    Rect bounds,
    List<double> stops, {
    List<Color>? colors,
  }) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors ?? defaultFadeMaskColors,
      stops: stops,
    ).createShader(bounds);
  }
}

/// خلفية التغويش + التدرج اللوني — تُستخدم في الاكسبلور والرئيسية
///
/// طبقة تغويش واحدة، لا ثلاث. النسخة الأولى كدّست ثلاثة [BackdropFilter]
/// (سيغما 44 و24 و8) كل واحد داخل [ShaderMask] خاص به، لتقليد «تغويش متدرج».
/// هذا يعني ٣ عمليات blur + ٤ طبقات saveLayer لكل هيدر، في كل إطار، والرئيسية
/// تعرض هيدرين معاً أثناء الانتقال. والطبقة الأقوى كانت مقنّعة عند أعلى الهيدر
/// — أي تحت التدرج المعتم بنسبة 92%، حيث لا تكاد تُرى.
///
/// [BackdropFilter] لا يمكن تخزينه مؤقتاً: يقرأ ما خلفه، والذي يتغيّر مع كل
/// إطار أثناء السكرول. فالحل الوحيد هو تقليل عددها.
class PinnedBlurGradientBackground extends StatelessWidget {
  const PinnedBlurGradientBackground({
    super.key,
    required this.fadeStops,
    this.fadeMaskColors,
    this.blurSigma = PinnedBlurHeaderStyle.defaultBlurSigma,
  });

  final List<double> fadeStops;
  final List<Color>? fadeMaskColors;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => PinnedBlurHeaderStyle.fadeMaskShader(
        bounds,
        fadeStops,
        colors: fadeMaskColors,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // سيغما صفر = بلا تغويش إطلاقاً، لا [BackdropFilter] أصلاً
          if (blurSigma > 0)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: const ColoredBox(color: Color(0x01FFFFFF)),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: PinnedBlurHeaderStyle.gradientColors(),
                stops: PinnedBlurHeaderStyle.gradientStops,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
