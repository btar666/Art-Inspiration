/// مساعد روابط واتساب — https://wa.me/{international_number}
abstract final class WhatsAppLink {
  /// يبني رابط واتساب من رقم محلي أو دولي أو رابط جاهز.
  static Uri? buildUri(String raw, {String fallbackPhone = ''}) {
    final source = _usableSource(raw) ?? _usableSource(fallbackPhone);
    if (source == null) return null;

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Uri.tryParse(source);
    }

    final international = toIraqInternational(source);
    if (international == null) return null;
    return Uri.parse('https://wa.me/$international');
  }

  /// 07701234567 → 9647701234567
  static String? toIraqInternational(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }

    if (digits.startsWith('964')) {
      return digits;
    }

    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    // أرقام عراقية محمولة تبدأ عادة بـ 7
    if (digits.length >= 9 && digits.startsWith('7')) {
      return '964$digits';
    }

    if (digits.length >= 10) {
      return digits;
    }

    return null;
  }

  static String? _usableSource(String value) {
    final text = value.trim();
    if (text.isEmpty || text == '#') return null;
    return text;
  }
}
