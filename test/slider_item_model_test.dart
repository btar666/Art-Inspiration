import 'package:flutter_test/flutter_test.dart';

import 'package:art_inspiration_app/features/app_api/models/slider_item_model.dart';

/// شريحة سلايدر حقيقية من api/slider يوم 2026-08-27 — لاحظ "null" كنص
Map<String, dynamic> _slide({Object? title}) => {
      'id': 11,
      'title': title,
      'image': 'JaSThcfGXPdyG5En_1787654400.png',
      'type': 1,
      'erp_type': 'none',
      'erp_id': null,
      'erp_name': null,
      'url': 'https://art-inspiration.com/storage/JaSThcfGXPdyG5En_1787654400.png',
    };

void main() {
  test('عنوان الشريحة لا يعرض النص النائب للمستخدم', () {
    // الحالة التي ظهرت فعلاً على الرئيسية: كلمة null فوق صورة البانر
    expect(SliderItemModel.fromJson(_slide(title: 'null')).title, '');
    expect(SliderItemModel.fromJson(_slide(title: 'NULL')).title, '');
    expect(SliderItemModel.fromJson(_slide(title: ' null ')).title, '');
    expect(SliderItemModel.fromJson(_slide(title: 'undefined')).title, '');

    // JSON null وقيمة فارغة كانتا تعملان قبل الإصلاح، ويجب أن تبقيا كذلك
    expect(SliderItemModel.fromJson(_slide(title: null)).title, '');
    expect(SliderItemModel.fromJson(_slide(title: '')).title, '');
  });

  test('العنوان الحقيقي يمر كما هو', () {
    expect(
      SliderItemModel.fromJson(_slide(title: 'التوصيل داخل كربلاء')).title,
      'التوصيل داخل كربلاء',
    );
    // لا نقص الكلمات التي تحتوي النص النائب داخلها
    expect(SliderItemModel.fromJson(_slide(title: 'nullify')).title, 'nullify');
  });

  test('رابط الوسائط ما زال يتجاهل النص النائب', () {
    final json = _slide(title: 'x')
      ..['url'] = 'null'
      ..['image'] = 'ok.png';
    expect(
      SliderItemModel.fromJson(json).mediaUrl,
      'https://art-inspiration.com/storage/ok.png',
    );
  });
}
