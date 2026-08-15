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

  /// تغويش أقوى من الأعلى — للاكسبلور فقط
  static const double exploreStrongBlurSigma = 44;
  static const double exploreMediumBlurSigma = 24;
  static const double exploreLightBlurSigma = 8;
  static const double exploreStrongBlurMaskEnd = 0.48;

  static const double defaultStrongBlurSigma = 30;
  static const double defaultMediumBlurSigma = 18;
  static const double defaultLightBlurSigma = 6;
  static const double defaultStrongBlurMaskEnd = 0.35;

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

/// خلفية التغويش المتدرج + التدرج اللوني — تُستخدم في الاكسبلور والرئيسية
class PinnedBlurGradientBackground extends StatelessWidget {
  const PinnedBlurGradientBackground({
    super.key,
    required this.fadeStops,
    this.fadeMaskColors,
    this.strongBlurSigma = PinnedBlurHeaderStyle.defaultStrongBlurSigma,
    this.mediumBlurSigma = PinnedBlurHeaderStyle.defaultMediumBlurSigma,
    this.lightBlurSigma = PinnedBlurHeaderStyle.defaultLightBlurSigma,
    this.strongBlurMaskEnd = PinnedBlurHeaderStyle.defaultStrongBlurMaskEnd,
  });

  final List<double> fadeStops;
  final List<Color>? fadeMaskColors;
  final double strongBlurSigma;
  final double mediumBlurSigma;
  final double lightBlurSigma;
  final double strongBlurMaskEnd;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) =>
          PinnedBlurHeaderStyle.fadeMaskShader(
        bounds,
        fadeStops,
        colors: fadeMaskColors,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _MaskedBlurLayer(
            sigma: strongBlurSigma,
            maskStops: [0.0, strongBlurMaskEnd, 1.0],
            maskColors: const [
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
          ),
          _MaskedBlurLayer(
            sigma: mediumBlurSigma,
            maskStops: const [0.0, 0.5, 1.0],
            maskColors: const [
              Colors.transparent,
              Colors.white,
              Colors.transparent,
            ],
          ),
          _MaskedBlurLayer(
            sigma: lightBlurSigma,
            maskStops: const [0.0, 0.75, 1.0],
            maskColors: const [
              Colors.transparent,
              Colors.white,
              Colors.white,
            ],
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

class _MaskedBlurLayer extends StatelessWidget {
  const _MaskedBlurLayer({
    required this.sigma,
    required this.maskStops,
    required this.maskColors,
  });

  final double sigma;
  final List<double> maskStops;
  final List<Color> maskColors;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: maskColors,
        stops: maskStops,
      ).createShader(bounds),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: const ColoredBox(color: Color(0x01FFFFFF)),
      ),
    );
  }
}
