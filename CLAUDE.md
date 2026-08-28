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

## Android builds again — two faults, one hiding the other

`flutter build apk` used to die at configuration with `* What went wrong:
25.0.2`. That was the JDK: Java 25 against Gradle 8.14, which tops out at 24.
Homebrew's `openjdk` and Android Studio's bundled JBR were **both** 25, so
there was nothing to fall back to.

Fixed by installing a supported JDK and pointing Flutter at it. AGP 8.11
requires 17+, so 21 is the comfortable choice:

```bash
brew install openjdk@21
flutter config --jdk-dir /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
```

🚩 That setting is **machine-wide, not repo-wide**, like the CocoaPods one
above. A new machine has to run it.

Clearing the JDK error exposed a second failure that had been invisible behind
it — `:app:mergeDebugResources` → `drawable-mdpi 80: Error: Invalid resource
directory name`. Five empty directories with a space in the name
(`drawable-mdpi 80`, `drawable-hdpi 120`, `drawable-xhdpi 160`,
`drawable-xxhdpi 240`, `drawable-xxxhdpi 320`) sat next to the real ones, left
by a shell loop during the launch-screen work that read `mdpi 80` as one
argument. Git does not track empty directories, so they never appeared in
`git status` and never reached anyone else's clone. Deleted.

🚩 The older note here said Android "fails the same way on a clean checkout".
That was true of the JDK and false of the directories. If an Android build
fails on one machine only, look for untracked local junk before blaming the
config.

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

🚩 **The tall home header no longer draws a band at all** (owner, 2026-08-28).
He asked for the frosted strip above the slider to go. Removing only the blur
changed nothing on screen — it sat under a gradient that is 92% opaque, the same
trap as the masked layer above — so the whole `PinnedBlurGradientBackground` is
gone from `home_header_overlay.dart`. Two things replaced it, because the band
was carrying contrast, not decoration:

- The bell is blue and vanished over the blue slide, so it now sits on a white
  circle in `HomeSearchBar`, matching the search pill beside it.
- The system clock is white and vanished over the pale slides, so a 32%
  black-to-transparent scrim covers the status-bar strip **only**
  (`height: topInset`). Photographed on all four slides.

The **compact** header keeps its blur. It floats over a scrolling list and has
no artwork of its own to show off.

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

### The banner was cropped on iPhone and not on Android

Reported by the owner and confirmed on an iPhone 17 Pro simulator: the home
banner lost words off both sides. `منتجات` read `تجات`; `تليق بزبائنك` read `يق بزبائنك`.

Every slider image is about **1.67:1** (786×470, 884×529, 1032×617 on
2026-08-27). The hero is full-screen wide and `topInset + headerRowHeight() +
175.h` tall, so `topInset` — the notch — is the only term that differs between
platforms, and it decides how much `BoxFit.cover` throws away:

| | hero box | aspect | of the image width `cover` keeps |
|---|---|---|---|
| iPhone 17 Pro (402×874, inset 62) | 402×303 | 1.33 | **79%** |
| a 412×892 Android (inset 24) | 412×270 | 1.53 | **91%** |

Nine percent off the edges clears the text. Twenty-one percent does not. Same
code, same images, different notch.

The banner now draws **twice**: `cover` behind, `fitWidth` with
`Alignment.bottomCenter` in front. The front copy is the one the customer
reads — full width, no crop, on any device. The back copy exists only for the
strip above it, because `fitWidth` leaves `heroHeight − width/aspect` unpainted
and a flat `homeBannerBg` there put the white system clock on `#E8EBFF`. The
seam was measured at exactly **63.0pt** down the right-hand column, matching
303 − 402/1.672 to a tenth of a point. All four slides were then photographed
whole.

### The banner box is 12:11, and the artwork must match it

The owner saw the `cover` copy the day the header band came off and called it
"mirroring" (2026-08-28). He was right — it is the same artwork, zoomed, and on
a symmetric sunburst the top strip reads as a reflection. The band had been
hiding it. Then he asked for the banner to be **taller**, and for the exact
export size to hand his designer.

Both answers are the same number. `HomeScrollMetrics.heroHeight` now returns
`screenWidth / bannerAspect` with `bannerAspect = 12 / 11`, so:

