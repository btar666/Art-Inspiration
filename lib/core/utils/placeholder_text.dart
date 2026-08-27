/// الباكند يرسل النص النائب كنص حرفي، لا كـ JSON null.
///
/// ‏`api/slider` أعاد فعلاً `"title":"null"` — أربعة أحرف — فظهرت كلمة null
/// بالأبيض فوق صورة البانر. نفس الفتحة مفتوحة في سياسة الإرجاع و«من نحن»،
/// وكلاهما نص يكتبه موظف في لوحة التحكم، والحقل الفارغ يُحفظ كنص "null".
/// لذلك يمرّ كل نص معروض قادم من باكند المتجر من هنا أولاً.
const _placeholders = {'null', 'undefined', '#'};

/// يعيد النص بعد إزالة الفراغات، أو `''` إذا كان فارغاً أو نصاً نائباً
String cleanText(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return _placeholders.contains(text.toLowerCase()) ? '' : text;
}
