import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/home/presentation/widgets/main_bottom_nav.dart';
import 'glass_shimmer_sweep.dart';

const _successGreen = Color(0xFF1FAE62);
const _successGreenSoft = Color(0xFFB8F5D0);
const _stockIcon = Icons.inventory_2_outlined;

OverlayEntry? _activeSnack;
Timer? _holdTimer;

/// عرض رسالة نفاد الكمية
void showOutOfStockSnackBar(BuildContext context) {
  _showGlassSnackBar(
    context,
    const OutOfStockSnackBarContent(),
  );
}

/// عرض تحذير عند تجاوز الكمية المتوفرة
void showStockLimitSnackBar(BuildContext context, int availableQuantity) {
  _showGlassSnackBar(
    context,
    StockLimitSnackBarContent(availableQuantity: availableQuantity),
  );
}

/// عرض رسالة إضافة منتج للسلة بتصميم عائم
void showAddToCartSnackBar(BuildContext context) {
  _showGlassSnackBar(
    context,
    const AddToCartSnackBarContent(),
  );
}

void _showGlassSnackBar(BuildContext context, Widget content) {
  _dismissGlassSnack();

  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _GlassSnackHost(
      bottom: MainBottomNavMetrics.floatingBarReservedHeight.h +
          8.h +
          MediaQuery.paddingOf(context).bottom,
      onFinished: _dismissGlassSnack,
      child: content,
    ),
  );
  _activeSnack = entry;
  overlay.insert(entry);
}

void _dismissGlassSnack() {
  _holdTimer?.cancel();
  _holdTimer = null;
  _activeSnack?.remove();
  _activeSnack = null;
}

class _GlassSnackHost extends StatefulWidget {
  const _GlassSnackHost({
    required this.bottom,
    required this.child,
    required this.onFinished,
  });

  final double bottom;
  final Widget child;
  final VoidCallback onFinished;

  @override
  State<_GlassSnackHost> createState() => _GlassSnackHostState();
}

class _GlassSnackHostState extends State<_GlassSnackHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.18),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _scale = Tween<double>(begin: 0.97, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _holdTimer = Timer(const Duration(milliseconds: 1800), _close);
  }

  Future<void> _close() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 32.w,
      right: 32.w,
      bottom: widget.bottom,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ScaleTransition(
            scale: _scale,
            alignment: Alignment.bottomCenter,
            child: Material(
              type: MaterialType.transparency,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// محتوى سناك بار تجاوز الكمية المتوفرة
class StockLimitSnackBarContent extends StatelessWidget {
  const StockLimitSnackBarContent({
    super.key,
    required this.availableQuantity,
  });

  final int availableQuantity;

  @override
  Widget build(BuildContext context) {
    return _GlassSnackBarShell(
      accent: AppColors.homeDiscount,
      fill: [
        Colors.white.withValues(alpha: 0.42),
        const Color(0xFFFFE0E4).withValues(alpha: 0.48),
        AppColors.homeDiscount.withValues(alpha: 0.16),
      ],
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _GlassSnackBadge(
            background: AppColors.orderStatusCancelledBg.withValues(alpha: 0.72),
            iconColor: AppColors.homeDiscount,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'الكمية الموجودة حاليا فقط $availableQuantity',
              style: AppTextStyles.authField(
                color: AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// محتوى سناك بار نفاد الكمية
class OutOfStockSnackBarContent extends StatelessWidget {
  const OutOfStockSnackBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return _GlassSnackBarShell(
      accent: AppColors.homeDiscount,
      fill: [
        Colors.white.withValues(alpha: 0.42),
        const Color(0xFFFFE0E4).withValues(alpha: 0.48),
        AppColors.homeDiscount.withValues(alpha: 0.16),
      ],
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _GlassSnackBadge(
            background: AppColors.orderStatusCancelledBg.withValues(alpha: 0.72),
            iconColor: AppColors.homeDiscount,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'عذرا الكمية نافذة حاليا',
              style: AppTextStyles.authField(
                color: AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// محتوى سناك بار إضافة المنتج للسلة
class AddToCartSnackBarContent extends StatelessWidget {
  const AddToCartSnackBarContent({super.key});

  @override
  Widget build(BuildContext context) {
    return _GlassSnackBarShell(
      accent: _successGreen,
      fill: [
        Colors.white.withValues(alpha: 0.42),
        _successGreenSoft.withValues(alpha: 0.5),
        _successGreen.withValues(alpha: 0.18),
      ],
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _GlassSnackBadge(
            background: _successGreenSoft.withValues(alpha: 0.72),
            iconColor: _successGreen,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'تمت الإضافة إلى السلة',
              style: AppTextStyles.authField(
                color: AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.shopping_bag_outlined,
            color: _successGreen.withValues(alpha: 0.55),
            size: 18.sp,
          ),
        ],
      ),
    );
  }
}

class _GlassSnackBarShell extends StatelessWidget {
  const _GlassSnackBarShell({
    required this.accent,
    required this.fill,
    required this.child,
  });

  final Color accent;
  final List<Color> fill;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.62),
                width: 1.1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: fill,
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: GlassShimmerSweep()),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSnackBadge extends StatelessWidget {
  const _GlassSnackBadge({
    required this.background,
    required this.iconColor,
  });

  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(11.r);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Icon(
            _stockIcon,
            color: iconColor,
            size: 18.sp,
          ),
        ),
      ),
    );
  }
}