- the box takes its height from the **width alone** — same shape on every phone,
  which is what killed the old iPhone-crops-Android-doesn't bug at the root: the
  notch no longer decides the box ratio;
- artwork exported at **1200 × 1100 px** fills it exactly — no crop, no strip,
  and the `cover` copy is deleted;
- 368pt tall on an iPhone 17 Pro, 42% of the screen, which is what the owner
  drew on his screenshot.

`heroMaxScreenFraction = 0.46` caps it, because `width / aspect` on a short
360×640 phone is 52% of the screen. Above the cap the top of the image is cut —
the strip the floating header covers anyway.

🚩 **Today's four banners are still 1.67:1 and do NOT fill the new box.**
`fitWidth` + `bottomCenter` puts the shortfall at the top: measured 6pt of bare
`homeBannerBg` above the artwork on an iPhone 17 Pro, because the header covers
123.5 of the 128pt gap. On a small-notch Android the same arithmetic leaves
about 46pt visible. It closes itself the day the new slides are uploaded.

🚩 The safe zone the designer was given, as fractions of the image so they
survive a resize: **top 35%** is under the status bar and the floating search
row (33.5% on the worst device, plus the short-phone crop); **bottom 80px of
1100** holds the page dots. Sides are never cropped.

🚩 `sliderVisualHeight` and `logoHideStartOffset` derive from the hero, so the
header still starts fading when the categories reach it. All three take
`(topInset, Size screen)`.

🚩 The video path still uses `FittedBox(BoxFit.cover)` and still crops.
Left alone on purpose: `api/slider` serves four images and no video today, and
a letterboxed video is a worse default than a cropped one.

🚩 `memCacheHeight` was removed and must not come back. Passing it
alongside `memCacheWidth` decodes to both numbers literally, without preserving
the aspect ratio — `ResizeImagePolicy.exact`, which is `BoxFit.fill`. Today's
images are smaller than the target so both values clamp back to the original
size and the bug never fires; a banner larger than the screen would have been
squashed. Width alone always keeps the ratio.

## The backend sends the STRING "null"

`api/slider` returns `"title":"null"` — four characters, not a JSON null — and
the app painted the word **null** in white over a banner image on the home
screen. `(json['title'] ?? '').toString()` catches a JSON null and nothing
else, so the word reached the screen. `SliderItemModel` **already had** the
right helper: `_firstNonEmpty` rejected `'null'`, and `url` / `image` /
`video` / `erp_name` / `erp_id` all used it. Only `title` skipped it.

### The slide title is gone, and that is the fix

The title field was watched for one day and served junk every time:

| slide | morning | evening |
|---|---|---|
| 11 (GUARANTEED) | `"null"` | `"null"` |
| 6 (the app promo) | `"."` | `"العنوان"` |
| 5 (delivery) | `"null"` | `"null"` |
| 1 (الاكثر مبيعاً) | `""` | `""` |

Three shapes of junk in one day: a machine placeholder, a typed dot, and the
field's own label typed into the field. A parser guard caught the first, a
punctuation rule caught the second, and nothing catches the third — `العنوان`
is a real Arabic word.

So the owner's call (2026-08-27) was to **stop drawing the title at all**. The
`Positioned` `Text` is deleted from `_SliderSlide`, and with it the `title`
field on `SliderItemModel`; the overlay was its only reader. Every banner is a
finished piece of artwork with its own headline baked in — the app was painting
white text on top of somebody else's design, and that is what produced three
separate bugs.

🚩 Do not add it back to make an admin field "work". If a title is ever wanted,
it is a design change to the banner, not a `Text` over the image.

`_firstNonEmpty` and `_placeholderTexts` stay — they still guard `url`,
`image`, `video` and `erp_name`, which is what
`test/slider_item_model_test.dart` now pins.

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

The real repair on the backend is still worth having: stop writing a blank
title as the text "null". It just no longer reaches a customer.

### The privacy policy now has its own screen, and it still says "Test"

Two separate problems, one fixed and one not.

**Fixed: it had no reachable screen, and the parser read the wrong key.**
`fetchPrivacyPolicy` looked for `content` / `text` / `body`; the endpoint sends
**`details`**, so the call returned `''` no matter what staff typed. The only
thing that rendered it was `_PrivacyPolicySection` at the bottom of
`HelpPage` — and nothing in the app navigates to `HelpPage`, so the policy was
unreachable twice over.

