import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:art_inspiration_app/core/utils/arabic_digits.dart';

TextEditingValue _run(List<TextInputFormatter> formatters, String typed) {
  var value = TextEditingValue.empty;
  for (final ch in typed.split('')) {
    var next = TextEditingValue(
      text: value.text + ch,
      selection: TextSelection.collapsed(offset: value.text.length + 1),
    );
    for (final f in formatters) {
      next = f.formatEditUpdate(value, next);
    }
    value = next;
  }
  return value;
}

void main() {
  test('يحوّل الأرقام العربية والفارسية', () {
    expect(toEnglishDigits('٠٧٧٠١٢٣٤٥٦٧'), '07701234567');
    expect(toEnglishDigits('۰۷۷۰'), '0770');
    expect(toEnglishDigits('0770'), '0770');
  });

  test('حقل الهاتف: عربي إلى إنجليزي، ولا يتجاوز ١١ رقماً', () {
    expect(_run(phoneInputFormatters, '٠٧٧٠١٢٣٤٥٦٧').text, '07701234567');
    expect(_run(phoneInputFormatters, '٠٧٧٠١٢٣٤٥٦٧٨٩').text, '07701234567');
    expect(_run(phoneInputFormatters, '٠٧٧-٠ ١٢أ٣').text, '0770123');
  });

  test('حقل الكمية: التحويل يسبق digitsOnly', () {
    final quantity = [
      const ArabicDigitsInputFormatter(),
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(6),
    ];
    expect(_run(quantity, '١٢٣').text, '123');
  });
}
