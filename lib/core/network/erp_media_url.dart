import 'api_response_parser.dart';

/// بناء روابط صور المنتجات — من بيانات ERP فقط
abstract final class ErpMediaUrl {
  /// أول صورة صالحة للمنتج (صورة رئيسية)
  static String? resolve({
    required Map<String, dynamic> record,
    required Map<String, dynamic> main,
  }) {
    final all = allUrls(record: record, main: main);
    return all.isEmpty ? null : all.first;
  }

  /// كل روابط الصور (معرض + رئيسية) بترتيب الظهور في ERP
  static List<String> allUrls({
    required Map<String, dynamic> record,
    required Map<String, dynamic> main,
  }) {
    final urls = <String>[];
    final seen = <String>{};

    void add(String? url) {
      final normalized = _normalizeUrl(url);
      if (normalized == null || !seen.add(normalized)) return;
      urls.add(normalized);
    }

    for (final value in [
      main['image'],
      main['imageUrl'],
      main['thumbnail'],
      record['imageUrl'],
    ]) {
      if (_isHttpUrl(value?.toString() ?? '')) {
        add(value.toString());
      }
    }

    for (final url in _collectAttachmentUrls(record['attachments'])) {
      add(url);
    }
    for (final url in _collectAttachmentUrls(main['attachments'])) {
      add(url);
    }

    final galleryRaw = main['gallery'] ?? main['galleryImageUrls'] ?? main['images'];
    for (final url in _collectAttachmentUrls(galleryRaw)) {
      add(url);
    }

    final imageName = _firstNonEmpty([
      main['imageName'],
      record['imageName'],
    ]);
    if (imageName.isNotEmpty) {
      add(
        _storageUrl(
          fileName: imageName,
          tableName: record['tableName']?.toString() ?? 'inventory_products',
        ),
      );
    }

    return urls;
  }

  static List<String> _collectAttachmentUrls(dynamic raw) {
    if (raw == null) return const [];

    if (raw is String && raw.trim().isNotEmpty) {
      final decoded = ApiResponseParser.decodeJsonField(raw);
      if (decoded != null) {
        return _collectAttachmentUrls(decoded);
      }
      if (_isHttpUrl(raw)) return [_normalizeUrl(raw.trim())!];
      final built = _storageUrl(fileName: raw.trim());
      return built == null ? const [] : [built];
    }

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);

      // شكل Dan ERP: {"images":[{url, file_name, ...}, ...]}
      for (final key in ['images', 'files', 'attachments', 'gallery']) {
        final nested = map[key];
        if (nested is List) {
          return _collectAttachmentUrls(nested);
        }
      }

      final single = _fromAttachmentMap(map);
      return single == null ? const [] : [single];
    }

    if (raw is List) {
      final urls = <String>[];
      for (final item in raw) {
        if (item is Map) {
          final url = _fromAttachmentMap(Map<String, dynamic>.from(item));
          if (url != null) urls.add(url);
        } else if (item is String && item.trim().isNotEmpty) {
          if (_isHttpUrl(item)) {
            final normalized = _normalizeUrl(item.trim());
            if (normalized != null) urls.add(normalized);
          } else {
            final built = _storageUrl(fileName: item.trim());
            if (built != null) urls.add(built);
          }
        }
      }
      return urls;
    }

    return const [];
  }

  static String? _fromAttachmentMap(Map<String, dynamic> map) {
    final direct = _firstHttpUrl([
      map['url'],
      map['fileUrl'],
      map['file_url'],
      map['path'],
      map['src'],
      map['link'],
    ]);
    if (direct != null) return _normalizeUrl(direct);

    final fileName = _firstNonEmpty([
      map['file_name'],
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

    if (_isHttpUrl(cleanName)) return _normalizeUrl(cleanName);

    final table = tableName ?? 'products';
    final encodedName = cleanName.split('/').map(Uri.encodeComponent).join('/');
    final encodedTable = Uri.encodeComponent(table);

    return 'https://aman-erp.com/storage/$encodedTable/$encodedName';
  }

  /// صور taxonomy من `/brands` و `/categories` — قد تكون رابطاً كاملاً أو `brands/file.png`
  static String? lookupImage(dynamic raw, {required String folder}) {
    var text = raw?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') return null;
    if (text.startsWith('http://')) {
      text = 'https://${text.substring(7)}';
    }
    if (text.startsWith('https://')) return text;
    if (text.startsWith('/')) {
      return 'https://aman-erp.com$text';
    }
    if (text.startsWith('$folder/')) {
      return 'https://aman-erp.com/storage/$text';
    }
    return 'https://aman-erp.com/storage/$folder/$text';
  }

  /// ERP غالباً يرجع http — نحوّله لـ https ليتوافق مع Android
  static String? _normalizeUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.startsWith('http://')) {
      return 'https://${text.substring(7)}';
    }
    return text;
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
