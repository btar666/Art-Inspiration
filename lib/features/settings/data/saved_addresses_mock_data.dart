import 'models/delivery_address_model.dart';

/// عناوين توصيل تجريبية
abstract final class SavedAddressesMockData {
  static List<DeliveryAddressModel> initial() => [
        const DeliveryAddressModel(
          id: '1',
          governorate: 'بغداد',
          area: 'الكرادة',
          landmark: 'قرب جسر الأحرار',
          isCurrent: true,
        ),
        const DeliveryAddressModel(
          id: '2',
          governorate: 'البصرة',
          area: 'العشار',
          landmark: 'شارع الكورنيش',
        ),
      ];
}
