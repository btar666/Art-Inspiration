import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'glass_shimmer_sweep.dart';

/// زر المفضلة الزجاجي — ضبابي مع لمعة متحركة
class GlassFavoriteButton extends StatelessWidget {
  const GlassFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    required this.width,
    required this.height,
    required this.iconSize,
    required this.borderRadius,
    this.iconColor,
  });

  final bool isFavorite;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double iconSize;
  final double borderRadius;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final heartColor = iconColor ?? AppColors.homeHeart;
    final tint = isFavorite
        ? const Color(0xFFFF6B8A)
        : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: tint.withValues(alpha: isFavorite ? 0.28 : 0.16),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: SizedBox(
              width: width,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 1.1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isFavorite
                        ? [
                            Colors.white.withValues(alpha: 0.45),
                            const Color(0xFFFFE0E8).withValues(alpha: 0.5),
                            const Color(0xFFFF6B8A).withValues(alpha: 0.22),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.42),
                            AppColors.primaryLight.withValues(alpha: 0.32),
                            AppColors.primary.withValues(alpha: 0.12),
                          ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(
                      child: GlassShimmerSweep(highlightAlpha: 0.38),
                    ),
                    Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? const Color(0xFFE85D6A)
                          : heartColor,
                      size: iconSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
