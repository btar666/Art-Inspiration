/// نموذج عنوان التوصيل المحفوظ
class DeliveryAddressModel {
  const DeliveryAddressModel({
    required this.id,
    required this.governorate,
    required this.area,
    required this.landmark,
    this.lat = 0,
    this.lng = 0,
    this.isCurrent = false,
  });

  final String id;
  final String governorate;
  final String area;
  final String landmark;
  final double lat;
  final double lng;
  final bool isCurrent;

  String get fullAddress => '$governorate، $area${landmark.isNotEmpty ? ' — $landmark' : ''}';

  DeliveryAddressModel copyWith({
    String? governorate,
    String? area,
    String? landmark,
    double? lat,
    double? lng,
    bool? isCurrent,
  }) {
    return DeliveryAddressModel(
      id: id,
      governorate: governorate ?? this.governorate,
      area: area ?? this.area,
      landmark: landmark ?? this.landmark,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}

/// نتيجة نموذج العنوان
class AddressFormResult {
  const AddressFormResult({
    required this.governorate,
    required this.area,
    required this.landmark,
    this.lat = 0,
    this.lng = 0,
  });

  final String governorate;
  final String area;
  final String landmark;
  final double lat;
  final double lng;
}
