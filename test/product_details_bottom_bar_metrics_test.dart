import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:art_inspiration_app/core/constants/app_constants.dart';
import 'package:art_inspiration_app/shared/widgets/product_details_bottom_bar_metrics.dart';

/// يثبّت أن الكيبورد لا يغطّي زر «اضافة الى السلة».
///
/// كان الزر مثبتاً فوق الحافة الآمنة وحدها بينما يرتفع شريط السعر فوق
/// الكيبورد: يكتب الزبون الكمية، ثم يختفي الزر الذي يحتاجه. ولوحة الأرقام
/// على iOS بلا زر «تم»، فلم يكن هناك مخرج.
const _safeBottom = 34.0;
const _keyboardInset = 291.0;

/// ‏`.h` و `.w` تحتاجان ScreenUtil مهيّأً، وهذا أقصر طريق لتهيئته
Future<void> _initScreenUtil(WidgetTester tester) => tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(
          AppConstants.designWidth,
          AppConstants.designHeight,
        ),
        builder: (_, __) => const SizedBox.shrink(),
      ),
    );

void main() {
  testWidgets('بلا كيبورد: الزر فوق الحافة الآمنة، والسعر فوقه', (tester) async {
    await _initScreenUtil(tester);

    final button = ProductDetailsBottomBarMetrics.addToCartBottom(
      safeBottom: _safeBottom,
      keyboardInset: 0,
    );
    final price = ProductDetailsBottomBarMetrics.priceRowBottom(
      safeBottom: _safeBottom,
      keyboardInset: 0,
    );

    expect(button, ProductDetailsBottomBarMetrics.bottomMargin() + _safeBottom);
    expect(price, greaterThan(button));
  });

  testWidgets('مع الكيبورد: الزر يرتفع فوقه ولا يبقى تحته', (tester) async {
    await _initScreenUtil(tester);

    final button = ProductDetailsBottomBarMetrics.addToCartBottom(
      safeBottom: _safeBottom,
      keyboardInset: _keyboardInset,
    );
    final price = ProductDetailsBottomBarMetrics.priceRowBottom(
      safeBottom: _safeBottom,
      keyboardInset: _keyboardInset,
    );

    // الحافة السفلى للزر فوق أعلى الكيبورد
    expect(button, greaterThan(_keyboardInset));
    // وشريط السعر ما زال فوق الزر تماماً، لا متداخلاً معه
    expect(
      price,
      button +
          ProductDetailsBottomBarMetrics.addToCartHeight() +
          ProductDetailsBottomBarMetrics.gapBetweenRows(),
    );
  });
}
