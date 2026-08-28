import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أبعاد ثابتة لحساب سلوك إخفاء الهيدر وشريط البحث عند التمرير
abstract final class HomeScrollMetrics {
  static double searchBarHeight() => 42.h;

  /// صف الهيدر: بحث + إشعارات تحت شريط الحالة
  static double headerRowHeight() => 8.h + searchBarHeight() + 10.h;

  /// نسبة صندوق البانر: ‏12:11‏ — أي تصدير ‏1200×1100‏ بكسل
  ///
  /// الصندوق يأخذ ارتفاعه من عرض الشاشة وحده، فنسبته واحدة على الآيفون
  /// والأندرويد مهما اختلفت القصّة (notch). صورة بهذه النسبة تملأه تماماً:
  /// بلا قص وبلا فراغ. غيّر هذا الرقم فقط إذا غيّر المصمّم نسبة الصور.
  static const double bannerAspect = 12 / 11;

  /// أطول ما يُسمح للبانر: ‏46%‏ من ارتفاع الشاشة. على هاتف قصير (‏360×640‏)
  /// كان البانر يبتلع نصف الشاشة، وهنا يُقصّ أعلى الصورة — وهو النطاق الذي
  /// يغطّيه الهيدر أصلاً.
  static const double heroMaxScreenFraction = 0.46;

  /// الارتفاع الكلي للهيرو من أعلى الشاشة
  static double heroHeight(double topInset, Size screen) {
    final byWidth = screen.width / bannerAspect;
    final ceiling = screen.height * heroMaxScreenFraction;
    final floor = topInset + headerRowHeight();
    final height = byWidth < ceiling ? byWidth : ceiling;
    return height < floor ? floor : height;
  }

  /// الجزء المرئي من السلايدر تحت شريط البحث داخل الهيرو
  static double sliderVisualHeight(double topInset, Size screen) =>
      heroHeight(topInset, screen) - topInset - headerRowHeight();

  static double categoriesBlockHeight() => 20.h + 12.h + 22.h + 38.h;

  /// عند هذا الإزاحة يبدأ الهيدر بالاختفاء (وصول قسم المنتجات)
  /// الهيدر ثابت فلا يُحسب ارتفاعه — فقط السلايدر الظاهر + الأقسام
  static double logoHideStartOffset(double topInset, Size screen) =>
      sliderVisualHeight(topInset, screen) + categoriesBlockHeight();

  static double logoHideAnimationRange() => 48.h;
}
