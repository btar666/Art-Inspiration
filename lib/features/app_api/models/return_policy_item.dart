import '../../../core/utils/placeholder_text.dart';

/// بند سياسة من api/return_policy
class ReturnPolicyItem {
  const ReturnPolicyItem({
    required this.id,
    required this.title,
    required this.details,
  });

  final int id;
  final String title;
  final String details;

  bool get hasContent => title.trim().isNotEmpty || details.trim().isNotEmpty;

  factory ReturnPolicyItem.fromJson(Map<String, dynamic> json) {
    final rawDetails = cleanText(
      json['details'] ?? json['content'] ?? json['text'] ?? json['body'],
    );
    return ReturnPolicyItem(
      id: _asInt(json['id']) ?? 0,
      title: cleanText(json['title'] ?? json['name']),
      details: _stripHtml(rawDetails),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static String _stripHtml(String raw) {
    var text = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    return text;
  }
}
