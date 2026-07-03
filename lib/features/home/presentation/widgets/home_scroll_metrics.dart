import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد ثابتة لحساب سلوك إخفاء الشعار وشريط البحث عند التمرير
abstract final class HomeScrollMetrics {
  static double logoBarHeight() => 8.h + 44.h + 8.h;

  static double searchBlockHeight() => 50.h + 14.h;

  static double categoriesBlockHeight() => 20.h + 12.h + 22.h + 38.h;

  static double bannerBlockHeight() => 16.h + 150.h + 10.h;

  /// عند هذا الإزاحة يبدأ الشعار بالاختفاء (وصول قسم المنتجات)
  static double logoHideStartOffset() =>
      searchBlockHeight() + categoriesBlockHeight() + bannerBlockHeight();

  static double logoHideAnimationRange() => 48.h;
}
