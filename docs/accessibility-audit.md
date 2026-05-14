# Accessibility Audit Results

A structured record of the manual accessibility validation carried out for the iOSDevUK Accessibility Challenge 2026 submission. Code-side improvements are documented in the main [`README.md`](../README.md); this file captures the on-device verification.

**Device:** iPhone 16 running iOS 26.4.2
**Tester:** Trevor Doodes
**Date completed:** 2026-05-12

---

## Per-screen audit

For each screen, walk through with each assistive technology and tick when verified or note any issue with a brief description and the corresponding code change (if any).

### Programme tab

| Check | VoiceOver | Voice Control | Increase Contrast | Differentiate Without Color | AX5 Dynamic Type | Reduce Motion |
|---|---|---|---|---|---|---|
| Day picker reads correctly | ✅ | ✅| ✅ | n/a | ✅ | n/a |
| Talk cards read in one focus stop | ✅| ✅| ✅ | ✅ | ✅ | n/a |
| Time reads naturally ("from 09:30 to 10:15") | ✅ | n/a | ✅ | n/a | ✅ | n/a |
| Speakers and location follow the title | ✅ | n/a | n/a | n/a | n/a | n/a |
| Favourite button focusable separately from card | ✅ | ✅ | ✅ | ✅ | ✅ | n/a |
| 88pt favourite hit area comfortable | n/a | n/a | n/a | n/a | ✅ | n/a |
| Custom announcement plays cleanly | ✅ | n/a | n/a | n/a | n/a | n/a |
| Differentiated haptic — add vs remove distinguishable | n/a | n/a | n/a | n/a | n/a | n/a |
| Break rows show session-type symbol | n/a | n/a | n/a | ✅| ✅ | n/a |
| Card border visible | n/a | n/a | ✅ | ✅ | n/a | n/a |
| Time column doesn't truncate | n/a | n/a | n/a | n/a | ✅ | n/a |
| Star bounce respects Reduce Motion | n/a | n/a | n/a | n/a | n/a | ✅ |

**Notes:** Manual pass found `.symbolEffect(.bounce, value:)` still played with system Reduce Motion on, despite Apple's guidance that symbol effects auto-suppress. `.symbolEffectsRemoved(_:)` did not help either — it only governs *indefinite* symbol effects, while `.bounce` triggered by a value-change is discrete. Fixed in `FavouriteButtonView.swift` by reading `@Environment(\.accessibilityReduceMotion)` and conditionally omitting the `.symbolEffect` modifier from the view tree entirely when Reduce Motion is on.

### Speakers tab

| Check | VoiceOver | Voice Control | Increase Contrast | AX5 Dynamic Type |
|---|---|---|---|---|
| Speaker rows read as one focus stop | ✅ | ✅ | ✅ | ✅|
| Voice Control activates by speaker name | n/a | ✅ | n/a | n/a |
| Search field announces result count | ✅ | n/a | n/a | n/a |
| Bio text adapts to Increase Contrast | n/a | n/a | ✅ | n/a |
| Speaker detail "Sessions" announces as heading | ✅ | n/a | n/a | n/a |
| Social links hint "Opens in browser" | ✅ | n/a | n/a | n/a |

**Notes:**
No Issues found

### Locations tab

| Check | VoiceOver | Voice Control | Increase Contrast | AX5 Dynamic Type |
|---|---|---|---|---|
| Location rows read as one focus stop |  ✅| ✅ | ✅ | ✅|
| Voice Control activates by location name | n/a | ✅ | n/a | n/a |
| Map labelled with venue name | ✅ | n/a | n/a | n/a |
| Map hint directs to text description | ✅ | n/a | n/a | n/a |
| Description text adapts to Increase Contrast | n/a | n/a | ✅| n/a |

**Notes:** During the manual pass the Map was reading its embedded `Marker` ("<venue name>, shows more info") instead of the outer `.accessibilityLabel`/`.accessibilityHint`. Fixed by adding `.accessibilityElement()` ahead of the label and hint in `LocationDetailView.swift` so the marker's accessibility subtree is collapsed and the custom hint ("Scroll down for a text description of this venue.") is what VoiceOver announces.

### My Schedule tab

| Check | VoiceOver | Voice Control | Increase Contrast | AX5 Dynamic Type |
|---|---|---|---|---|
| Empty state reads sensibly | ✅ | n/a | n/a | n/a |
| Day headings announced as headers | ✅ | n/a | n/a | n/a |
| Sessions read as on the Programme tab | ✅ | ✅ | ✅ | ✅ |
| No double-announce when scrolling pinned headers | ✅ | n/a | n/a | n/a |

