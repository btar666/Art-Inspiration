import '../../../core/utils/placeholder_text.dart';

/// معلومات التطبيق من api/info
class AppInfoModel {
  const AppInfoModel({
    this.website = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.about = '',
    this.copyright = '',
    this.instagram = '',
    this.facebook = '',
    this.telegram = '',
    this.whatsapp = '',
    this.tiktok = '',
    this.x = '',
  });

  final String website;
  final String email;
  final String phone;
  final String address;
  final String about;
  final String copyright;
  final String instagram;
  final String facebook;
  final String telegram;
  final String whatsapp;
  final String tiktok;
  final String x;

  factory AppInfoModel.fromJson(Map<String, dynamic> json) {
    return AppInfoModel(
      website: json['website']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      about: cleanText(json['about']),
      copyright: json['copyright']?.toString() ?? '',
      instagram: json['instagram']?.toString() ?? '',
      facebook: json['facebook']?.toString() ?? '',
      telegram: json['telegram']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString() ?? '',
      tiktok: json['tiktok']?.toString() ?? '',
      x: json['x']?.toString() ?? '',
    );
  }
}
