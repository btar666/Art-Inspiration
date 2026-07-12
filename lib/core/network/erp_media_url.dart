import 'api_config.dart';
import 'api_response_parser.dart';

/// بناء روابط صور منتجات Dan ERP — من بيانات ERP فقط
abstract final class ErpMediaUrl {
  static String? resolve({
    required Map<String, dynamic> record,
    required Map<String, dynamic> main,
  }) {
    final direct = _firstHttpUrl([
      main['image'],
      main['imageUrl'],
      main['thumbnail'],
      record['imageUrl'],
    ]);
    if (direct != null) return direct;

    final fromAttachments = _fromAttachments(record['attachments']) ??
        _fromAttachments(main['attachments']);
    if (fromAttachments != null) return fromAttachments;

    final imageName = _firstNonEmpty([
      main['imageName'],
      record['imageName'],
    ]);
    if (imageName.isNotEmpty) {
      return _storageUrl(
        fileName: imageName,
        tableName: record['tableName']?.toString() ?? 'inventory_products',
      );
    }

    return null;
  }

  static String? _fromAttachments(dynamic raw) {
    if (raw == null) return null;

    if (raw is String && raw.trim().isNotEmpty) {
      final decoded = ApiResponseParser.decodeJsonField(raw);
      if (decoded != null) {
        return _fromAttachmentMap(decoded);
      }
      if (_isHttpUrl(raw)) return raw.trim();
      return _storageUrl(fileName: raw.trim());
    }

    if (raw is Map) {
      return _fromAttachmentMap(Map<String, dynamic>.from(raw));
    }

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final url = _fromAttachmentMap(Map<String, dynamic>.from(item));
          if (url != null) return url;
        } else if (item is String && item.trim().isNotEmpty) {
          if (_isHttpUrl(item)) return item.trim();
          final built = _storageUrl(fileName: item.trim());
          if (built != null) return built;
        }
      }
    }

    return null;
  }

  static String? _fromAttachmentMap(Map<String, dynamic> map) {
    final direct = _firstHttpUrl([
      map['url'],
      map['fileUrl'],
      map['path'],
      map['src'],
      map['link'],
    ]);
    if (direct != null) return direct;

    final fileName = _firstNonEmpty([
      map['fileName'],
      map['filename'],
      map['name'],
      map['imageName'],
    ]);
    if (fileName.isEmpty) return null;

    return _storageUrl(
      fileName: fileName,
      tableName: map['tableName']?.toString(),
    );
  }

  static String? _storageUrl({
    required String fileName,
    String? tableName,
  }) {
    final cleanName = fileName.trim();
    if (cleanName.isEmpty) return null;

    if (_isHttpUrl(cleanName)) return cleanName;

    final table = tableName ?? 'inventory_products';
    final encodedName = cleanName.split('/').map(Uri.encodeComponent).join('/');
    final encodedClient = Uri.encodeComponent(ApiConfig.clientId);
    final encodedTable = Uri.encodeComponent(table);

    return '${ApiConfig.baseUrl}/storage/$encodedClient/$encodedTable/$encodedName';
  }

  static String? _firstHttpUrl(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (_isHttpUrl(text)) return text;
    }
    return null;
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static bool _isHttpUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }
}
