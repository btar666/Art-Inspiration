import 'models/delivery_address_model.dart';

/// عناوين توصيل تجريبية
abstract final class SavedAddressesMockData {
  static List<DeliveryAddressModel> initial() => [
        const DeliveryAddressModel(
          id: '1',
          governorate: 'المنزل',
          area: 'شارع الجمعية',
          landmark: 'قرب جسر الأحرار',
          isCurrent: true,
        ),
        const DeliveryAddressModel(
          id: '2',
          governorate: 'العمل',
          area: 'شارع الكورنيش',
          landmark: 'مبنى الإدارة',
        ),
      ];
}
