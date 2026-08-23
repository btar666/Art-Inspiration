// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// ينسخ AMAN_API_TOKEN من dart_defines.json إلى api_secrets.dart
/// حتى يعمل `flutter build apk` بدون --dart-define-from-file.
///
/// الاستخدام (مرة بعد clone أو عند تغيير التوكن):
///   dart run tool/sync_api_secrets.dart
void main() {
  final root = Directory.current;
  if (!File('${root.path}/pubspec.yaml').existsSync()) {
    stderr.writeln('شغّل الأمر من جذر المشروع.');
    exit(1);
  }

  final definesFile = File('${root.path}/dart_defines.json');
  String? token;

  if (definesFile.existsSync()) {
    final raw = definesFile.readAsStringSync();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      stderr.writeln('dart_defines.json يجب أن يكون كائن JSON.');
      exit(1);
    }
    final value = decoded['AMAN_API_TOKEN'];
    if (value is String && value.trim().isNotEmpty) {
      token = value.trim();
    }
  }

  token ??= Platform.environment['AMAN_API_TOKEN']?.trim();
  if (token == null || token.isEmpty) {
    stderr.writeln(
      'AMAN_API_TOKEN غير متوفر.\n'
      'ضعه في dart_defines.json أو متغير البيئة AMAN_API_TOKEN.',
    );
    exit(1);
  }

  const targetPath = 'lib/core/network/api_secrets.dart';
  final content = '''
/// مُولَّد تلقائياً — لا تعدّل يدوياً.
/// المصدر: dart_defines.json عبر `dart run tool/sync_api_secrets.dart`
abstract final class ApiSecrets {
  static const amanApiToken = ${_dartStringLiteral(token)};
}
''';

  File('${root.path}/$targetPath').writeAsStringSync(content);
  print('تم تحديث $targetPath');
}

String _dartStringLiteral(String value) {
  final buffer = StringBuffer("'");
  for (final codeUnit in value.codeUnits) {
    switch (codeUnit) {
      case 0x27: // '
        buffer.write(r"\'");
      case 0x5c: // \
        buffer.write(r'\\');
      case 0x0a:
        buffer.write(r'\n');
      case 0x0d:
        buffer.write(r'\r');
      case 0x09:
        buffer.write(r'\t');
      default:
        if (codeUnit < 0x20) {
          buffer.write('\\u${codeUnit.toRadixString(16).padLeft(4, '0')}');
        } else {
          buffer.writeCharCode(codeUnit);
        }
    }
  }
  buffer.write("'");
  return buffer.toString();
}
