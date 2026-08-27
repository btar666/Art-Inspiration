/// نوع وسائط السلايدر
enum SliderMediaType {
  image,
  video,
}

/// هدف الربط عند الضغط على السلايدر
enum SliderLinkType {
  none,
  product,
  category,
  brand,
}

/// عنصر سلايدر من الباكند
class SliderItemModel {
  const SliderItemModel({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    required this.linkType,
    this.linkId,
    this.linkName,
  });

  final String id;
  final String mediaUrl;
  final SliderMediaType mediaType;
  final SliderLinkType linkType;
  final int? linkId;
  final String? linkName;

  bool get isVideo => mediaType == SliderMediaType.video;

  bool get hasLink {
    if (linkType == SliderLinkType.none) return false;
    if (linkType == SliderLinkType.product) {
      return linkId != null;
    }
    final name = linkName?.trim() ?? '';
    return name.isNotEmpty || linkId != null;
  }

  factory SliderItemModel.fromJson(Map<String, dynamic> json) {
    final mediaType = _parseMediaType(json);
    final rawUrl = _firstNonEmpty([
      if (mediaType == SliderMediaType.video) json['video'],
      json['url'],
      json['image'],
      json['video'],
    ]);

    return SliderItemModel(
      id: (json['id'] ?? '').toString(),
      mediaUrl: _normalizeMediaUrl(rawUrl),
      mediaType: mediaType,
      linkType: _parseLinkType(json['erp_type']),
      linkId: _parseLinkId(json['erp_id']),
      linkName: _firstNonEmpty([json['erp_name']]),
    );
  }

  static SliderMediaType _parseMediaType(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 2 || type == '2') return SliderMediaType.video;

    final videoField = (json['video'] ?? '').toString().trim();
    if (videoField.isNotEmpty) return SliderMediaType.video;

    final url = _firstNonEmpty([json['url'], json['image']]);
    if (_isVideoUrl(url)) return SliderMediaType.video;

    return SliderMediaType.image;
  }

  static SliderLinkType _parseLinkType(dynamic value) {
    final raw = value?.toString().trim().toLowerCase() ?? '';
    return switch (raw) {
      'product' => SliderLinkType.product,
      'category' => SliderLinkType.category,
      'brand' => SliderLinkType.brand,
      _ => SliderLinkType.none,
    };
  }

  static int? _parseLinkId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final text = value.toString().trim();
    if (text.isEmpty || text == '0' || text == 'null') return null;
    return int.tryParse(text);
  }

  /// نصوص نائبة يرسلها الباكند كنص حرفي، لا كـ JSON null
  ///
  /// ‏api/slider يعيد فعلاً `"url":"null"` — أربعة أحرف، لا قيمة فارغة.
  /// تحرس هذه القائمة الآن الروابط و `erp_name`؛ العنوان لم يعد يُرسم.
  static const _placeholderTexts = {'null', 'undefined'};

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isEmpty) continue;
      if (_placeholderTexts.contains(text.toLowerCase())) continue;
      return text;
    }
    return '';
  }

  static String _normalizeMediaUrl(String rawUrl) {
    var url = rawUrl.trim();
    if (url.isEmpty) return url;
    if (!url.startsWith('http')) {
      url = 'https://art-inspiration.com/storage/$url';
    }
    return url;
  }

  static bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.m3u8') ||
        lower.contains('/video/');
  }
}
