import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// خلفية زجاجية بيضاء لرأس الاكسبلور — مثل iOS
class ExploreGlassHeaderBackground extends StatelessWidget {
  const ExploreGlassHeaderBackground({super.key});

  static const double topBlurSigma = 45;

  static double topBlurHeight() => 180.h;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
              Color(0x88FFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: [0.0, 0.38, 0.78, 1.0],
          ).createShader(bounds),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: topBlurHeight(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: topBlurSigma,
                      sigmaY: topBlurSigma,
                    ),
                    child: ColoredBox(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: topBlurHeight() * 0.9,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: const ColoredBox(color: Color(0x01FFFFFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.92),
                Colors.white.withValues(alpha: 0.78),
                Colors.white.withValues(alpha: 0.45),
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.25, 0.55, 0.8, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
