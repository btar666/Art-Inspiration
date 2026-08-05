import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/home/data/models/product_model.dart';
import 'app_back_button.dart';

/// عارض صورة المنتج بملء الشاشة
abstract final class ProductImageFullscreenViewer {
  static Future<void> open(
    BuildContext context, {
    required ProductModel product,
    required int initialIndex,
  }) {
    final urls = _imageUrls(product);
    if (urls.isEmpty) return Future.value();

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'إغلاق',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, _, __) {
        return _ProductImageFullscreenViewer(
          product: product,
          imageUrls: urls,
          initialIndex: initialIndex.clamp(0, urls.length - 1),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static List<String> _imageUrls(ProductModel product) {
    if (product.galleryImageUrls.isNotEmpty) {
      return product.galleryImageUrls;
    }
    final main = product.imageUrl;
    if (main != null && main.isNotEmpty) return [main];
    return const [];
  }
}

class _ProductImageFullscreenViewer extends StatefulWidget {
  const _ProductImageFullscreenViewer({
    required this.product,
    required this.imageUrls,
    required this.initialIndex,
  });

  final ProductModel product;
  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_ProductImageFullscreenViewer> createState() =>
      _ProductImageFullscreenViewerState();
}

class _ProductImageFullscreenViewerState
    extends State<_ProductImageFullscreenViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrls[index],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.spa_outlined,
                          size: 96.sp,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 8.h,
              left: 16.w,
              child: AppBackButton(
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 24.h,
                left: 0,
                right: 0,
                child: Text(
                  '${_currentIndex + 1} / ${widget.imageUrls.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
