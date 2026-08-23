import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/widgets/cart_icon_button.dart';

/// زر السلة العائم القابل للسحب في أي مكان
class DraggableFloatingCartButton extends ConsumerStatefulWidget {
  const DraggableFloatingCartButton({
    super.key,
    this.onTap,
    this.bottomReservedHeight = 88,
  });

  final VoidCallback? onTap;
  final double bottomReservedHeight;

  @override
  ConsumerState<DraggableFloatingCartButton> createState() =>
      _DraggableFloatingCartButtonState();
}

class _DraggableFloatingCartButtonState
    extends ConsumerState<DraggableFloatingCartButton>
    with TickerProviderStateMixin {
  static const _spring = SpringDescription(
    mass: 0.85,
    stiffness: 380,
    damping: 26,
  );

  static const _throwMinSpeed = 220.0;
  static const _throwStopSpeed = 90.0;
  static const _throwDrag = 5.8;

  Offset? _dragOffset;
  Offset _snapBegin = Offset.zero;
  Offset _snapEnd = Offset.zero;
  Offset _lastThrowVelocity = Offset.zero;
  bool _isDragging = false;

  late final AnimationController _snapController;
  Ticker? _throwTicker;
  Duration? _lastThrowTick;
  Offset _throwVelocity = Offset.zero;
  Size? _motionScreenSize;
  EdgeInsets? _motionPadding;

  double get _buttonSize => 50.w;

  double get _edgeInset => 20.w;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController.unbounded(vsync: this)
      ..addListener(_onSnapTick);
  }

  @override
  void dispose() {
    _stopThrow();
    _snapController
      ..removeListener(_onSnapTick)
      ..dispose();
    super.dispose();
  }

  Offset _defaultPosition(Size screenSize, EdgeInsets padding) {
    return Offset(
      _edgeInset,
      screenSize.height -
          padding.bottom -
          widget.bottomReservedHeight.h -
          _buttonSize -
          12.h,
    );
  }

  double _maxLeft(Size screenSize) => screenSize.width - _buttonSize - _edgeInset;

  double _maxTop(Size screenSize, EdgeInsets padding) =>
      screenSize.height -
      padding.bottom -
      widget.bottomReservedHeight.h -
      _buttonSize;

  Offset _currentPosition(Size screenSize, EdgeInsets padding) {
    return _dragOffset ?? _defaultPosition(screenSize, padding);
  }

  Offset _clampPosition(Offset position, Size screenSize, EdgeInsets padding) {
    return Offset(
      position.dx.clamp(_edgeInset, _maxLeft(screenSize)),
      position.dy.clamp(padding.top, _maxTop(screenSize, padding)),
    );
  }

  Offset _magneticTarget(
    Offset position,
    Size screenSize,
    EdgeInsets padding, {
    Offset? throwVelocity,
  }) {
    final clamped = _clampPosition(position, screenSize, padding);
    final snapLeft = _edgeInset;
    final snapRight = _maxLeft(screenSize);
    final velocity = throwVelocity ?? Offset.zero;

    if (velocity.distance >= _throwMinSpeed &&
        velocity.dx.abs() >= velocity.dy.abs() * 0.45) {
      return Offset(velocity.dx > 0 ? snapRight : snapLeft, clamped.dy);
    }

    final centerX = clamped.dx + (_buttonSize / 2);
    final targetX = centerX < screenSize.width / 2 ? snapLeft : snapRight;

    return Offset(targetX, clamped.dy);
  }

  void _onSnapTick() {
    final t = _snapController.value.clamp(0.0, 1.0);
    setState(() {
      _dragOffset = Offset.lerp(_snapBegin, _snapEnd, t);
    });
  }

  void _stopMotion() {
    _stopThrow();
    if (_snapController.isAnimating) {
      _snapController.stop();
    }
  }

  void _stopThrow() {
    _throwTicker?.stop();
    _throwTicker?.dispose();
    _throwTicker = null;
    _lastThrowTick = null;
    _throwVelocity = Offset.zero;
  }

  void _snapToEdge(
    Size screenSize,
    EdgeInsets padding, {
    Offset? throwVelocity,
    double springVelocity = 0,
  }) {
    final current = _currentPosition(screenSize, padding);
    final target = _magneticTarget(
      current,
      screenSize,
      padding,
      throwVelocity: throwVelocity,
    );

    if ((current - target).distance < 0.5) {
      setState(() => _dragOffset = target);
      return;
    }

    _snapBegin = current;
    _snapEnd = target;

    _snapController.value = 0;
    _snapController.animateWith(
      SpringSimulation(_spring, 0, 1, springVelocity),
    );
  }

  void _startThrow(
    Offset velocity,
    Size screenSize,
    EdgeInsets padding,
  ) {
    _stopMotion();
    _lastThrowVelocity = velocity;
    _throwVelocity = velocity;
    _motionScreenSize = screenSize;
    _motionPadding = padding;
    _lastThrowTick = null;

    _throwTicker = createTicker(_onThrowTick)..start();
  }

  void _onThrowTick(Duration elapsed) {
    final screenSize = _motionScreenSize;
    final padding = _motionPadding;
    if (screenSize == null || padding == null) return;

    if (_lastThrowTick == null) {
      _lastThrowTick = elapsed;
      return;
    }

    final dt =
        (elapsed - _lastThrowTick!).inMicroseconds / 1000000.0;
    _lastThrowTick = elapsed;
    if (dt <= 0 || dt > 0.05) return;

    final decay = math.exp(-_throwDrag * dt);
    _throwVelocity *= decay;

    final current = _currentPosition(screenSize, padding);
    final next = _clampPosition(
      current + _throwVelocity * dt,
      screenSize,
      padding,
    );

    setState(() => _dragOffset = next);

    if (_throwVelocity.distance < _throwStopSpeed) {
      _stopThrow();
      final landed = _currentPosition(screenSize, padding);
      final target = _magneticTarget(
        landed,
        screenSize,
        padding,
        throwVelocity: _lastThrowVelocity,
      );
      final delta = target - landed;
      final distance = delta.distance;
      var springVelocity = 0.0;
      if (distance > 0) {
        springVelocity =
            (_lastThrowVelocity.dx * delta.dx +
                    _lastThrowVelocity.dy * delta.dy) /
                distance /
                1400;
      }
      _snapToEdge(
        screenSize,
        padding,
        throwVelocity: _lastThrowVelocity,
        springVelocity: springVelocity,
      );
    }
  }

  void _onPanStart(Size screenSize, EdgeInsets padding) {
    _stopMotion();
    setState(() {
      _isDragging = true;
      _dragOffset ??= _defaultPosition(screenSize, padding);
    });
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    Size screenSize,
    EdgeInsets padding,
  ) {
    final current = _currentPosition(screenSize, padding);

    setState(() {
      _dragOffset = _clampPosition(
        current + details.delta,
        screenSize,
        padding,
      );
    });
  }

  void _onPanEnd(
    DragEndDetails details,
    Size screenSize,
    EdgeInsets padding,
  ) {
    setState(() => _isDragging = false);
    final velocity = details.velocity.pixelsPerSecond;

    if (velocity.distance >= _throwMinSpeed) {
      _startThrow(velocity, screenSize, padding);
      return;
    }

    _snapToEdge(screenSize, padding);
  }

  @override
  void didUpdateWidget(DraggableFloatingCartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bottomReservedHeight != widget.bottomReservedHeight) {
      _stopMotion();
      _dragOffset = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final position = _currentPosition(screenSize, padding);
    final itemCount = ref.watch(cartItemCountProvider);
    final animationTick = ref.watch(cartAnimationTickProvider);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: RepaintBoundary(
        child: GestureDetector(
          onPanStart: (_) => _onPanStart(screenSize, padding),
          onPanUpdate: (d) => _onPanUpdate(d, screenSize, padding),
          onPanEnd: (d) => _onPanEnd(d, screenSize, padding),
          onPanCancel: () {
            setState(() => _isDragging = false);
            _snapToEdge(screenSize, padding);
          },
          child: AnimatedScale(
            scale: _isDragging ? 1.06 : 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: CartCircleIconButton(
              itemCount: itemCount,
              animationTick: animationTick,
              onTap: widget.onTap,
              size: 50.w,
              iconSize: 40.w,
              showBadge: false,
              showDot: true,
              blurred: true,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shake(
                  delay: 2600.ms,
                  hz: 2.2,
                  duration: 700.ms,
                  rotation: 0.03,
                  offset: const Offset(1.6, 0),
                  curve: Curves.easeInOut,
                ),
          ),
        ),
      ),
    );
  }
}

/// شكل زر السلة العائم — للاستخدام المباشر مع Riverpod
class FloatingCartButton extends ConsumerWidget {
  const FloatingCartButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CartCircleIconButton(
      itemCount: ref.watch(cartItemCountProvider),
      animationTick: ref.watch(cartAnimationTickProvider),
      onTap: onTap,
    );
  }
}