**Notes:**
No issues found

### Session detail

| Check | VoiceOver | Voice Control | Increase Contrast | AX5 Dynamic Type |
|---|---|---|---|---|
| Title announced as heading | ✅ | n/a | n/a | ✅ |
| Time and location read clearly | ✅ | n/a | ✅ | ✅ |
| Speakers focusable as composite rows | ✅| ✅ | ✅ | ✅ |
| Description reads as one block | ✅ | n/a | n/a | ✅ |
| Toolbar favourite button compact, not oversized | n/a | n/a | n/a | ✅ |
| Toolbar favourite announces selected state | ✅ | n/a | n/a | n/a |
| Toolbar favourite triggers same announcement | ✅ | n/a | n/a | n/a |

**Notes:** Manual VoiceOver pass found the time element only read "Time X to Y" with no venue context; the venue followed as a separate stop. Extended the time's `.accessibilityLabel` in `SessionDetailView.swift` to include the venue name ("Time X to Y, at <venue>") so the two pieces are announced together on first focus, while the venue `NavigationLink` remains a separate, tappable focus stop.

### Tab bar

| Check | VoiceOver | Voice Control |
|---|---|---|
| Each tab has an item label | ✅ | n/a |
| Voice Control accepts each natural alias | n/a | ✅ |

**Notes:**
No issues found

---

## Accessibility Inspector audit

Run **Xcode → Open Developer Tool → Accessibility Inspector → Audit** on each screen with the iOS Simulator running. Capture warnings and resolutions below.

| Screen | Warnings found | Resolved? | Notes |
|---|---|---|---|
| Programme | _14_ | ✅  | All dynamic font sizes unsupported. False positive passes manual tests|
| Programme — talk card | _0_ | ✅ | |
| Programme — break row | _0_|✅| Included in Programme audit |
| Speakers list | _2_| ✅ |Liquid Glass tab bar contrast resolved by `.toolbarBackground(.visible, for: .tabBar)` in `HomeView.swift`, gated on `colorSchemeContrast == .increased`, so the bar renders opaque only for users who opted into Increase Contrast. |
| Speaker detail |_2_ | ✅| Dynamic font size unsupported.  False positive passes manual test|
| Locations list | _0_|✅ | |
| Location detail |_1_ |✅ |Dynamic font size unsupported  |
| Session detail | _1_ | ✅ | Hit area too small on the venue `NavigationLink`. Fixed in `SessionDetailView.swift` by adding `.frame(minHeight: 44)` and `.contentShape(.rect)` to the Label inside the link so the entire 44pt-tall rectangle catches taps. |
| My Schedule (empty) |_2_ | ✅|Dynamic font unsupported, false positive passes manual test |
| My Schedule (with favourites) |_1_ | ✅ | Pinned section header was sitting on a translucent `.regularMaterial` that let scrolling content through and failed the contrast threshold. Fixed in `MyScheduleView.swift` by swapping to a fully opaque `Color(.systemBackground)` when `colorSchemeContrast == .increased`; the regular material is retained for users who haven't opted into Increase Contrast. |

---

## Dynamic Type stress test (AX5)

| Screen | Layout intact at AX5? | Notes |
|---|---|---|
| Programme | ✅ | |
| Speakers | ✅ | |
| Locations | ✅ | |
| My Schedule | ✅| |
| Session detail | ✅ | |
| Speaker detail | ✅ | |
| Location detail | ✅ | |

---

## Differentiated haptic verification (real device only)

| Action | Haptic perceived | Distinguishable from the other action? |
|---|---|---|
| Add to favourites (`.success`) | ✅ | ✅ |
| Remove from favourites (`.impact(weight: .light)`) | ✅ | ✅|

---

## Outcomes

The submission passes every row of the per-screen audit across VoiceOver, Voice Control, Increase Contrast, Differentiate Without Color, AX5 Dynamic Type and Reduce Motion, and every screen in the Accessibility Inspector audit now resolves to ✅. The differentiated-haptic check on a physical iPhone 16 confirms that adding (`.success`) and removing (`.impact(weight: .light)`) a favourite feel clearly distinct.

**Working as designed (no code changes needed):** the existing VoiceOver focus order on talk cards, the per-row accessibility label shape ("[Type] from [start] to [end]: [title], by [speakers], [location]"), the `accessibilityInputLabels` aliases on the favourite button and tab bar items, the `.isHeader` traits on day-section labels, the Differentiate Without Color border + SF Symbol redundancy, and the AX5 layout reflow on every screen passed on first inspection.

