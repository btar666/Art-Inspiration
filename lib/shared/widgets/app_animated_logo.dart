import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';
import 'shake_animation.dart';

/// شعار التطبيق — دوران عند الفتح + اهتزاز عند الضغط أو الخطأ
class AppAnimatedLogo extends StatefulWidget {
  const AppAnimatedLogo({
    super.key,
    this.size = 72,
    this.enableRotation = true,
    this.rotationDuration = const Duration(milliseconds: 900),
    this.enableEntrance = false,
    this.shakeOnTap = true,
    this.errorTick = 0,
    this.onRotationComplete,
  });

  final double size;
  final bool enableRotation;
  final Duration rotationDuration;
  final bool enableEntrance;
  final bool shakeOnTap;
  final int errorTick;
  final VoidCallback? onRotationComplete;

  @override
  State<AppAnimatedLogo> createState() => _AppAnimatedLogoState();
}

class _AppAnimatedLogoState extends State<AppAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnimation;
  int _shakeTick = 0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    );
    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.enableRotation) {
      _rotationController.forward().then((_) {
        widget.onRotationComplete?.call();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onRotationComplete?.call();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AppAnimatedLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorTick != oldWidget.errorTick && widget.errorTick > 0) {
      setState(() => _shakeTick++);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.shakeOnTap) return;
    setState(() => _shakeTick++);
  }

  @override
  Widget build(BuildContext context) {
    Widget logo = Image.asset(
      AppAssets.logo,
      width: widget.size.w,
      height: widget.size.w,
      fit: BoxFit.contain,
    );

    if (widget.enableRotation) {
      logo = RotationTransition(
        turns: _rotationAnimation,
        child: logo,
      );
    }

    if (widget.enableEntrance) {
      logo = logo
          .animate()
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            duration: 600.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(duration: 400.ms);
    }

    logo = logo.shakeOnTick(_shakeTick);

    if (!widget.shakeOnTap) return logo;

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: logo,
    );
  }
}
