/// إعدادات مؤقتة لاستخدام Dan ERP حتى اكتمال API الخاص بالتطبيق.
///
/// عطّل [enabled] أو اجعل [accessToken] فارغاً عند الانتقال لـ API مالنا.
abstract final class ErpDevConfig {
  static const enabled = true;

  /// JWT من refreshToken في Postman — حدّثه عند انتهاء الصلاحية.
  static const accessToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2Rhbi1lcnAuY29tLyIsImlhdCI6MTc4MzIwMjg4MiwiZXhwIjoxNzgzMjYyODIyLCJuYmYiOjE3ODMyMDI4ODIsImp0aSI6IjdQQ1h5U2hDSUxuQmptc2MiLCJzdWIiOiIxIiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyIsInVzZXJfaWQiOjEsInVzZXJfZW1haWwiOiJUSE9BTEZPOEFSLlNAR01BSUwuQ09NIiwidXNlcl9uYW1lIjoiREhVTEZJUUFSIFNBTUVSIEFMSklZQUxFRSIsImd1YXJkIjoiYXBpIiwiaXNzdWVkX2F0IjoxNzgzMjAyODgyfQ.7kAB1SaJProR5r54_qFTdBdOA_J336oaFAcKOh4gMi0';

  /// refresh token (base64) من Postman — اختياري لتجديد الجلسة تلقائياً.
  static const refreshToken = '';

  static const userId = '1';
  static const userName = 'DHULFIQAR SAMER ALKIYALEE';
  static const userEmail = 'THOALFO8AR.S@GMAIL.COM';
}
