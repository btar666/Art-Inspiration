import '../../../core/network/api_response_parser.dart';
import 'erp_product_fields.dart';
import 'models/store_settings.dart';

/// تحويل سجل setting إلى إعدادات المتجر + أقسام/براندات إن وُجدت
abstract final class ErpSettingsMapper {
  static StoreSettings fromRecords(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return const StoreSettings();

    final main = ApiResponseParser.decodeJsonField(records.first['main']) ?? {};
    final currency = main['currency'];

    var currencyCode = 'IQD';
    var currencySymbol = 'د.ع';
    var arabicName = 'الدينار العراقي';

    if (currency is Map) {
      currencyCode = currency['selected']?.toString() ?? currencyCode;
      currencySymbol = currency['selectedSymbol']?.toString() ?? currencySymbol;

      final list = currency['list'];
      if (list is List) {
        for (final item in list) {
          if (item is Map && item['code']?.toString() == currencyCode) {
            arabicName = item['arabic_name']?.toString() ?? arabicName;
            break;
          }
        }
      }
    }

    final categories = <String>{
      ...ErpProductFields.listFromSettingsField(main['categories']),
      ...ErpProductFields.listFromSettingsField(main['categoryList']),
      ...ErpProductFields.listFromSettingsField(main['productCategories']),
      ...ErpProductFields.listFromSettingsField(main['Categories']),
    };

    final brands = <String>{
      ...ErpProductFields.listFromSettingsField(main['brands']),
      ...ErpProductFields.listFromSettingsField(main['brandList']),
      ...ErpProductFields.listFromSettingsField(main['Brands']),
    };

    return StoreSettings(
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      currencyArabicName: arabicName,
      categories: categories.toList()..sort(),
      brands: brands.toList()..sort(),
    );
  }
}
