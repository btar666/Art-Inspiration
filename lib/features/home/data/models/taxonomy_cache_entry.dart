/// كاش أقسام/براندات المتوفرة — يُبنى من مسح المنتجات غير النافذة
class TaxonomyCacheEntry {
  const TaxonomyCacheEntry({
    required this.categoryNames,
    required this.brandNames,
    required this.inStockCount,
    required this.savedAt,
  });

  final List<String> categoryNames;
  final List<String> brandNames;
  final int inStockCount;
  final DateTime savedAt;

  static const ttl = Duration(hours: 24);

  bool get isValid => DateTime.now().difference(savedAt) < ttl;

  Map<String, dynamic> toJson() => {
        'categoryNames': categoryNames,
        'brandNames': brandNames,
        'inStockCount': inStockCount,
        'savedAt': savedAt.toIso8601String(),
      };

  factory TaxonomyCacheEntry.fromJson(Map<String, dynamic> json) =>
      TaxonomyCacheEntry(
        categoryNames: (json['categoryNames'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        brandNames: (json['brandNames'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        inStockCount: json['inStockCount'] as int? ?? 0,
        savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}
