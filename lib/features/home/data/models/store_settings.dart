/// إعدادات المتجر من جدول setting
class StoreSettings {
  const StoreSettings({
    this.currencyCode = 'IQD',
    this.currencySymbol = 'د.ع',
    this.currencyArabicName = 'الدينار العراقي',
    this.categories = const [],
    this.brands = const [],
  });

  final String currencyCode;
  final String currencySymbol;
  final String currencyArabicName;
  final List<String> categories;
  final List<String> brands;
}
