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
- `ITSAppUsesNonExemptEncryption` is `false` in `Info.plist`, so App Store
  Connect stops asking the export-compliance question on every upload. The
  app ships no cryptography of its own — dio and Firebase make HTTPS calls
  and nothing else; `pubspec.yaml` carries no crypto package. Revisit that
  declaration the day the app encrypts something itself.

## The launch screen is half of the splash

The native launch screen and the Flutter splash draw the **same logo, at
the same size, in the same place**, so the handoff between them is
invisible. Measured on an iPhone 17 Pro: launch screen centre −21.7pt from
screen centre, first Flutter frame −21.3pt. The gap is 0.4pt.

Three numbers hold that together, and all three are dictated by the splash:

- **Size** — `AppAnimatedLogo(size: 80)` under the 393pt design width, so
  the storyboard sizes the image at `0.2036 × superview.width` and Android
  ships one drawable per density (80/120/160/240/320px). A fixed point size
  would be wrong on every phone that is not 393 wide.
- **Position** — the splash centres logo + brand text as ONE column, so the
  logo alone sits 21.5pt **above** screen centre. iOS spends a `centerY`
  constant of `-21.5`; Android insets the layer-list item by
  `android:bottom="43dp"`, twice the offset, because a centred bitmap moves
  up by half of what you take off the bottom.
- **No entrance animation** — `enableEntrance: false` on the splash logo.
  The logo is already on screen when Flutter takes over. Scaling it in from
  0.5 would blink it out and grow it back.

🚩 **iPhone is exact; iPad settles by 23pt.** The offset is a fixed point
value, but the splash derives its own from the window width, so the two only
agree at the 393pt design width. Measured on an iPad Pro 11 (the app opens
windowed under iPadOS 26, ~673pt wide): logo size matched exactly at 137pt,
centre was 23pt off. Left alone on purpose — iPad is a nominal platform here
and the exact fix wants a `safeArea` layout guide plus a spacer view whose
height is `0.172 × superview.width`, hand-written into a storyboard Xcode
owns, to buy 23pt on a device nobody in Karbala is using. Do it the day iPad
becomes real.

🚩 Change the splash logo's size, its 12pt gap or the brand text, and these
numbers go stale. Re-measure, do not eyeball. The check that produced them:
screenshot the launch screen and the first Flutter frame, find the bounding
box of brand blue (`#0014FF`) in each, compare the centres.

🚩 `values-night/styles.xml` inherited `Theme.Black.NoTitleBar`, so Android
in dark mode flashed a **black** window before Flutter painted white. The
app has no dark theme — `AppColors.background` is white and there is no
`darkTheme` — so both night styles are Light now.

## Android does not build on this machine

`flutter build apk` dies at configuration with `* What went wrong: 25.0.2`.
That is the JDK version, not a code error: Java 25 against Gradle 8.14,
which tops out at Java 24. It fails the same way on a clean checkout, so it
blocks nobody's change but it blocks every Android build. Fix it by
pointing Flutter at a Java 21 JDK (`flutter config --jdk-dir …`) or by
moving the wrapper to Gradle 9. Until then, validate Android resource edits
with `aapt2 compile <file> -o <dir>`, which runs in a second and catches
real XML errors.

## Home screen performance — what was measured

Numbers below are from the iOS simulator in **debug** mode with identical
injected drags before and after. Debug inflates the UI-thread (build) figures
several times over; the raster figures are GPU work and are the honest ones
for anything blur-related. Profile mode does not run on the simulator, so
none of this has been sized on a real device yet.

**The blur stack was the scroll cost.** `PinnedBlurGradientBackground` used to
stack THREE `BackdropFilter`s (sigma 44 / 24 / 8), each inside its own
`ShaderMask`, to fake a blur that fades downward — 3 blurs + 4 saveLayers per
header. The home screen mounts TWO headers (the tall one and the compact one)
and cross-fades them, so a scrolling frame paid **6 blurs and 10 saveLayers**.
It is now one blur and one saveLayer per header.