**Caught and fixed during the manual passes:**
- *Map marker leakage* (`LocationDetailView`) — VoiceOver read the embedded `Marker` ("<venue>, shows more info") instead of the outer label/hint. Resolved with `.accessibilityElement()` to collapse the marker subtree.
- *Time read as digit-stream* — `.dateTime.hour(.twoDigits).minute(.twoDigits)` made VoiceOver speak "14:00" as "fourteen zero zero". Reformatted to 12-hour AM/PM with on-the-hour elision in `Session.accessibilityTimeText`.
- *Time and venue read as separate focus stops* on `SessionDetailView` — extended the time element's accessibility label to include the venue name so both pieces are announced together while the venue link remains independently focusable and tappable.
- *Reduce Motion ignored* by the favourite-star `.symbolEffect(.bounce)` — `.symbolEffectsRemoved(_:)` doesn't suppress discrete value-triggered effects, so the `.symbolEffect` modifier is now omitted from the view tree entirely when `accessibilityReduceMotion` is on.
- *Hit area too small* on the venue `NavigationLink` in `SessionDetailView` — Label's natural height is ~22pt; `.frame(minHeight: 44)` plus `.contentShape(.rect)` raises the tappable rectangle to the 44pt minimum.
- *Increase Contrast warnings* on the Liquid Glass tab bar and on the pinned day header in My Schedule — both materials let scrolling content through enough to fail Inspector's contrast threshold. The tab bar now uses `.toolbarBackground(.visible, for: .tabBar)` and the pinned header swaps to a fully opaque `Color(.systemBackground)` whenever `colorSchemeContrast == .increased`. Non-opted-in users keep Apple's intended translucent look.
- *Caption text contrast over tinted talk cards* — a re-audit after adding the Up Next promotion surfaced `.secondary` failing the 4.5:1 threshold on the talk card's end time, speakers, and location text, plus the Up Next card's "ON NOW" / "UP NEXT" header (orange-on-orange-tint). `contrastAdaptiveSecondary()` was originally gated on `colorSchemeContrast == .increased`; the gate was too narrow because Inspector audits against the default (Increase Contrast off) state. The modifier now always renders `.primary`, relying on font size and weight to carry the visual hierarchy. The Up Next header keeps its colour identity on the icon and switches the text to `.primary` for the same reason.
- *Multiple URLs packed into a single social-link entry* — surfaced by `SpeakerAccessibilityTests` in the Tier 1 suites. The conference data stores `"https://example.com\nhttps://github.com/foo\n"` in one `socialLink` field; `URL(string:)` accepted the whole string but the embedded newlines meant tapping the link did nothing and Voice Control commands like "Open GitHub" had no effect. `SocialLinksView` now splits each `socialLink` on newlines and renders one `Link` per URL, deriving a friendly label from the host ("GitHub", "Mastodon", "LinkedIn", "Bluesky", "Twitter / X") so each link is individually addressable by VoiceOver and Voice Control.

**Intentionally accepted:** the segmented day picker on the Programme tab does not visibly grow at AX5 because `UISegmentedControl` caps its label font and reflowing to a vertical menu would lose the at-a-glance three-day strip. The system Large Content Viewer (long-press a segment) is the accessibility-compensating affordance and is wired automatically by UIKit. Accessibility Inspector also flagged several "Dynamic Text" false positives on screens where the manual AX5 sweep confirmed layout integrity; those are recorded as `✅` with a rationale rather than fixed-in-code.

**Automated counterpart:** the five Tier 1 test suites in `MythConf26Tests/MythConf26Tests.swift` exhaustively pin the accessibility-string contract — every spoken label, every time string, every SF Symbol, every social URL — against the real bundled `conf.json` on every CI run. Running the manual Inspector audit therefore remains a one-off confirmation rather than a recurring obligation.

---

## Appendix — How to reproduce this audit

A short walkthrough so judges (or future contributors) can repeat each section of the audit on their own device or simulator. The simulator used during development was iPhone 17 / iOS 26.4.1; any iPhone running iOS 18+ should behave equivalently for the items checked below.

### Per-screen pass — assistive technologies

**VoiceOver.** Settings → Accessibility → VoiceOver. Also bind it to Accessibility Shortcut so a triple-click of the side button toggles it. Gestures: swipe right/left to move focus, double-tap to activate, two-finger swipe up to read the screen, two-finger rotation to switch the rotor. Walk each tab from top-left, ticking the column once each focus stop announces something close to the row's description.