`api/privacy_policy` and `api/return_policy` return the same shape,
`data: [{id, title, details}]`, so both now go through one `_fetchPolicies`
helper and `ReturnPolicyItem`, which already reads `details`, strips HTML and
rejects placeholder text. `privacyPolicyProvider` is a
`List<ReturnPolicyItem>`; the dead section in `HelpPage` was deleted rather
than ported. `PrivacyPolicyPage` is a settings menu item under «عن التطبيق»,
with `assets/images/privacy.png` — a lock glyph drawn onto the same badge the
other settings icons use, so it matches without a hand-made asset.

Verified on the simulator: three sections rendered with their titles, HTML
gone, paragraph breaks kept, no overflow and no exception.

**Not fixed: the content is placeholder prose.** The endpoint served
`{"data":[]}` in the morning, `title: "test"` at midday, and three rows titled
`Test 1/2/3` holding a short story about a lamp by evening. Someone is editing
it live. None of it is a privacy policy, and the App Store requires a real one,
so this still blocks submission. Backend content, not app code.

### The other three placeholder holes are closed

`"null"` could also reach the screen through `ReturnPolicyItem.title` (which
renders inside the checkout consent checkbox — `أقر بأنني قرأت «null» وأوافق
عليها` on the box a customer must tick before ordering),
`ReturnPolicyItem.details` and `AppInfoModel.about`. All three now go through
`cleanText` in `lib/core/utils/placeholder_text.dart`, which rejects `null`,
`undefined` and `#`, case-insensitively.

`api/return_policy` is clean today. `api/info` is not: `"about"` is `"<br>"`,
which the about page was already stripping to empty and replacing with its
hardcoded fallback. The guard matters the day a staff member leaves that field
blank and the backend writes the string.

`test/placeholder_text_test.dart` pins it — reverting the `title` line makes it
fail with `Expected: '' Actual: 'null'`. Verified.

🚩 The older copies of this guard were left alone. `_firstNonEmpty` is
duplicated in `slider_item_model`, `erp_media_url`, `erp_product_fields` and
`erp_order_mapper`; they work, and rewriting four parsers to share one helper
buys nothing today.

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

## The product page and the number pad

Three separate reports about the same screen, 2026-08-28.

**The number pad had no exit.** The quantity field asks for
`TextInputType.number`, and iOS draws that as a bare 0-9 pad — no return key,
no Done. `onSubmitted` therefore never fires, so once the pad was up the only
way out was to leave the screen. It now closes on `onTapOutside`, which routes
through `_onFocusChange` → `commitIfEditing`, so the typed quantity is kept.

**The add-to-cart button sat under the pad.** `_PriceQuantityBar` rode up on
`MediaQuery.viewInsetsOf`, `_AddToCartBar` did not — so the customer typed a
quantity and then could not reach the button that uses it. Both rows now come
from `addToCartBottom`, which swaps the safe-area inset for the keyboard inset,
and `priceRowBottom` is defined in terms of it, so the two can never drift
apart again.

**Swipe-back worked from one edge only.** Flutter's `CupertinoPageRoute` puts
its back-gesture strip on the *start* edge — in this RTL app the **right** —
and makes it 20pt wide. Measured on an iPhone 17 Pro: a drag from x=396 went
back, a drag from x=6 did nothing. Correct iOS behaviour for Arabic, but the
habit of swiping from the left is real, so the owner asked for both
(2026-08-28). `_LeftEdgeBack` in `app_swipe_page.dart` adds a matching 20pt
strip on the physical left. It pops on drag end rather than tracking the finger
— reimplementing Flutter's interactive `_CupertinoBackGestureDetector` is ~150
lines of framework internals for an edge most users reach by habit, not by
feel. `HitTestBehavior.translucent` lets taps through, and the wrapping `Stack`
uses `StackFit.expand` so the page still gets the tight constraints a route
child normally has. Both edges verified by screenshot.

🚩 **The simulator will not show the software keyboard**, so neither keyboard
fix could be photographed. `test/product_details_bottom_bar_metrics_test.dart`
pins the geometry instead: reverting `addToCartBottom` fails it with
`Expected: a value greater than <291.0> Actual: <45.2>` — the button 45pt up
the screen with a 291pt keyboard over it.

