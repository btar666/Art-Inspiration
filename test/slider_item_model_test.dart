import 'package:flutter_test/flutter_test.dart';

import 'package:art_inspiration_app/features/app_api/models/slider_item_model.dart';

/// شريحة سلايدر حقيقية من api/slider يوم 2026-08-27 — لاحظ "null" كنص
Map<String, dynamic> _slide() => {
      'id': 11,
      'image': 'JaSThcfGXPdyG5En_1787654400.png',
      'type': 1,
      'erp_type': 'brand',
      'erp_id': null,
      'erp_name': null,
      'url': 'https://art-inspiration.com/storage/JaSThcfGXPdyG5En_1787654400.png',
    };

void main() {
  test('رابط الوسائط يتجاهل النص النائب ويسقط إلى الحقل التالي', () {
    final json = _slide()
      ..['url'] = 'null'
      ..['image'] = 'ok.png';
    expect(
      SliderItemModel.fromJson(json).mediaUrl,
      'https://art-inspiration.com/storage/ok.png',
    );
  });

  test('اسم الربط النائب لا يجعل الشريحة قابلة للضغط', () {
    // erp_name = "null" مع erp_id فارغ: لا وجهة حقيقية، فلا رابط
    final junk = _slide()..['erp_name'] = 'null';
    expect(SliderItemModel.fromJson(junk).hasLink, isFalse);

    final real = _slide()..['erp_name'] = 'Eucerin';
    expect(SliderItemModel.fromJson(real).hasLink, isTrue);
  });
}
