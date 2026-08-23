import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../cart/presentation/widgets/cart_page_metrics.dart';
import '../../../home/presentation/widgets/main_bottom_nav.dart';

/// مقاييس الزر العائم في صفحة مراجعة الطلب
abstract final class CheckoutReviewOverlayMetrics {
  /// مسافة إضافية أسفل السكرول لتمرير المحتوى بحرية تحت الزر
  static double scrollExtraBottom() => 48.h;

  /// مسافة إضافية أسفل الزر عن حافة الشاشة
  static double overlayBottomExtra() => 12.h;

  /// ارتفاع زر السلة الزجاجي (CartCheckoutFooter glassy)
  static double cartButtonHeight() => MainBottomNavMetrics.height();

  static double overlayBottomOffset(BuildContext context) {
    final footer = CartPageMetrics.footerPadding();
    return footer.bottom +
        overlayBottomExtra() +
        MediaQuery.paddingOf(context).bottom;
  }

  static double scrollBottomInset(BuildContext context) {
    final footer = CartPageMetrics.footerPadding();
    return cartButtonHeight() +
        footer.top +
        footer.bottom +
        overlayBottomExtra() +
        scrollExtraBottom() +
        MediaQuery.paddingOf(context).bottom;
  }
}
