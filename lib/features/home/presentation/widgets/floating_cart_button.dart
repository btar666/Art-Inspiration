import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// زر السلة العائم القابل للسحب في أي مكان
class DraggableFloatingCartButton extends StatefulWidget {
  const DraggableFloatingCartButton({
    super.key,
    this.itemCount = 1,
    this.onTap,
    this.bottomReservedHeight = 88,
  });

  final int itemCount;
  final VoidCallback? onTap;
  final double bottomReservedHeight;

  @override
  State<DraggableFloatingCartButton> createState() =>
      _DraggableFloatingCartButtonState();
}

class _DraggableFloatingCartButtonState extends State<DraggableFloatingCartButton> {
  Offset? _position;

  double get _buttonSize => 56.w;

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
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final position = _position ?? _defaultPosition(screenSize, padding);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (d) => _onPanUpdate(d, screenSize, padding),
        onTap: widget.onTap,
        child: FloatingCartButton(itemCount: widget.itemCount),
      ),
    );
  }
}

/// شكل زر السلة العائم
class FloatingCartButton extends StatelessWidget {
  const FloatingCartButton({
    super.key,
    this.itemCount = 1,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Image.asset(
            AppAssets.shoppingCartIcon,
            width: 28.w,
            height: 28.w,
            fit: BoxFit.contain,
          ),
          if (itemCount > 0)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  color: AppColors.notificationDot,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
