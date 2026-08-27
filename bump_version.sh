#!/usr/bin/env bash
# يرفع رقم النسخة في pubspec.yaml — وهو المصدر الوحيد للأندرويد و iOS معاً.
#   أندرويد: flutter.versionName / flutter.versionCode (android/app/build.gradle.kts)
#   iOS:     $(FLUTTER_BUILD_NAME) / $(FLUTTER_BUILD_NUMBER) (ios/Runner/Info.plist)
#
#   ./bump_version.sh          1.0.1+2 → 1.0.1+3   (رقم البناء فقط)
#   ./bump_version.sh patch    1.0.1+2 → 1.0.2+3
#   ./bump_version.sh minor    1.0.1+2 → 1.1.0+3
#   ./bump_version.sh major    1.0.1+2 → 2.0.0+3
#   ./bump_version.sh 2.5.0    1.0.1+2 → 2.5.0+3
#
# رقم البناء يزيد دائماً — TestFlight يرفض رقم بناء مستعملاً من قبل.

set -euo pipefail

# "1.0.1+2" + mode → "1.0.2+3"
next_version() {
  local current="$1" mode="${2:-build}"
  local name="${current%%+*}" build="${current##*+}"

  [[ "$name" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "صيغة النسخة غير صحيحة: $name" >&2; return 1; }
  [[ "$build" =~ ^[0-9]+$ ]] || { echo "رقم البناء غير صحيح: $build" >&2; return 1; }

  local major="${name%%.*}" rest="${name#*.}"
  local minor="${rest%%.*}" patch="${rest#*.}"

  case "$mode" in
    build) ;;
    patch) patch=$((patch + 1)) ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    major) major=$((major + 1)); minor=0; patch=0 ;;
    [0-9]*.[0-9]*.[0-9]*)
      [[ "$mode" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "نسخة غير صحيحة: $mode" >&2; return 1; }
      major="${mode%%.*}"; rest="${mode#*.}"; minor="${rest%%.*}"; patch="${rest#*.}" ;;
    *) echo "خيار غير معروف: $mode (استعمل build/patch/minor/major أو x.y.z)" >&2; return 1 ;;
  esac

  echo "${major}.${minor}.${patch}+$((build + 1))"
}

selftest() {
  local fails=0
  check() {
    local got; got="$(next_version "$1" "$2")"
    [[ "$got" == "$3" ]] && echo "ok   $1 $2 → $got" || { echo "FAIL $1 $2 → $got (متوقع $3)"; fails=1; }
  }
  check 1.0.1+2 ""      1.0.1+3
  check 1.0.1+2 build   1.0.1+3
  check 1.0.1+2 patch   1.0.2+3
  check 1.0.1+2 minor   1.1.0+3
  check 1.0.1+2 major   2.0.0+3
  check 1.0.1+2 2.5.0   2.5.0+3
  check 9.9.9+99 patch  9.9.10+100
  next_version "1.0+2" build 2>/dev/null && { echo "FAIL: قبل نسخة ناقصة"; fails=1; } || echo "ok   رفض 1.0+2"
  next_version "1.0.1+x" build 2>/dev/null && { echo "FAIL: قبل رقم بناء غير رقمي"; fails=1; } || echo "ok   رفض 1.0.1+x"
  exit $fails
}

[[ "${1:-}" == "--selftest" ]] && selftest

cd "$(dirname "$0")"
[[ -f pubspec.yaml ]] || { echo "pubspec.yaml غير موجود" >&2; exit 1; }

current="$(sed -n 's/^version: *//p' pubspec.yaml | head -1)"
[[ -n "$current" ]] || { echo "لا يوجد سطر version في pubspec.yaml" >&2; exit 1; }

new="$(next_version "$current" "${1:-build}")"

# ملف مؤقت بدل sed -i، فيعمل على macOS و Linux معاً.
tmp="$(mktemp)"
sed "s/^version: .*/version: ${new}/" pubspec.yaml > "$tmp" && mv "$tmp" pubspec.yaml

echo "pubspec.yaml: ${current} → ${new}"
echo "أندرويد و iOS يقرآن هذا السطر، فالرقمان متطابقان."
