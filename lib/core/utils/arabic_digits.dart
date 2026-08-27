import 'package:flutter/services.dart';

const _arabicIndic = '٠١٢٣٤٥٦٧٨٩';
const _extendedArabicIndic = '۰۱۲۳۴۵۶۷۸۹';

/// يحوّل الأرقام العربية ٠١٢٣ والفارسية ۰۱۲۳ إلى أرقام إنجليزية 0123.
/// لوحة المفاتيح العربية تكتب ٠٧٧٠ ولا يقبلها الباك-إند ولا `int.parse`.
String toEnglishDigits(String input) {
  var out = input;
  for (var i = 0; i < 10; i++) {
    out = out
        .replaceAll(_arabicIndic[i], '$i')
        .replaceAll(_extendedArabicIndic[i], '$i');
  }
  return out;
}

/// يطبّق [toEnglishDigits] أثناء الكتابة. التحويل حرف بحرف، فموضع المؤشر
/// يبقى صحيحاً بلا حساب إضافي.
class ArabicDigitsInputFormatter extends TextInputFormatter {
  const ArabicDigitsInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = toEnglishDigits(newValue.text);
    return text == newValue.text ? newValue : newValue.copyWith(text: text);
  }
}

/// حقول الهاتف: أرقام إنجليزية فقط، ١١ رقماً كحدّ أقصى (07XXXXXXXXX).
final phoneInputFormatters = <TextInputFormatter>[
  const ArabicDigitsInputFormatter(),
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(11),
];
