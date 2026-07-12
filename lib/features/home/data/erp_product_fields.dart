/// استخراج حقول التصنيف/البراند من main المنتج في Dan ERP
abstract final class ErpProductFields {
  /// تسميات الأقسام للعرض (يفضّل الاسم على المعرف).
  static List<String> categoryValues(Map<String, dynamic> main) {
    final labels = <String>[];
    final seen = <String>{};

    void addLabel(dynamic value) {
      final text = value?.toString().trim() ?? '';
      if (text.isEmpty || !seen.add(text)) return;
      labels.add(text);
    }

    void addFromEntry(dynamic item) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final label = _firstNonEmpty([
          map['nameAr'],
          map['name'],
          map['label'],
          map['title'],
          map['categoryName'],
          map['id'],
          map['categoryId'],
        ]);
        addLabel(label);
        return;
      }
      addLabel(item);
    }

    addLabel(main['categoryName']);
    addLabel(main['category']);

    final categoryIds = main['categoryIds'];
    if (categoryIds is List) {
      for (final item in categoryIds) {
        addFromEntry(item);
      }
    }

    // المعرف المفرد أخيراً — غالباً غير مقروء للمستخدم
    addLabel(main['categoryId']);

    return labels;
  }

  /// كل المفاتيح المستخدمة للمطابقة (اسم + id).
  static List<String> categoryMatchKeys(Map<String, dynamic> main) {
    final keys = <String>{};

    void add(dynamic value) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) keys.add(text);
    }

    add(main['categoryName']);
    add(main['category']);
    add(main['categoryId']);

    final categoryIds = main['categoryIds'];
    if (categoryIds is List) {
      for (final item in categoryIds) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          add(map['nameAr']);
          add(map['name']);
          add(map['label']);
          add(map['title']);
          add(map['categoryName']);
          add(map['id']);
          add(map['categoryId']);
        } else {
          add(item);
        }
      }
    }

    return keys.toList();
  }

  static String primaryCategory(Map<String, dynamic> main) {
    final values = categoryValues(main);
    if (values.isEmpty) return '';

    // فضّل اسماً مقروءاً على معرف مثل category_123
    for (final value in values) {
      if (!_looksLikeOpaqueId(value)) return value;
    }
    return values.first;
  }

  static String brandValue(Map<String, dynamic> main) {
    for (final value in [main['brandId'], main['brand'], main['brandName']]) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  /// استخراج قوائم الأقسام/البراندات من setting.main إن وُجدت.
  static List<String> listFromSettingsField(dynamic raw) {
    if (raw == null) return const [];
    final values = <String>{};

    void add(dynamic value) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) values.add(text);
    }

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          add(
            map['nameAr'] ??
                map['name'] ??
                map['label'] ??
                map['title'] ??
                map['id'],
          );
        } else {
          add(item);
        }
      }
    } else if (raw is Map) {
      for (final entry in raw.values) {
        if (entry is Map) {
          final map = Map<String, dynamic>.from(entry);
          add(
            map['nameAr'] ??
                map['name'] ??
                map['label'] ??
                map['title'] ??
                map['id'],
          );
        } else {
          add(entry);
        }
      }
    }

    return values.toList();
  }

  static bool _looksLikeOpaqueId(String value) {
    return RegExp(r'^(category_|cat_|id_)', caseSensitive: false)
            .hasMatch(value) ||
        RegExp(r'^\d+$').hasMatch(value);
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}
