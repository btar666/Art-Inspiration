# Art Inspiration — customer app

Flutter e-commerce app for **ART INSPIRATION / شركة الهام الفن**, a
wholesale cosmetics distributor in Karbala. Pharmacies and beauty shops
browse the catalog and place orders. Arabic-only, RTL, iPhone + iPad +
Android. Repo: gitlab.com/mobile-apps-devs/art-inspiration, `main`.

The owner does not read code. Verify in the simulator and report what you
saw, not what you expect.

## Read this first

`.cursor/rules/flutter-architecture.mdc` holds the **code conventions**
(feature-first layout, Riverpod patterns, go_router, screenutil, theme,
naming). It is `alwaysApply` and still accurate. This file holds what that
one does not: the backends, the build traps, and the release path.

`README.md` holds the developer setup. Keep all three in step.

## TWO backends, and they are not interchangeable

This is the fact that costs the most time if you miss it.

| | Aman ERP | The shop's own backend |
|---|---|---|
| base | `https://aman-erp.com/api/v1` | `https://art-inspiration.com/` |
| auth | `Authorization: Bearer <static key>` | header `token: <customer token>` |
| key lives in | `ApiSecrets.amanApiToken` (in the repo) | `AuthStorage.accessToken` (per user) |
| dio provider | `dioProvider` | `appApiDioProvider` |
| serves | products, categories, brands, stock, customers, sales_invoices | slider, featured ids, customer login/register/edit, my_account, notifications, info, policies, delete_account |
| callers | `home/data/products_repository`, `orders/data/orders_repository`, `orders/data/erp_party_resolver` | `features/app_api/data/app_api_service` |

So: **the catalog is the ERP's; the customer is the shop's.** A product
comes from Aman, the person buying it does not exist there. When a screen
needs both, it joins them in the repository, never in a widget.

`baseDioProvider` is the third, unauthenticated one. Rarely used.

## Running it

`flutter pub get && flutter run`. Nothing else. The Aman key is committed
on purpose (see decision 1), so a fresh clone runs.

- Dev login goes through art-inspiration.com — a real customer account.
  There is no dev bypass: `ErpDevConfig.enabled` is `kDebugMode && false`
  and `ErpDevSession.skipLoginToHome` returns `false`. Both are dead
  switches kept for shape. Do not "fix" them into a bypass.
- 🚩 The iOS simulator needs a booted device; `flutter run -d <udid>`.
  First run after a clean checkout takes minutes (pod install).

## iOS build traps — all three cost hours on 2026-08-27

1. 🚩 **Minimum is iOS 15.0**, forced by `firebase_core`. If you ever see
   `no versions of 'firebase-ios-sdk' match the requirement 12.17.0`,
   **the version is fine — the deployment target is too low.** Swift
   Package Manager reports a platform mismatch as a resolution failure.
   That message sent this project down a 40-minute dead end.
2. 🚩 **The build uses CocoaPods, not SwiftPM.** SwiftPM is still
   experimental in Flutter and failed here. `flutter config
   --no-enable-swift-package-manager` is a **machine-wide** setting, not a
   repo one, so a new machine has to run it. README says so.
3. 🚩 **Release uses its own entitlements file.**
   `ios/Runner/RunnerRelease.entitlements` sets `aps-environment` to
   `production`; Debug and Profile keep `development` in
   `Runner.entitlements`. App Store Connect **rejects** a build signed
   with the development value. Never point all three configs back at one
   file.

## Releasing to TestFlight

```bash
./bump_version.sh          # or patch / minor / major / x.y.z
flutter build ipa --export-method app-store
```

Then drag `build/ios/ipa/*.ipa` into Transporter.

- `pubspec.yaml`'s `version:` is the **single** source for both platforms
  (Android via `flutter.versionName/versionCode`, iOS via
  `$(FLUTTER_BUILD_NAME)/$(FLUTTER_BUILD_NUMBER)`). Nothing else in the
  app hardcodes a version, so they cannot drift. The script edits that one
  line and always increments the build number, because TestFlight refuses
  a build number it has seen.
- Signing is automatic under team `427DBVF8F9`. Xcode creates the
  Apple Distribution certificate on first archive **if an Apple ID is
  signed into Xcode → Settings → Accounts**. Without it the archive
  succeeds and the export fails.
- Before shipping, verify the IPA rather than trusting the build:
  `codesign -d --entitlements - --xml Payload/Runner.app` should show
  `aps-environment=production` and `get-task-allow=false`.
- Open and NOT done: the launch image is still Flutter's placeholder, so
  the app opens on a blank white screen. `flutter build ipa` warns about
  it every time.

## Locked decisions

1. **The Aman API key ships in the repo** (owner, 2026-08-27). It sits in
   `dart_defines.json` and `lib/core/network/api_secrets.dart`, both taken
   out of `.gitignore` so a clone runs with no setup. The owner was told
   it lives in git history permanently; that was his call. If it ever
   leaks, rotate it in the Aman ERP dashboard, edit `dart_defines.json`
   and run `dart run tool/sync_api_secrets.dart`.
   `android/upload-keystore.jks` stays **out** — a signing key is not an
   API key.
2. **Arabic is hardcoded, not localized.** `locale` is pinned to `ar` and
   the whole tree is wrapped in `Directionality(rtl)`. `supportedLocales`
   lists `en` but no English strings exist and there is no `l10n.yaml`.
   Write Arabic literals in widgets like the rest of the code. Do not
   introduce an i18n layer unless the owner asks for a second language.
3. **One font: DIN Next LT Arabic**, three weights (300/400/700).
   `AppFonts.resolveWeight` snaps any requested weight onto those three,
   so asking for w600 silently gives bold. That is intended — do not add
   faces to make a design pixel-exact.
4. **Design size is 393×852** (`AppConstants`). Every `.w/.h/.r/.sp`
   scales from it.

## Layout trap: fixed heights overflow

🚩 A screen built entirely from fixed `.h` heights **has no give**, and
`Spacer()` cannot rescue it — a Spacer only distributes space that is
left, and there is none. The onboarding page shipped 812.7 points of
content into 778 and hid its own buttons behind the overflow stripe.

The fix pattern, in `onboarding_page.dart`: a `LayoutBuilder` sums the
fixed blocks, and the one elastic block (the carousel) takes
`min(designHeight, whatIsLeft)`. Each gap is a **named local used in both
the sum and its `SizedBox`**, so the two can never drift. Widgets expose
their own height (`OnboardingActionBar.height`,
`OnboardingPageIndicator.height`) instead of the page copying numbers.

Reuse this shape rather than wrapping a screen in a scroll view — a
primary button below the fold is still a bug, even when reachable.

Measure, do not eyeball: the Flutter log prints the exact overflow, and
`0 overflowed` in a full run is the test.

## Tests

There are none, and `test/` is empty. The working check is: build → run in
the simulator in Arabic → read the log for `overflowed` and
`EXCEPTION CAUGHT` → screenshot. `flutter analyze` currently reports 87
pre-existing infos/warnings; do not treat a clean global analyze as the
bar, check the files you touched.
