import 'package:flutter/material.dart';
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
    extends ConsumerState<DraggableFloatingCartButton> {
  Offset? _position;

  double get _buttonSize => 50.w;

  Offset _defaultPosition(Size screenSize, EdgeInsets padding) {
    return Offset(
      20.w,
      screenSize.height -
          padding.bottom -
          widget.bottomReservedHeight.h -
          _buttonSize -
          12.h,
    );
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    Size screenSize,
    EdgeInsets padding,
  ) {
    final defaultPos = _defaultPosition(screenSize, padding);
    final current = _position ?? defaultPos;
    final maxTop = screenSize.height -
        padding.bottom -
        widget.bottomReservedHeight.h -
        _buttonSize;
    final maxLeft = screenSize.width - _buttonSize;

    setState(() {
      _position = Offset(
        (current.dx + details.delta.dx).clamp(0.0, maxLeft),
        (current.dy + details.delta.dy).clamp(padding.top, maxTop),
      );
    });
  }

  @override
  void didUpdateWidget(DraggableFloatingCartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bottomReservedHeight != widget.bottomReservedHeight) {
      _position = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final position = _position ?? _defaultPosition(screenSize, padding);
    final itemCount = ref.watch(cartItemCountProvider);
    final animationTick = ref.watch(cartAnimationTickProvider);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: RepaintBoundary(
        child: GestureDetector(
          onPanUpdate: (d) => _onPanUpdate(d, screenSize, padding),
          child: CartCircleIconButton(
            itemCount: itemCount,
            animationTick: animationTick,
            onTap: widget.onTap,
            size: 50.w,
            iconSize: 40.w,
            showBadge: false,
            showDot: true,
            blurred: true,
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