| identical drags, home screen | before | after |
|---|---|---|
| raster avg | 1.91 ms | **1.39 ms** |
| worst raster frame | 11.81 ms | **8.96 ms** |

🚩 **A `BackdropFilter` can never be cached.** It samples what is behind it,
and behind it is a scrolling list, so it re-runs every frame no matter what
`RepaintBoundary` or `const` you wrap it in. The only lever is fewer of them,
over a smaller area, at a lower sigma. Adding a second blurred overlay to a
scrolling screen doubles the cost of every frame it is visible for.

🚩 The strongest blur layer was masked to the TOP of the header — under a
gradient that is 92% opaque there. It was the most expensive layer doing the
least visible work. Check what your blur actually shows through before paying
for it.

**Rebuild costs that were also cut** (no before/after number in isolation,
they were folded into the same pass):
- `HomeHeaderOverlay` rebuilt its whole subtree — 3 blurs, 4 masks and the
  search bar with its typewriter animation — on every scroll notification.
  The visual is now the `child:` of the `ValueListenableBuilder`, so only the
  opacity and offset recompute.
- `HomePage` used `setState` to show the scroll-to-top button, which rebuilt
  `HomeContent` and therefore every catalog sliver. It is a `ValueNotifier`
  now, read by a `ValueListenableBuilder` around the button alone.
- `HomeCatalogStrips` took `catalog` as a parameter. It reads the provider
  itself now so `HomeContent` can pass `const HomeCatalogStrips()`; Dart
  canonicalises the const instance, so Flutter skips that subtree on a parent
  rebuild instead of rebuilding two image strips.

### Still open: one ~130 ms UI-thread frame per scroll session

Reproducible, warm, both before and after this pass, so it is NOT the blur.
It lands on a `HomeContent` rebuild, but the rebuild is not obviously the
cause: `HomeCatalogStrips`, `HomeFeaturedProductStrips` and `HomePromoBanner`
are all const-skipped, and only two product cards build. The suspicion is
**layout**, not build — `FrameTiming.buildDuration` covers build + layout +
paint on the UI thread, and rebuilding the `CustomScrollView` relayouts the
whole viewport; `const` skips building, never layout.

🚩 Do not chase this further from the simulator in debug. Next step is
`flutter run --profile` on a real iPhone with the DevTools timeline, which
will say whether it survives AOT and whether it is build or layout. Only then
is a refactor (splitting the one big `SliverToBoxAdapter`, or giving the strips
block a fixed height so it becomes a relayout boundary) worth its regression
risk.

🚩 `debugPrint` is **throttled**. Lines arrive late and out of order relative
to frame timings, which made an early reading of this look causal when it was
not. Use `print` when you are correlating log lines with timings.

### Two loaders were drawn behind the floating header

The home header floats over the scroll view, so anything a page centres near
the top lands underneath it.

- **Pull-to-refresh.** `RefreshIndicator` defaulted to `edgeOffset: 0`, which
  put the spinner around y=40pt — under the header's blur and above the search
  bar. `AppRefreshScrollView` takes an `edgeOffset` now and home passes
  `topInset + HomeScrollMetrics.headerRowHeight()` (~123pt), landing the
  spinner below the header. Other screens default to 0 and are unchanged.
- **The slider's own spinner.** The banner fills the whole hero, measured at
  303pt tall on an iPhone 17 Pro, so a plain `Center` put the spinner at 151pt
  — inside the header band, which ends at 160pt. `_SliderLoader` pads it down
  past the header first.

🚩 Neither spinner could be photographed: injected touch paths do not trigger
Flutter's pull-to-refresh on this simulator, and the banner image loads too
fast to catch even with the disk cache cleared. Both fixes are geometry
verified against a real screenshot (hero bottom at 303pt, header at 160pt),
not seen. Confirm them by hand on a device.

