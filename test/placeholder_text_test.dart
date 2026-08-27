import 'package:flutter_test/flutter_test.dart';

import 'package:art_inspiration_app/features/app_api/models/app_info_model.dart';
import 'package:art_inspiration_app/features/app_api/models/return_policy_item.dart';

/// يثبّت أن النص النائب "null" لا يصل إلى الشاشة.
///
/// الأهم هو عنوان سياسة الإرجاع: فهو يُعرض داخل مربّع الموافقة في إتمام
/// الطلب — «أقر بأنني قرأت «null» وأوافق عليها» — على مربّع يجب على الزبون
/// تأشيره قبل الشراء.
void main() {
  test('بند السياسة يرفض النص النائب "null"', () {
    final item = ReturnPolicyItem.fromJson({
      'id': 1,
      'title': 'null',
      'details': 'null',
    });

    expect(item.title, '');
    expect(item.details, '');
    expect(item.hasContent, isFalse);
  });

  test('بند السياسة يحتفظ بالنص الحقيقي وينزع وسوم HTML', () {
    final item = ReturnPolicyItem.fromJson({
      'id': 1,
      'title': 'ضمان المنتجات',
      'details': '<p><b>جميع المنتجات اصلية</b></p>',
    });

    expect(item.title, 'ضمان المنتجات');
    expect(item.details, 'جميع المنتجات اصلية');
    expect(item.hasContent, isTrue);
  });

  test('«من نحن» يرفض النص النائب فتظهر النسخة الاحتياطية', () {
    expect(AppInfoModel.fromJson({'about': 'null'}).about, '');
    expect(AppInfoModel.fromJson({'about': 'NULL'}).about, '');
    expect(AppInfoModel.fromJson({'about': ' '}).about, '');
    expect(AppInfoModel.fromJson({'about': 'شركة الهام الفن'}).about,
        'شركة الهام الفن');
  });
}
