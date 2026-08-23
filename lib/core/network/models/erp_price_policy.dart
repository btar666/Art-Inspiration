/// سياسة التسعير في أمان ERP — تحدد سعر العرض للعميل
enum ErpPricePolicy {
  retail,
  halfWholesale,
  wholesale;

  /// من قيمة `price_policy` في سجل العميل بأمان ERP
  static ErpPricePolicy fromErp(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'wholesale':
      case 'جملة':
        return ErpPricePolicy.wholesale;
      case 'half_wholesale':
      case 'half-wholesale':
      case 'halfwholesale':
      case 'نصف_جملة':
      case 'نصف جملة':
        return ErpPricePolicy.halfWholesale;
      case 'retail':
      case 'مفرق':
      default:
        return ErpPricePolicy.retail;
    }
  }

  String get erpValue => switch (this) {
        ErpPricePolicy.retail => 'retail',
        ErpPricePolicy.halfWholesale => 'half_wholesale',
        ErpPricePolicy.wholesale => 'wholesale',
      };

  String get labelAr => switch (this) {
        ErpPricePolicy.retail => 'مفرق',
        ErpPricePolicy.halfWholesale => 'نصف جملة',
        ErpPricePolicy.wholesale => 'جملة',
      };

  String? toJson() => erpValue;

  static ErpPricePolicy? fromJson(dynamic raw) {
    if (raw == null) return null;
    return fromErp(raw.toString());
  }
}
