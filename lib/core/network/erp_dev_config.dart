/// إعدادات مؤقتة لاستخدام Dan ERP حتى اكتمال API الخاص بالتطبيق.
///
/// عطّل [enabled] عند الانتقال لـ API مالنا أو الاعتماد على Login فقط.
abstract final class ErpDevConfig {
  static const enabled = true;

  /// حساب Admin من Dan ERP — يُستخدم لتسجيل دخول تلقائي عند الإقلاع.
  static const email = 'thoalfo8ar.s@gmail.com';
  static const password = '550450Aa';

  /// JWT جاهز (اختياري). إذا فارغ يُستخدم [email]/[password].
  static const accessToken = '';

  /// refresh token اختياري لتجديد الجلسة تلقائياً.
  static const refreshToken = '';

  static const userId = '1';
  static const userName = 'DHULFIQAR SAMER ALJIYALEE';
  static const userEmail = 'THOALFO8AR.S@GMAIL.COM';
  static const userPhone = '07842799567';
}
