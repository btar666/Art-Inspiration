import 'package:flutter/material.dart';

/// لمعان متحرك على الزجاج — يملك المتحكم الخاص به حتى لا يحدث LateError
class GlassShimmerSweep extends StatefulWidget {
  const GlassShimmerSweep({
    super.key,
    this.highlightAlpha = 0.18,
  });

  final double highlightAlpha;

  @override
  State<GlassShimmerSweep> createState() => _GlassShimmerSweepState();
}

class _GlassShimmerSweepState extends State<GlassShimmerSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              return Transform.translate(
                offset: Offset((t * 2.2 - 0.6) * width, 0),
                child: Transform.rotate(
                  angle: 0.4,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: width * 0.28,
                      height: height * 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(
                              alpha: widget.highlightAlpha,
                            ),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