The toggle lives in the Simulator app's I/O → Keyboard → Connect Hardware
Keyboard (⌘K), and it is written to
`~/Library/Preferences/com.apple.iphonesimulator.plist` under
`DevicePreferences:<UDID>:ConnectHardwareKeyboard`. Setting it while the
Simulator is **running** is useless — the app overwrites the file on quit. Set
it with the Simulator closed and it survives, though on iOS 26 the pad still
did not appear here. `osascript` cannot send ⌘K without Accessibility
permission. Confirm both fixes by hand on a device.

## The Arabic keyboard types ٠١٢٣, and nothing read it

An Arabic keyboard produces Arabic-Indic digits (U+0660–0669), and Persian
layouts produce the extended set (U+06F0–06F9). Neither is a digit to Dart:
`int.parse('٢٥')` throws, and the backend stores the characters verbatim. The
quantity field was worse than that — `FilteringTextInputFormatter.digitsOnly`
denies everything outside `[0-9]`, so an Arabic digit was **deleted as it was
typed**. The customer pressed ٢٥ and watched the field stay empty.

`lib/core/utils/arabic_digits.dart` holds one converter and one formatter:

- `toEnglishDigits` — 20 `replaceAll` passes over a short string. Boring on
  purpose; a `codeUnit & 0xF` trick works for both ranges and reads as noise.
- `ArabicDigitsInputFormatter` — runs the converter on every keystroke. The
  conversion is one code unit for one code unit, so the caret needs no fixing.
- `phoneInputFormatters` — the converter, then `digitsOnly`, then
  `LengthLimitingTextInputFormatter(11)`.

🚩 **Order is the whole fix.** `digitsOnly` must run *after* the converter. Put
it first and it strips the Arabic digits before anything can convert them —
which is the original bug, restored.

Applied to the four phone fields (register, checkout ×2, edit profile), the
login field (email *or* phone, so conversion only — no `digitsOnly`, no length
cap), and the product quantity field. `AppTextField` gained an
`inputFormatters` parameter to carry them.

Phone fields now take **11 digits and no more**, matching the `^07\d{9}$` that
`register_page` already validated against.

### Both behaviours were photographed on the simulator

Typing Arabic digits is impossible here — there is no software keyboard (see
the number-pad section), and the injected-text path drops anything outside
printable ASCII. The pasteboard gets around both:

```bash
printf '٠٧٧٠١٢٣٤٥٦٧٨٩' | LANG=en_US.UTF-8 xcrun simctl pbcopy <udid>
```

🚩 `LANG` is not optional. Without it `simctl pbcopy` decodes stdin as
**MacRoman**, and ٢٥ lands on the pasteboard as `Ÿ¢Ÿ•`. That looks exactly like
a broken formatter — the field rejects the junk and stays unchanged — and cost
half an hour of chasing the wrong thing.

Then long-press the field and tap Paste:

| field | pasted | shown |
|---|---|---|
| product quantity (held `1`) | `٢٥` | **125** |
| checkout second phone (empty) | `٠٧٧٠١٢٣٤٥٦٧٨٩` (13) | **07701234567** |

The second row is both halves at once: converted, and truncated to 11.

`test/arabic_digits_test.dart` pins the converter, the phone chain and the
quantity chain by feeding characters through `formatEditUpdate` one at a time.

## The ERP customer had no address, and could never get one

Reported 2026-08-28: a user registered in the app, ordered, and the customer
record in Aman ERP had `address: null`. The ERP schema does carry the field —
`GET /customers/202` returns `name`, `phone`, `email`, `address`, `notes` — and
the app knew the address the whole time. It just never sent it.

Two faults stacked:

1. `_createCustomer` posted `name`, `phone`, `type`, `price_policy`,
   `is_active`. No `address` key at all.
2. **The customer is created at login, not at checkout.** `fetchPricePolicy`
   calls `resolve` with `createIfMissing` defaulting to true, and
   `_enrichUserFromErp` / `syncPricePolicyFromErp` run it on login, app start
   and pull-to-refresh — long before the customer picks a delivery address.
   From then on `resolve` returns early from the stored `id_erp`, so
   `_createCustomer` is never reached again.

