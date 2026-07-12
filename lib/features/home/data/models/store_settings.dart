/// إعدادات المتجر من جدول setting
class StoreSettings {
  const StoreSettings({
    this.currencyCode = 'IQD',
    this.currencySymbol = 'د.ع',
    this.currencyArabicName = 'الدينار العراقي',
  });

  final String currencyCode;
  final String currencySymbol;
  final String currencyArabicName;
}
