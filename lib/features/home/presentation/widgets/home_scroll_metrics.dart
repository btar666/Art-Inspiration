import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد ثابتة لحساب سلوك إخفاء الهيدر وشريط البحث عند التمرير
abstract final class HomeScrollMetrics {
  static double searchBarHeight() => 42.h;

  /// صف الهيدر: بحث + إشعارات تحت شريط الحالة
  static double headerRowHeight() => 8.h + searchBarHeight() + 10.h;

  /// الجزء المرئي من السلايدر تحت شريط البحث داخل الهيرو
  static double sliderVisualHeight() => 175.h;

  /// ارتفاع جسم الهيرو (مساحة الهيدر الثابت + صورة السلايدر)
  static double heroBodyHeight() =>
      headerRowHeight() + sliderVisualHeight();

  /// الارتفاع الكلي للهيرو من أعلى الشاشة
  static double heroHeight(double topInset) =>
      topInset + heroBodyHeight();

  static double categoriesBlockHeight() => 20.h + 12.h + 22.h + 38.h;

  /// عند هذا الإزاحة يبدأ الهيدر بالاختفاء (وصول قسم المنتجات)
  /// الهيدر ثابت فلا يُحسب ارتفاعه — فقط السلايدر الظاهر + الأقسام
  static double logoHideStartOffset() =>
      sliderVisualHeight() + categoriesBlockHeight();

  static double logoHideAnimationRange() => 48.h;
}