**Voice Control.** Settings → Accessibility → Voice Control. Say "Show names" to overlay every actionable element's accessibility name; "Tap [name]" to activate. The favourite button has aliases ("Favourite", "Star", "Save") and tab bar items have multiple aliases each — see the test pass in `HomeView.swift` and `FavouriteButtonView.swift`.

**Increase Contrast.** Settings → Accessibility → Display & Text Size → Increase Contrast. Talk-card backgrounds change from 10 % tint to 25 % tint with a stroked border; the tab bar and the pinned My Schedule day header switch to fully opaque backgrounds. Caption text on tinted cards renders `.primary` regardless of the contrast setting (the original Increase-Contrast-only gate was widened after a re-audit to meet WCAG 4.5:1 at default contrast).

**Differentiate Without Color.** Settings → Accessibility → Display & Text Size → Differentiate Without Color. Each `SessionType` carries an SF Symbol (`SessionType.symbolName`) shown on break rows; talk cards gain a stroked border in the session-type colour so type is conveyed by shape and border as well as fill.

**Reduce Motion.** Settings → Accessibility → Motion → Reduce Motion. Tap any favourite star — it must change state without bouncing. The code path is in `FavouriteButtonView.bounceIfMotionAllowed`.

### Accessibility Inspector audit

The Inspector ships with Xcode and runs against a booted simulator. From a terminal:

```bash
xcrun simctl boot 91E4D96A-5233-4166-9396-847DAA0C12B5   # any iPhone simulator UDID
open -a Simulator
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 \
  -destination 'id=91E4D96A-5233-4166-9396-847DAA0C12B5' \
  -derivedDataPath /tmp/mythconf-dd build CODE_SIGNING_ALLOWED=NO
xcrun simctl install booted /tmp/mythconf-dd/Build/Products/Debug-iphonesimulator/MythConf26.app
xcrun simctl launch booted cjp.com.MythConf26
open -a "Accessibility Inspector"
```

In Accessibility Inspector: pick the booted simulator from the top-left target selector → click the **Audit** tab → **Run Audit** → record any warnings against the relevant row above. Navigate to the next screen in the simulator and re-run; the Inspector audits only the currently visible view tree.

### Dynamic Type at AX5

On a device: Settings → Accessibility → Display & Text Size → Larger Text → toggle on Larger Accessibility Sizes → drag the slider to the rightmost notch.

On the simulator:

```bash
xcrun simctl ui 91E4D96A-5233-4166-9396-847DAA0C12B5 content_size accessibility-extra-extra-extra-large
# reset afterwards:
xcrun simctl ui 91E4D96A-5233-4166-9396-847DAA0C12B5 content_size large
```

Re-launch the app and walk each screen. Pass criteria: no meaning-bearing text truncated, no controls pushed off-screen, layouts reflow vertically. Tab bar items and inline navigation titles intentionally cap their visible growth — long-press one and a centred HUD (the system **Large Content Viewer**) appears at full AX5 size.

### Differentiated haptics

Real device only — haptics do not fire in the simulator. Open Programme → tap a star to add (expect `.success`, a brief double-pulse) → tap the same star to remove (expect `.impact(weight: .light)`, a single soft thud). The pair should feel meaningfully different with your eyes closed.

### Verifying the temporal-context features

The conference-phase banner (top of Programme), the "Now" / "In N min" badges on each talk card, and the "Up next" promotion at the top of My Schedule are all reactive to the wall clock — they only surface inside specific time windows relative to the bundled `conf.json` dates (2–5 September 2027). To see them live without waiting for the real conference, set your Mac's clock to a date during the conference and re-launch the simulator: **System Settings → General → Date & Time → toggle off "Set time and date automatically" → set the date to 3 September 2027, 11:00**. The phase banner becomes "Day 2 of 4"; the talk card whose `startTime` falls inside the current 15-minute window shows an "In N min" badge; the talk currently underway shows a "Now" badge; and any session you favourite that's starting within the next two hours is promoted to the top of My Schedule. Revert the clock to automatic when done. The same behaviour is exhaustively pinned by the `TemporalContextTests` suite in `MythConf26Tests.swift`, which runs against injected `now` values rather than the real clock and passes on every CI run.

### Automated counterpart

The five Tier 1 test suites in `MythConf26Tests/MythConf26Tests.swift` replicate what the Accessibility Inspector's audit checks at the data level — every spoken label is exercised against every talk, speaker, session and location in `conf.json` on every CI run. Running the manual Inspector audit is therefore a one-off confirmation rather than a recurring obligation.
