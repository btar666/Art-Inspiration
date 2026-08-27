# Art Inspiration

تطبيق التجارة الإلكترونية لشركة الهام الفن. Flutter + Riverpod + go_router،
يقرأ الكتالوج والطلبات من أمان ERP.

## التشغيل بعد clone

```bash
flutter pub get
flutter run
```

مفتاح أمان ERP مرفوع مع المشروع في `dart_defines.json` و
`lib/core/network/api_secrets.dart`، فلا حاجة لإعداد قبل التشغيل.
عند تغيير المفتاح، عدّل `dart_defines.json` ثم:

```bash
dart run tool/sync_api_secrets.dart
```

## رفع رقم النسخة

`pubspec.yaml` هو المصدر الوحيد — أندرويد و iOS يقرآن منه، فالرقمان
لا يفترقان أبداً. رقم البناء يزيد في كل مرة لأن TestFlight يرفض
رقماً مستعملاً:

```bash
./bump_version.sh          # 1.0.1+2 → 1.0.1+3
./bump_version.sh patch    # 1.0.1+2 → 1.0.2+3
./bump_version.sh minor    # 1.0.1+2 → 1.1.0+3
./bump_version.sh major    # 1.0.1+2 → 2.0.0+3
./bump_version.sh 2.5.0    # 1.0.1+2 → 2.5.0+3
./bump_version.sh --selftest
```

## iOS

الحد الأدنى **iOS 15.0**، يفرضه firebase_core. البناء يمر عبر
**CocoaPods** لا Swift Package Manager. إذا فشل البناء عندك برسالة
`no versions of firebase-ios-sdk match`، فأنت على SPM:

```bash
flutter config --no-enable-swift-package-manager
```

## ما يبقى خارج المستودع

`android/upload-keystore.jks` ومعه كلمات المرور في
`android/key.properties`. اطلبها من مالك المشروع عند بناء نسخة للنشر.