## The backend sends the STRING "null"

`api/slider` returns `"title":"null"` — four characters, not a JSON null — and
the app painted the word **null** in white over a banner image on the home
screen. Checked against the live endpoint on 2026-08-27, three of four slides
carried junk titles:

| slide | title |
|---|---|
| 11 (the blue delivery banner) | `"null"` |
| 6 | `"."` |
| 5 | `"null"` |
| 1 | `""` — correct |

`(json['title'] ?? '').toString()` catches a JSON null and nothing else.
`SliderItemModel` **already had** the right helper — `_firstNonEmpty` rejected
`'null'`, and `url` / `image` / `video` / `erp_name` / `erp_id` all used it.
Only `title` skipped it. The fix was to route `title` through the same helper
and widen it to `{'null', 'undefined'}`, case-insensitively. `test/
slider_item_model_test.dart` pins it — reverting the one-line change makes it
fail with `Expected: '' Actual: 'null'`.

🚩 **Scope, measured before widening it.** The same defect class exists in
other parsers (`ErpProductMapper` line 49 turns a `"description": "null"` into
a product subtitle because `"null".isEmpty` is false; the offline catalog
snapshot re-reads category and brand lists with a bare `e.toString()`). None
of it was fixed, because none of it is real today: 400 sampled ERP products,
152 brands, 38 categories and the shop's own categories/brands/info/policy
endpoints are all clean. The junk lives only in **staff-entered slider
content**, where a blank admin form field is submitted as the string "null".
Add the guards there if that ever changes — do not pre-emptively sprinkle them.

The check, in one command:

```bash
curl -s https://art-inspiration.com/api/slider | grep -o '"title":"[^"]*"'
```

🚩 The `"."` title on slide 6 is the same symptom and is NOT fixed — it is a
human placeholder, not a machine one, and stripping punctuation-only titles is
a judgement call for the owner, not a parser rule. The real repair for both is
on the backend: stop writing a blank title as text.

### `api/privacy_policy` returns an empty list

Noticed while checking the other endpoints, not fixed: `{"data":[]}`. The
privacy-policy screen therefore has nothing to show, and the App Store
requires a reachable privacy policy. Worth resolving before the next
submission.

## Open decisions, waiting on the owner (2026-08-27)

Three questions were put to the owner at the end of the 2026-08-27 session and
are NOT answered. Do not decide them alone.

1. **Three more placeholder holes.** A 40-agent audit found `"null"` could
   reach the screen through `ReturnPolicyItem.title` (which renders inside the
   checkout consent checkbox — `أقر بأنني قرأت «null» وأوافق عليها` on the box
   a customer must tick to order), `ReturnPolicyItem.details`, and
   `AppInfoModel.about`. Both endpoints are CLEAN today, checked live. But the
   app already carries this defence elsewhere (`app_api_service.dart:339`
   strips `'#'` and `'null'`; `contact_us_page.dart:71,81` strip `'#'`), so
   these are holes in an existing pattern, not speculation. Recommended: patch
   all three through one shared helper, ~10 lines.
2. **The `"."` slide title.** Slide 6 of `api/slider` has `"title":"."`, which
   paints a stray dot on the banner. Left alone: a punctuation-only title is a
   human placeholder, and stripping it is a product decision, not a parser rule.
3. **Nothing from that session was committed.** The working tree carries the
   launch screen, the export-compliance key, the home-screen performance pass
   and the slider fix.

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

There is exactly one: `test/slider_item_model_test.dart`, which pins the
"backend sends the string null" bug described above. It was added because a
screenshot only proves today's data — the test proves the parser. The working check is: build → run in
the simulator in Arabic → read the log for `overflowed` and
`EXCEPTION CAUGHT` → screenshot. `flutter analyze` currently reports 87
pre-existing infos/warnings; do not treat a clean global analyze as the
bar, check the files you touched.