So fixing only the create path would have fixed nothing for any real account.
`ErpPartyResolver.syncAddress` now runs from `createInvoice` **after** the
invoice is created, and PATCHes `address` only when the ERP record has none —
a staff member may have corrected it there. `_createCustomer` sends it too, for
the rarer case where the first ERP contact really is the order.

The address is `draft.selectedAddress?.fullAddress`, falling back to the user's
`city` — registration collects the governorate and nothing finer, so that is
the best available for a pickup-at-company order.

🚩 The sync is wrapped in `try/catch` and runs after the invoice on purpose.
Recording an address is an administrative convenience; it must never drop an
order.

🚩 **Not verified end to end.** Confirming it means placing a real order, which
writes a real sales invoice into the owner's live ERP. `PATCH /customers/{id}`
was confirmed available (`Allow: GET,HEAD,PUT,PATCH,DELETE`) and a bodyless
PATCH left customer 202 untouched, `updated_at` unchanged. Everything past that
is code review. Place one test order and check the customer record.

## Why push never arrived on a real iPhone

The iOS setup is correct and was not the problem: `aps-environment` is
`development` in `Runner.entitlements` and `production` in
`RunnerRelease.entitlements`, both wired per build config;
`UIBackgroundModes` has `remote-notification`; `GoogleService-Info.plist` is in
the Resources build phase and its `BUNDLE_ID` matches `com.artinspiration.app`.

The bug is in `PushNotifications.initialize`. It called

```dart
final token = await messaging.getToken();
```

with no `try`/`catch`, and before any APNs token existed. On a real device the
APNs token arrives asynchronously after registration with Apple, and `getToken`
throws `apns-token-not-set` until it does. That threw out of `initialize()` at
that line — **before `subscribeToTopic('notification-public')`**.

That is fatal here, because **the app sends its FCM token to no backend at
all**; it only `debugPrint`s it. Every notification this app receives comes
through that one topic. No subscription, no notifications. And `_initialized`
is set true at the top of the method, so nothing retries for the rest of the
session.

The simulator returns an APNs token immediately, which is exactly why it looked
healthy there and dead on a phone.

`_awaitApnsToken` now polls `getAPNSToken()` ten times at 500 ms on iOS before
`getToken` runs, `getToken` is wrapped, and the topic subscription no longer
depends on it.

That fix was correct and is not the whole story. The app half now works and
was measured working on 2026-08-28: the simulator logs `FCM token: …` and
`FCM subscribed to topic: notification-public`.

### The real cause: Firebase cannot authenticate with Apple

Sending one FCM v1 message to that live token returns, verbatim:

```json
{"error":{"code":401,"message":"Invalid APNs credential.",
 "status":"UNAUTHENTICATED",
 "details":[{"errorCode":"THIRD_PARTY_AUTH_ERROR"}]}}
```

`THIRD_PARTY_AUTH_ERROR` is FCM saying it has no working APNs key for this app.
Nothing in the repo can fix it — the key is uploaded in the Firebase console.

🚩 **The project holds TWO iOS apps, and the APNs setup went to the wrong
one.** `GET /v1beta1/projects/art-inspiration-6d593/iosApps`:

| displayName | bundleId | teamId |
|---|---|---|
| `artinspiration` ← **the shipped app** | `com.artinspiration.app` | **absent** |
| `art_inspiration_app (ios)` | `com.example.artInspirationApp` | `427DBVF8F9` |

The `com.example…` pair is `flutter create` scaffolding from before the bundle
was renamed. It carries the Team ID; the real app carries none. There is a
matching junk Android app (`com.example.art_inspiration_app`). Android never
noticed because Android does not go through APNs — which is exactly why this
reads as "iOS-only".

**Fixed the same day.** The owner uploaded the APNs Authentication Key (`.p8`
from developer.apple.com → Keys) onto the **`artinspiration`** app under
Project settings → Cloud Messaging → Apple app configuration, with its Key ID
and Team ID `427DBVF8F9`. `iosApps` now reports `teamId` on both entries, and
the same curl to the same token returns
`projects/art-inspiration-6d593/messages/7579edd7-…` instead of the 401.
Nothing in the app changed between the two replies.

⚠️ The two `com.example…` apps (one iOS, one Android) are still ACTIVE. They
are the trap that caused this: the next person to configure push can pick the
wrong row again. Delete them when convenient.

