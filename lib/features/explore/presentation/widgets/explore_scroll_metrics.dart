import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد تقديرية لمسافة السكرول — يُستبدل بالقياس الفعلي عند التخطيط
abstract final class ExploreScrollMetrics {
  static double titleSectionHeight() => 8.h + 36.h;

  static double tabsSectionHeight() => 8.h + 48.h;

  static double pinnedHeaderHeight(double topInset) =>
      topInset + titleSectionHeight() + tabsSectionHeight();
}
