import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد سلوك التمرير والهيدر في صفحة الاكسبلور
abstract final class ExploreScrollMetrics {
  static double titleSectionHeight() => 8.h + 36.h;

  static double tabsSectionHeight() => 8.h + 48.h;

  static double titleBarHeight(double topInset) => topInset + titleSectionHeight();

  static double tabsBlockHeight() => tabsSectionHeight();

  /// مسافة تمرير إضافية قبل بدء اختفاء الهيدر (العنوان + التبويبات)
  static double headerHideDelayScroll() => 72.h;

  /// عند هذا الإزاحة يبدأ الهيدر بالاختفاء
  static double headerHideStartOffset() => headerHideDelayScroll();

  static double headerHideAnimationRange() => 56.h;

  static double pinnedHeaderHeight(double topInset) =>
      titleBarHeight(topInset) + tabsBlockHeight();
}