🚩 The APNs credential cannot be read or written through the Firebase
Management API — `iosApps` exposes `teamId` and nothing about keys. Do not go
looking for an API for it. The retest is scriptable, though, and is the only
honest proof the upload worked:

```bash
# 1. read the token the app logs on launch
flutter run -d <udid> | grep "FCM token:"
# 2. send to THAT TOKEN ONLY — never to the topic, it reaches every customer
curl -s -X POST "https://fcm.googleapis.com/v1/projects/art-inspiration-6d593/messages:send" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{"message":{"token":"<token>","notification":{"title":"اختبار","body":"فحص"}}}'
```

A `name: projects/…/messages/…` reply means Apple accepted it.

🚩 An Apple Silicon simulator gets a real APNs token and a real FCM token,
so it reproduces this end to end. The old note here said push could not be
tested without a phone. It can.

## Page pushes use Cupertino's own timing again

The owner called the product-page open-and-back "messy" (2026-08-28).
`_FastCupertinoPageRoute` was overriding the push at **180ms** forward and
160ms back. `CupertinoPageRoute.kTransitionDuration` is **500ms**. The slide,
the parallax on the page behind it, and the shadow down its leading edge were
all being crushed into a third of the time they are designed for, which reads
as a jump rather than a transition. The overrides are gone; the route uses its
own duration.

🚩 `AppPageTransition` (180/160) still exists and is still correct — it drives
the **fade between bottom-nav tabs**, where a switch should feel instant. Do
not "unify" the two: a tab change and a page push are different gestures with
different expectations.

## The consent checkboxes now come to the customer

Reported 2026-08-28: with a long order, tapping «تأكيد الطلب» only showed a red
snack bar. The two policy consents sit at the very bottom, and the customer had
no idea where to look.

`revealPending()` in `checkout_policy_sections.dart` replaces
`openPendingPolicies()`: it expands every un-accepted card, scrolls the **first**
un-accepted one to the top of the viewport (`Scrollable.ensureVisible`), then
pulses a blue halo around it — `_GlowRing`, one `AnimationController` and
`(1 - cos(v·6π)) / 2 · (1 - 0.45v)`, three soft pulses that fade out. The child
is the `AnimatedBuilder`'s `child:`, so only the halo repaints.

🚩 **The old call did nothing at all, and the lazy `ListView` was why.** Policy
cards are the list's LAST child, so at the top of the page they are not built —
`GlobalKey.currentState` is null and the tap fell through to the snack bar
alone. Scrolling first exposed a second fault: **`maxScrollExtent` is an
estimate** while children are unbuilt, and it does not grow when a card expands,
so `ensureVisible` clamped to the stale value and refused to move
(`px=609 max=609 delta=525`, measured). The page uses a
`SingleChildScrollView` + `Column` now. Nothing is lost: all order lines already
lived inside ONE `_InfoCard`, so the laziness never applied to them.

🚩 A `GlobalKey` into a lazily-built list is null until the target scrolls into
range. Do not reach into one from a button that lives somewhere else.

Verified on an iPhone 17 Pro from a cold start: one tap moved the page from the
top to the first policy card, both cards open, checkbox on screen. The halo was
photographed by pinning the pulse at 1.0 — at real speed it is 1.6s and a
screenshot cannot catch it.

## Tests

There are two, and both pin the "backend sends the string null" bug described
above: `test/slider_item_model_test.dart` for the slide's media url and link
name, and `test/placeholder_text_test.dart` for the return-policy and about-us
text. They exist because a screenshot only proves today's data — a test proves
the parser. The working check is: build → run in
the simulator in Arabic → read the log for `overflowed` and
`EXCEPTION CAUGHT` → screenshot. `flutter analyze` reports 7 pre-existing
infos (four `cacheExtent` deprecations, two getter/setter style notes, one
async-gap context) and zero errors.

🚩 If it ever reports errors again, read the file paths first. On
2026-08-28 the IDE refused to launch with «Errors exist in your project» and
all 79 errors were in `build/ios/SourcePackages/firebase_messaging-16.5.0/` —
the plugin's own example app and tests, importing a `firebase_options.dart`
and a `mockito` this repo does not have. A stale SwiftPM checkout from the
abandoned SwiftPM attempt; the build uses CocoaPods, so `rm -rf
build/ios/SourcePackages` (268 MB) fixed it and it does not come back.
