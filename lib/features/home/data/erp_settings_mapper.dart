import '../../../core/network/api_response_parser.dart';
import 'models/store_settings.dart';

/// تحويل سجل setting إلى إعدادات المتجر
abstract final class ErpSettingsMapper {
  static StoreSettings fromRecords(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return const StoreSettings();

    final main = ApiResponseParser.decodeJsonField(records.first['main']) ?? {};
    final currency = main['currency'];
    if (currency is! Map) return const StoreSettings();

    final selected = currency['selected']?.toString() ?? 'IQD';
    final selectedSymbol = currency['selectedSymbol']?.toString() ?? 'د.ع';

    var arabicName = 'الدينار العراقي';
    final list = currency['list'];
    if (list is List) {
      for (final item in list) {
        if (item is Map && item['code']?.toString() == selected) {
          arabicName = item['arabic_name']?.toString() ?? arabicName;
          break;
        }
      }
    }

    return StoreSettings(
      currencyCode: selected,
      currencySymbol: selectedSymbol,
      currencyArabicName: arabicName,
    );
  }
}
