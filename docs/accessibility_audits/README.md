# Accessibility Remediation Summary

Date: 2026-05-09

This folder contains the accessibility audit inputs and the remediation plan for the MythConf26 SwiftUI app. The implementation work has been applied to `main` and focuses on VoiceOver behavior, Dynamic Type support, target sizing, semantic labels, and contrast/transparency resilience.

## What Was Fixed

### Programme and Session Cards

- Restored full-width session cards while keeping the favourite star as a separate 44 x 44 point target inside the card area.
- Restyled session cards toward the supplied reference card with a pale adaptive surface, blue top accent, visible session type chip, stronger title hierarchy, and icon-backed speaker/location metadata.
- Kept the card itself as the navigation target and retained a custom accessibility action for toggling favourites from the focused card.
- Added richer VoiceOver labels, values, hints, and input labels for talk cards.
- Added explicit accessibility reading order for the card and favourite target.
- Stacked compact-width parallel sessions vertically so long titles are not squeezed into narrow columns.
- Made programme rows reflow vertically at accessibility Dynamic Type sizes.
- Improved time column sizing so time labels keep a stable, readable touch and VoiceOver area.
- Added visible session type text so the category is not conveyed only through color.
- Updated break/session backgrounds to respect Reduce Transparency and increased contrast settings.

### Session Details (Updated 2026-05-17)

- Redesigned the session detail screen with a standard inline navigation title, keeping the favourite control in the toolbar instead of building a custom top bar.
- Added a large readable session title, explicit Time and Location rows, a tappable speaker card section, and an "About This Session" section so the visual hierarchy matches the VoiceOver structure.
- Added a full-width "Add to Favourites" / "Remove from Favourites" action with clear VoiceOver labels, values, hints, and Voice Control input labels.
- Preserved the toolbar favourite star as a quick action while giving the body favourite button a separate, descriptive accessibility action.
- Added stable identifiers for the session detail title, time, location, speaker card, about text, and favourite action so UI tests can assert the detail screen structure.

### Favourites (Updated 2026-05-17)

- Increased the favourite button hit target to at least 44 x 44 points.
- Added contextual labels such as "Add [talk title] to favourites" and "Remove [talk title] from favourites".
- Standardized the saved-session action as "favourite" while keeping "My Schedule" as the destination tab for favourited sessions.
- Kept favourite state values such as "Favourited" and "Not favourited" so VoiceOver announces the current state clearly.
- Added selected state, accessibility value, hint, and input labels for Voice Control.
- Updated Voice Control input labels for favourite controls so the visible star can still be targeted with "Star", while repeated session cards also expose title-specific commands such as "Favourite [session title]".
- Added differentiated haptic feedback: success feedback when adding a favourite, light impact feedback when removing one.
- Added differentiated sound feedback: `bell.mp3` when adding a favourite, `pop.mp3` when removing one.

### Feedback Settings (Updated 2026-05-17)

- Added Settings toggles for favourite haptic feedback and favourite sound feedback.
- Kept both feedback types on by default while allowing users to disable either channel independently.
- Preserved favourite functionality when either feedback channel is disabled.

### On/Off Labels (Updated 2026-05-20)

The app's binary settings use native SwiftUI `Toggle` controls, so iOS provides the system switch semantics and supports the user's On/Off Labels display setting without custom drawing.

- `OpenDyslexic Reading Font`, `Haptic Feedback`, and `Sound Feedback` are implemented as native toggles in Settings rather than custom colour-only controls.
- Each toggle uses a stable setting label that describes the preference, while the native control supplies the on/off state.
- Toggle hints describe the result of changing the setting without duplicating the current state in the label.
- Favourite controls outside Settings are not switches, but they expose equivalent binary state through visible star state, accessibility values such as `Favourited` and `Not favourited`, selected state where applicable, and explicit add/remove actions.

Manual verification: enable **Settings > Accessibility > Display & Text Size > On/Off Labels**, open the app Settings screen, and confirm the system switch labels appear and VoiceOver announces each toggle label and state clearly.

### Button Shapes (Updated 2026-05-20)

The app uses a mix of native buttons, full-width action surfaces, icon buttons, and card/row navigation targets. Button Shapes support is handled by preserving native controls where possible and adding explicit shape affordances to custom icon-only controls when the system Button Shapes setting is enabled.

- The shared Settings toolbar button reads `accessibilityShowButtonShapes` and adds a circular background and separator stroke around the gear icon when Button Shapes is enabled.
- The favourite star button reads `accessibilityShowButtonShapes` and adds a circular background and separator stroke around the 44 x 44 point star target when Button Shapes is enabled.
- Speaker social link buttons use plain button styling and read `accessibilityShowButtonShapes` to add a small rounded background and separator stroke when Button Shapes is enabled.
- Session Detail speaker and location navigation rows read `accessibilityShowButtonShapes` and add a rounded background, separator stroke, and rectangular content shape when Button Shapes is enabled.
- Full-width actions such as Session Detail favourite and Location Detail Open in Maps use plain button styling with custom visible button surfaces: text, icons, rounded rectangular backgrounds, borders, and rectangular content shapes. This avoids the system drawing an extra oval around the custom label when Button Shapes is enabled.
- The My Schedule empty-state Browse Programme action uses a native bordered prominent button style, so SwiftUI provides the visible button shape.
- Other row and card navigation targets use visible card or row boundaries as the button-shape equivalent: programme cards have filled surfaces and strokes, location rows use standard list rows, and speaker rows use list-row structure.

Manual verification: enable **Settings > Accessibility > Display & Text Size > Button Shapes**, then check the Settings toolbar button, favourite star buttons in Programme and Session Detail, full-width action buttons, and tappable rows/cards. Confirm tappable areas are visually discoverable without relying on colour or text alone.

### Reduce Motion (Updated 2026-05-20)

- Gated the favourite star symbol replacement transition behind the system Reduce Motion setting.
- With Reduce Motion off, the favourite star can still use the symbol replacement transition when toggled.
- With Reduce Motion on, the star state changes without the replacement motion effect.
- Gated the Session Detail full-width favourite action animation behind the system Reduce Motion setting.
- With Reduce Motion off, the Session Detail favourite action can still use the short 0.2 second ease-in-out state animation.
- With Reduce Motion on, the Session Detail favourite action updates instantly without animating the button state change.
- Confirmed there are no active live badge `.symbolEffect` pulse animations in the current codebase. Any future symbol effects should also be gated by `accessibilityReduceMotion`.

### Reduce Transparency (Updated 2026-05-20)

The app avoids relying on blurred or translucent surfaces for core schedule content when the system Reduce Transparency setting is enabled.

- My Schedule day headers read `accessibilityReduceTransparency` and switch from `.regularMaterial` to opaque `Color(.systemBackground)` when Reduce Transparency is enabled.
- Programme and My Schedule talk cards read `accessibilityReduceTransparency` and use opaque `Color(.secondarySystemBackground)` instead of low-opacity session tinting when Reduce Transparency is enabled.
- Break rows read `accessibilityReduceTransparency` and use opaque `Color(.secondarySystemBackground)` instead of low-opacity session tinting when Reduce Transparency is enabled.
- Card shadows are suppressed in reduced-transparency contexts so schedule cards remain stable, flat, and readable.
- Other primary action surfaces, including Session Detail favourite and Location Detail Open in Maps, already use opaque system backgrounds and separator borders rather than material blur.

Remaining low-opacity accent fills in badges and icon backgrounds are decorative or secondary. Manual verification should confirm that these do not reduce readability when Reduce Transparency is enabled.

### Dyslexia Reading Mode (Updated 2026-05-17)

- Added an optional OpenDyslexic reading mode for users with dyslexia.
- Kept the setting off by default and user-controlled from Settings.
- **Targeted Accessibility Approach**: Applied OpenDyslexic to primary reading-heavy text (descriptions, biographies) while keeping dense metadata, navigation, and compact controls in the system font. This gives dyslexic users the benefit where reading load is highest without risking layout breakage in times, tabs, chips, and buttons.
    - **Reduces "Visual Crowding"**: Dyslexia is often exacerbated by "crowding"—where characters or lines of text feel like they are merging. By applying OpenDyslexic (which has "heavy bottoms" to prevent letter rotation) to long-form text, we help where the cognitive load is highest.
    - **Preserves "Information Scent"**: Navigation and metadata rely on pattern recognition. Keeping these in the system font ensures that "spatial" landmarks stay where the user expects them to be, without wider kerning causing labels to truncate or wrap awkwardly.
    - **Prevents "Layout Fatigue"**: Dyslexic-friendly fonts are often wider. Keeping compact grids and buttons in the system font prevents truncation ("...") which is more frustrating to read than a standard font.
- Preserved Dynamic Type by using scalable FontKit relative/dynamic font APIs rather than fixed-size custom fonts.

### ADHD Enhancements (Updated 2026-05-17)

- **Session Status Badge & Relative Countdown**: Added the `SessionStatusBadge` to programme rows and session cards to provide clear, immediate context for the current state of a talk.
    - **Reduces "Time Blindness"**: Converts abstract timestamps (e.g., "14:15") into concrete status markers. Within 15 minutes of a session start, the badge transitions to a precise countdown (e.g., **"Starting in 8m"**) or **"Starting now"** (when < 1 minute remains). This eliminates the mental math required for executive function, helping users who struggle to track durations and start times.
    - **Optimized VoiceOver Wording**: While the UI uses compact "m" for space, VoiceOver is provided with expanded wording (e.g., "Starting in 8 minutes") to ensure clarity and reduce cognitive effort during navigation.
    - **Instant Filtering**: The **"Live Now"** indicator (in high-signal red) creates a strong "information scent," allowing users to instantly scan a dense schedule and identify current sessions without being overwhelmed by visual noise.
    - **Anchoring in the "Now"**: By visually graying out **"Ended"** sessions, the app helps users focus only on the relevant present and future. This reduces "choice paralysis" and helps keep the user anchored in their current location within the multi-day schedule.
- **Precise Countdown Badge**: Added a **"Starting in Xm"** countdown when a session begins within 15 minutes, while keeping **"Starting Soon"**, **"Live Now"**, and **"Ended"** for the broader states.
    - **Actionable Time Anchor**: A specific countdown such as **"Starting in 8m"** gives users a concrete deadline, which is more useful than a generic soon-state for users with ADHD or time blindness.
    - **VoiceOver Parity**: The visual short form is expanded for assistive technology, for example **"Starting in 8 minutes"**, so non-visual users get the same precise timing cue.
    - **Human Verification Still Recommended**: Verify the countdown remains readable in Programme, My Schedule, and break rows at large Dynamic Type sizes, and that it appears only within the 15-minute window.

### Speakers

- Hid decorative speaker photos from VoiceOver where the image duplicates adjacent speaker text.
- Added clear row grouping so speaker name and summary read as one useful list item.
- Shortened the visible speaker row summary to the first biography paragraph and used explicit system label/background colors so the list remains readable and audit-friendly.
- Improved Dynamic Type behavior for speaker summaries by allowing full text at accessibility sizes.
- Added contextual social link labels, for example links that include the speaker name.
- Updated speaker social links to support the provided conference data format where multiple URLs are stored as newline-separated values in one `socialLink` field. The UI now renders one accessible button per valid URL without changing `conf.json`.
- Improved social link naming by inferring platforms from URL hosts, including Website, GitHub, LinkedIn, Mastodon, Twitter, and Bluesky.
- Refined social link VoiceOver labels so website links read as `Open [speaker]'s website`, while platform links read as `Open profile of [speaker] on [platform]`.
- Switched supported social/community platforms to local SF Symbol assets in `Assets.xcassets` so GitHub, LinkedIn, Mastodon, Twitter/X, and Bluesky use recognisable logo-style symbols without depending on the `SocialSymbols` package. Generic website/blog links keep system fallback symbols.
- Changed the social link layout so standard Dynamic Type sizes use a horizontal scroll view with an `HStack`, while accessibility Dynamic Type sizes use a vertical stack to keep icon-and-text buttons readable without awkward wrapping.
- Added heading traits on detail sections where the text functions as a real heading.
- Added a contextual accessibility label to the speaker detail sessions heading so VoiceOver announces "Sessions by [speaker name]" instead of only "Sessions".
- Added an empty search result state for speaker search.

### Locations

- Summarized the map as a single accessible element with label, value, and hint.
- Added a visible "Open in Maps" button to provide feature parity with VoiceOver users. While VoiceOver users can access the map action via the custom accessibility rotor, this visible button ensures that all users—regardless of assistive technology usage—have the same accessible shortcut for external navigation.
- Restyled the Maps handoff as a compact full-width button while preserving the explicit "Open [location] in Maps" accessibility label.
- Added a copy-link option on Location Detail so users are not locked into one navigation path. The toolbar menu item lets touch, Switch Control, and keyboard users copy the Apple Maps URL for use in another maps app, notes, messages, or a browser without adding another large action button to the page.
- Added `Copy Link` as a page-level VoiceOver custom action alongside `Open in Maps`. The visible toolbar menu is hidden from VoiceOver to avoid duplicate swipe stops while preserving equivalent functionality through the Actions rotor.
- Improved location row grouping and Dynamic Type behavior.

### Images

- Kept redundant speaker thumbnails decorative in speaker list rows because the adjacent row text already identifies the speaker.
- Exposed larger speaker detail photos with contextual labels such as "Photo of Sarah Thornton".
- Avoided raw asset names being announced by VoiceOver by using explicit labels for meaningful images and hidden semantics for decorative images.
- Confirmed SF Symbol icons are either part of labelled controls or paired with visible text through `Label`.

### App Shell and Visual Semantics

- Kept tab labels accessible by using standard `Label`-based tab items.
- Replaced decorative foreground styling with semantic foreground styles.
- Used monochrome tab icons to resolve a tab bar color issue and ensure reliable contrast across different system appearances.
- Improved reduced-transparency behavior in schedule header areas.
- Implemented locale-aware time formatting using `Locale.HourCycle`. The app now automatically respects the user's system setting for 12-hour or 24-hour time across all displays and VoiceOver announcements.

### Differentiate Without Color (Updated 2026-05-20)

The primary Differentiate Without Color risks identified in the original audits have been addressed by making important schedule state available through text, icons, shape, and accessibility values rather than color alone.

- Session category is no longer only represented by the coloured card strip or tinted card background. Programme cards include visible session type text in the chip, and the card accessibility label includes the session type, for example `Talk: [session title]`.
- Favourite state is not dependent on the yellow star colour. Favourite controls use different star symbols, explicit action labels, a stable accessibility value such as `Favourited` or `Not favourited`, selected state where applicable, and title-specific Voice Control input labels.
- Session timing/status is not dependent on red, orange, blue, or green tint. `SessionStatusBadge` and `NowNextBadge` expose visible text such as `Live Now`, `Starting in 8m`, `Ended`, `Now`, and `Next`; status badges also pair the text with SF Symbol icons.
- Live sessions may still receive a red border for visual emphasis, but the meaning is also carried by the visible status badge and the card's accessibility custom content.
- Location and Maps actions use icon-plus-text labels, so the action is understandable without relying on accent colour.
- The Programme day picker uses the native segmented control selected state. Its colour treatment supports the design, but selection is not conveyed by colour alone.

Remaining visual colour use is decorative or redundant: card accents, low-opacity session type backgrounds, chip border tint, and metadata icon tint. These should remain acceptable as long as the adjacent text remains visible and the app continues to pass grayscale/Differentiate Without Color manual review.

### Grayscale (Updated 2026-05-20)

The app's primary states remain understandable when the display is converted to grayscale because important meaning is carried by text, symbols, shape, and explicit accessibility state rather than hue alone.

- Session timing and status use visible text such as `Live`, `Starting in 8m`, `Ended`, `Now`, and `Next`, so users do not need to distinguish red, orange, blue, or green.
- Favourite state uses star shape changes, explicit add/remove labels, accessibility values such as `Favourited` and `Not favourited`, and selected state where applicable, so the yellow star colour is not the only state indicator.
- Session category uses visible chip text and card accessibility labels, so the coloured card strip and tinted background are redundant cues rather than the only category signal.
- Action buttons such as Session Detail favourite and Location Detail Open in Maps use text, icons, borders, and filled surfaces that remain identifiable without colour.
- The tab bar uses monochrome SF Symbols and visible labels, which avoids multi-colour tab state depending on hue.

Remaining grayscale verification should focus on luminance contrast rather than meaning: check filled favourite stars, status badges, low-opacity card accents, and accent-colour icon backgrounds with the grayscale colour filter enabled.

### Siri and Voice-First Shortcuts (Updated 2026-05-21)

- Simplified App Intents to one reliable voice-first workflow: **Read Schedule**.
- Removed Siri session-title entity resolution, Siri favourite, Siri unfavourite, and Siri session-detail shortcuts because spoken session names were fragile and made the shortcut surface harder for Shortcuts/Siri to register and resolve reliably.
- Users still favourite sessions through the visual app, VoiceOver, Magic Tap, Voice Control, or custom actions. Siri then reads the already-saved/favourited schedule aloud.
- Returned spoken `IntentDialog` responses for voice-only use, including an empty-schedule state and a saved-sessions summary.
- Updated Siri spoken times to use clear phrases such as `Start time 09:30. End time 09:40.` while keeping compact time ranges in visual display subtitles.
- Used user-facing Siri wording such as "your schedule" so responses sound natural when Siri is addressing the user.
- Kept the Siri action aligned with existing app functionality: it mirrors the My Schedule tab rather than adding a new workflow.
- Kept easier app names such as `Myth Con`, `Myth Conference`, and `iOSDevUK` so users do not have to pronounce `MythConf` exactly.

### Searchable Sessions App Entity (Updated 2026-05-21)

- Added searchable session App Entities for system search while keeping **Read Schedule** as the only visible Siri/Shortcuts action.
- Indexed talk sessions with title, speaker, location, day, and time metadata so users can search for a session without visually scanning the full Programme.
- Added a hidden `OpenSessionIntent` for search results. Tapping a session result opens the app and routes through the existing Programme navigation to the matching Session Details screen.
- Kept this separate from spoken Siri session-title commands. Search/open supports users who prefer typing, keyboard search, Voice Control search workflows, or Spotlight-style discovery without reintroducing fragile spoken title matching.
- Accessibility benefit: helps VoiceOver users, Voice Control users, keyboard users, and users with cognitive fatigue jump directly to a known talk by remembering any useful detail such as title, speaker, location, or day.
- Mobility benefit: reduces repeated taps and swipes through a dense multi-day schedule. A user can use system search, select the result, and land on the correct detail screen in one navigation jump.
- Cognitive benefit: supports recognition-based navigation. Users can search for the one detail they remember, such as `SwiftData`, `Alex Morgan`, or `Tyndall Lecture Theatre`, instead of holding the day, time, and room structure in memory while browsing.

Search/open manual verification:

1. Fresh install and run the app so the search index is populated.
2. Open system search.
3. Search for `Observable`, `SwiftData`, or `LLDB`.
4. Tap the MythConf/iOSDevUK session result.
5. Confirm the app opens directly to the matching Session Details screen.

Manual verification:

1. Build and run the app.
2. Open Shortcuts and search for `iOSDevUK`, `Myth Con`, or `MythConf`.
3. Confirm only `Read Schedule` appears for the app.
4. With no favourites, run `Read Schedule` and confirm Siri says the schedule is empty.
5. Favourite one or more sessions in the app.
6. Run `Read Schedule` again and confirm Siri reads the saved sessions.
7. Test phrases:
   - `Read my schedule in iOSDevUK`
   - `Read my schedule in Myth Con`
   - `What is on my schedule in iOSDevUK`
   - `Read saved sessions in iOSDevUK`

### TipKit Feature Discovery (Updated 2026-05-17)

- Added contextual TipKit guidance for existing app features that can be missed visually or non-visually.
- Added a "Save Sessions" tip on the favourite star so users learn that the control keeps sessions in their schedule.
- Added a "Switch Days" tip on the Programme day picker so users discover the multi-day schedule.
- Added a "Find a Speaker" inline tip on the Speakers screen so users discover speaker search.
- Added an "Open in Maps" tip on location detail screens so users discover the external Maps handoff.
- Invalidated tips when the taught action is performed, reducing repeated guidance after the user has learned the control.
- Hid tips during all UI test launches so TipKit popovers do not create unstable screenshots or element-detection results.

### Automated UI Audits (Updated 2026-05-17)

- Added a `MythConf26UITests` accessibility audit suite using Apple's XCTest `performAccessibilityAudit` API.
- Added a UI-test launch reset hook so favourites start from a known state during automated tests.
- Added stable accessibility identifiers for major test targets, including the Programme day picker, schedule lists, session cards, session detail sections, favourite buttons, speaker rows, speaker detail sessions heading, location rows, and My Schedule states.
- Added automated audit coverage for Programme (including precise countdown tests), Speakers, Locations, My Schedule empty state, and My Schedule populated state.
- Added Settings screen audit coverage, including OpenDyslexic, favourite haptic feedback, and favourite sound feedback toggles. The Settings and My Schedule empty-state audits exclude XCTest's `dynamicType` check because Apple's audit timed out consistently in batched simulator runs; Dynamic Type remains covered by human review for those screens. My Schedule empty state also uses focused assertions for the Browse Programme action because the broad XCTest audit can time out on that screen in simulator runs.
- Added MythConf-specific semantic assertions for favourite add/remove labels and the speaker detail "Sessions by [speaker name]" heading.
- Added a focused UI assertion that opening a Programme session exposes the redesigned Session Details structure.
- Added a strict false-positive policy in the test harness: no audit issue is ignored unless it is reviewed and explicitly documented.
- Limited automated XCTest audits to contrast, element detection, hit regions, element descriptions, and traits. Dynamic Type and text clipping remain manual/static verification items because they were too slow or too noisy on the simulator used here.
- Disabled the XCTest contrast audit for the Speakers flow after reviewing repeated false positives against full-contrast system label text, and for the My Schedule empty-state audit after repeated simulator audit timeouts. Speaker and My Schedule empty-state contrast remain covered by `a11y-check` and human review; Programme, Locations, and My Schedule populated state still run contrast in XCTest.
- Added one narrow XCTest audit ignore for Apple's `Contrast nearly passed` result. Full contrast failures still fail the test suite where contrast auditing is enabled.

### Disabled XCTest Audit Checks To Investigate (Updated 2026-05-17)

These checks are not fully enabled in automated XCTest audits yet. Revisit them when the simulator/test runner is stable enough to distinguish real failures from tool noise.

- `dynamicType` is disabled because it was too slow and noisy in simulator UI tests. It caused timeouts instead of reliable, actionable failures. Dynamic Type remains a manual verification item.
- `textClipped` is disabled because it produced noisy or false-positive results during audit runs. Text clipping remains covered by manual review, especially at large accessibility text sizes.
- `contrast` is disabled only for the Speakers flow because XCTest repeatedly reported false contrast failures on normal system label text in the Speakers list/detail flow, even after row adjustments and passing static accessibility analysis. The Speakers flow still runs `elementDetection`, `hitRegion`, `sufficientElementDescription`, and `trait` audits.
- `contrast` remains enabled in XCTest for Programme, Locations, and My Schedule.
- `Contrast nearly passed` is ignored as a narrow XCTest false positive because Apple's audit can emit this borderline result for SwiftUI/system rendering. Full contrast failures still fail where contrast auditing is enabled.

## Automated Verification

Run from the repository root:

```sh
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Result on 2026-05-10: build succeeded.

Run the UI accessibility audits from the repository root:

```sh
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' test
```

The UI test target audits the visible app screens with `performAccessibilityAudit` and adds focused assertions for labels that XCTest can inspect. These tests require an iOS 17 or newer simulator. The automated audit intentionally excludes Dynamic Type and text clipping checks; keep those in the manual verification pass below.

```sh
a11y-check MythConf/MythConf26 --format json --per-view --no-trend
```

Result on 2026-05-09:

- Score: 100
- Grade: A+
- Errors: 0
- Warnings: 0

Simulator visual verification was also performed for the compact Programme card layout after the option C card redesign. The shared `ParallelSessionsRowView` and `ParallelTalkCardView` components are used by Programme and My Schedule.

## Accessibility Linting (a11y-check)

This project uses [a11y-check](https://github.com/cvs-health/ios-swiftui-accessibility-techniques#a11y-checker-a11y-check)
to catch accessibility issues at build time, similar to SwiftLint.

Accessibility issues like missing labels, incorrect traits, and small touch targets
are caught during development rather than discovered during manual testing or audits.
Issues are aligned with WCAG 2.2 and appear inline in Xcode's Issue Navigator and
editor gutter with file, line, and column information — no need to run the tool manually.

### Homebrew (easiest)

```bash
brew tap cvs-health/ios-swiftui-accessibility-techniques https://github.com/cvs-health/ios-swiftui-accessibility-techniques.git
brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check
```

If the build fails with `cannot find type 'SendableMetatype' in scope`, run:  
`env -u SDKROOT brew install --HEAD cvs-health/ios-swiftui-accessibility-techniques/a11y-check`

Then run `a11y-check` from anywhere. Run `a11y-check --version` to verify the install. Run `which a11y-check` to confirm the install path (typically `/opt/homebrew/bin/a11y-check`).

## VoiceOver Magic Tap for Session Detail

Added support for **VoiceOver Magic Tap** (`accessibilityAction(.magicTap)`) on the **Session Detail** screen, allowing users to quickly add or remove a session from their schedule using a two-finger double tap anywhere on the page.
Magic Tap is designed to trigger the most important contextual action on a screen, making it a natural fit for the session scheduling workflow. This provides a faster and more efficient experience for VoiceOver users by reducing the need to navigate back to the action button, while still preserving the standard visible button for discoverability and flexibility.

## Custom Accessibility Actions for Location Detail

For the **Location Detail** screen, I chose **custom accessibility actions** instead of Magic Tap for opening **Apple Maps**.
Since launching another app is a higher-impact action, exposing it through the **VoiceOver Actions rotor** provides a more predictable and intentional experience. VoiceOver users are explicitly informed that additional actions are available, making the feature easier to discover while also reducing the risk of accidental navigation away from the app.

The same Actions rotor also exposes **Copy Link**. This gives VoiceOver users a non-navigation alternative: they can copy the location URL and paste it into another maps app, a message, notes, or a browser. The visible toolbar menu is intentionally hidden from VoiceOver because it duplicates the rotor action, while still keeping the copy option discoverable for touch, Switch Control, and keyboard users.

## High-Fidelity Accessibility Notifications (iOS 26+)

Implemented modern accessibility patterns to keep VoiceOver users informed of critical state changes and external handoffs, prioritizing background reliability and persistent feedback.

- **Maps Handoff Confirmation (AccessibilityNotification.Announcement)**: When the user taps the "Open in Maps" button, the app explicitly posts a high-priority announcement ("One moment, opening Apple Maps...") before triggering the external navigation. 
    - **Accessibility Benefit**: Standard URL transitions are often too fast for VoiceOver to process, which can leave non-visual users disoriented by a sudden, unexplained app switch. By using a manual announcement, we provide a "verbal bridge" that prepares the user for the context change and ensures they know exactly which external service is being launched before the conference app enters the background.
- **Local Session Reminders (UNCalendarNotificationTrigger)**: Replaced visual alerts with system-level local notifications for favourited sessions. Reminder timing is user-configurable: Off, 5 minutes, 10 minutes, or 15 minutes before a session starts.
    - **Accessibility Benefits**: 
        - **Lock Screen Support**: Reminders are accessible even when the device is locked and the user is moving between sessions.
        - **Persistence**: Notifications stay in the Notification Center, allowing users to review them if they missed the initial alert.
        - **VoiceOver Reliability**: System notifications provide the most reliable way for VoiceOver to announce time-sensitive information, especially when the app is in the background. 
        - **Deep-Link Efficiency**: Notifications are fully interactive. Tapping a reminder automatically launches the app and navigates directly to the relevant session details, saving the user from manually searching through the schedule. 

## Testing Time-Based Features 

To test features like the **Session Start Alert** without waiting for the actual conference dates, you can inject a custom system date using launch arguments. 

### How to set a Custom Date: 
1. In Xcode, go to **Product > Scheme > Edit Scheme...** 
2. Select **Run** on the left sidebar, then the **Arguments** tab. 
3. Under **Arguments Passed On Launch**, add: 
   `-TestingDate 841582200` 
   *(This represents Sep 1, 2027, 08:59:30 AM — 10 minutes before the first workshop starts)*. 

### Session Status Badge Test Dates:

- `-TestingDate 841581000`: 30 minutes before the first workshop. The status badge should be hidden.
- `-TestingDate 841581720`: 18 minutes before the first workshop. The status badge should show **Starting Soon**.
- `-TestingDate 841582320`: 8 minutes before the first workshop. The status badge should show **Starting in 8m** visually and expose **Starting in 8 minutes** to VoiceOver.
- `-TestingDate 841582800`: at the first workshop start time. The status badge should show **Live**.
- `-TestingDate 841590001`: just after the first workshop ends. The status badge should show **Ended**.

### Now and Next Row Chips

Programme and My Schedule rows can show compact **Now** and **Next** chips beside the time column.

This feature was added as an accessibility and cognitive support improvement. It gives users an immediate schedule anchor without requiring them to calculate the current time against multiple start/end times. It is especially useful for VoiceOver users, users with ADHD or time blindness, dyslexic users scanning dense timetable text, users with cognitive fatigue, and attendees navigating quickly between rooms under time pressure.

- **Now** appears on the session or break that is currently in progress.
- **Next** appears only when there is also a visible/current **Now** item in the same schedule context.
- If there is no current **Now** item, **Next** is not shown. This avoids making a future session look like the current schedule anchor.
- The status badge now says **Live** instead of **Live Now** so the row can express two separate concepts: **Now** for schedule position and **Live** for session status.
- The chip is placed beside the time column because it supports the same task: understanding where the current time sits in the schedule.

Manual verification:

1. Launch with `-TestingDate 841581000` and confirm neither **Now** nor **Next** appears.
2. Launch with `-TestingDate 841582800` and confirm the current row shows **Now** and **Live**.
3. Confirm the next row shows **Next** only while a current **Now** row exists.
4. Favourite a current or upcoming session and repeat the check in My Schedule.
5. With VoiceOver, confirm the row announces schedule position without adding a separate chip stop, for example: `Now, Live, 16:00 to 18:00...`.

### Favourite Feedback Fallback Announcement

Favourite toggles use haptic and sound feedback by default. When both are disabled, the app posts a spoken accessibility announcement:

- `Added to favourites`
- `Removed from favourites`

This keeps confirmation available for users who cannot use haptics or sounds. The announcement is intentionally a fallback so VoiceOver does not speak duplicate confirmations when another feedback channel is active.

Manual verification:

1. Enable VoiceOver.
2. Open Settings.
3. Turn off Favourite haptic feedback and Favourite sound feedback.
4. Favourite a session and confirm VoiceOver announces `Added to favourites`.
5. Unfavourite the same session and confirm VoiceOver announces `Removed from favourites`.

### VoiceOver Custom Rotors for Schedule Navigation

Programme and My Schedule include custom VoiceOver rotors for dense schedule navigation:

- Live Sessions
- Upcoming Sessions
- Favourited Sessions
- Breaks

These rotors help VoiceOver users move through the programme without swiping card by card. They are especially useful during the conference when users need to quickly find the current session, jump to upcoming sessions, jump to their saved sessions, or find breaks.

`Upcoming Sessions` gives VoiceOver users a quick way to skip past ended or currently live content and move through sessions that have not started yet. Its entries include the session or break name and start time, making it useful for planning the next talk without scanning the whole day.

`Sessions by Speaker` and `Sessions by Location` were investigated and removed. With SwiftUI `AccessibilityRotorEntry(id:in:)`, VoiceOver navigation lands on the target session card and announces that card's accessibility label, not the custom rotor entry label. That meant a user choosing a speaker or location rotor still heard the normal card announcement, such as `Talk: Welcome to MythConf 2027`, without the speaker or room context promised by the rotor name. Adding speaker and location to every card label would make the normal swipe flow too verbose, so speaker and location discovery remains in the dedicated Speakers and Locations tabs. Session cards still expose Speaker, Location, Time, Status, and Favourite state through `accessibilityCustomContent`.

Manual verification:

1. Enable VoiceOver.
2. Open Programme with a test date during a live session.
3. Open the rotor and confirm the custom rotor names appear.
4. Use Live Sessions to jump to the current session.
5. Use Upcoming Sessions to jump to sessions or breaks that have not started yet.
6. Favourite a session and confirm it appears in Favourited Sessions.
7. Use Breaks to jump to registration, tea/coffee, lunch, or social rows.
8. Confirm Sessions by Speaker and Sessions by Location are not present in the schedule rotor list.
9. Use the Speakers and Locations tabs for speaker-based and room-based discovery.
10. Repeat in My Schedule with at least one favourited session.

### Session Card Custom Accessibility Content

Session cards expose structured metadata with `accessibilityCustomContent`:

- Speaker
- Location
- Time
- Status
- Favourite state

Break rows expose structured metadata for time, location, and status. This keeps the main session or break label short while still allowing VoiceOver users to inspect important details through the custom content rotor. It reduces long repeated announcements and helps users who need specific metadata, such as location or time, without forcing every detail into the primary swipe order.

Time metadata now uses spoken-friendly ranges instead of the compact visual range `09:30 - 09:40`. Upcoming sessions read as `Starts at 09:30. Ends at 09:40.`, live sessions read as `Started at 09:30. Ends at 09:40.`, and ended sessions read as `Started at 09:30. Ended at 09:40.` The visible UI remains compact, but VoiceOver avoids reading punctuation or dashes awkwardly. This gives users two clear time anchors and helps people who find dense timetable ranges harder to process.

Manual verification:

1. Enable VoiceOver.
2. Focus a Programme session card.
3. Confirm the main announcement is concise.
4. Open the custom content rotor and confirm Speaker, Location, Time, Status, and Favourite state are available.
5. Confirm Time reads as a spoken range with appropriate tense, for example `Started at 09:30. Ended at 09:40.` for ended sessions.
6. Toggle the favourite state and confirm the custom Favourite value updates.
7. Focus a break row and confirm Time, Location, and Status are available.
8. Repeat on My Schedule.

### Accessible Favourite Reminder Controls

Settings includes a **Session Reminders** control for favourited sessions:

- Off
- 5 minutes
- 10 minutes
- 15 minutes

This was added because reminder timing affects cognitive load and interruption management. Some users need earlier prompts to transition between rooms, while others find reminders disruptive and need to turn them off. This helps users with ADHD, time blindness, anxiety around interruptions, auditory sensitivity, and anyone navigating a busy venue with VoiceOver or Switch Control.

The reminder timing control uses a menu picker instead of a segmented picker. This preserves label context for VoiceOver and avoids four cramped segmented targets on narrow devices, improving Switch Control and motor accessibility.

Manual verification:

1. Open Settings and confirm the Session Reminders options are reachable with VoiceOver.
2. Confirm the reminder timing control is announced as `Favourite reminder timing` and opens as a menu.
3. Set reminders to Off, favourite a future session, and confirm no reminder is scheduled.
4. Set reminders to 5 minutes, favourite a future session, and confirm the pending reminder says `starting in 5 minutes`.
5. Repeat for 10 and 15 minutes.
6. Confirm past sessions never schedule reminders.

### Settings VoiceOver Polish

- The OpenDyslexic preview is hidden from VoiceOver because it is a visual-only font sample. VoiceOver users get the actionable setting through the OpenDyslexic toggle instead.
- Settings footer explanations are hidden from VoiceOver where the same practical information is already provided by the control label, value, and hint.
- When VoiceOver is running, toggling OpenDyslexic announces whether the preview changed to OpenDyslexic or back to the system font.
- Settings toggle hints were updated to describe the result of each action, including OpenDyslexic, favourite haptic feedback, and favourite sound feedback.

### Accessibility Label Cleanup (Updated 2026-05-21)

The app now keeps several custom VoiceOver labels closer to the visible text and avoids category prefixes that made announcements longer than needed.

- Session Detail title and description labels now use the actual session title and description instead of prefixed labels such as `Session Title` or `Session Description`.
- Session Detail location and speaker rows now use the location or speaker name as the primary label, with navigation context left to the control role and hint.
- Speaker Detail names, biographies, and session links no longer add `Speaker`, `Biography`, or `Session` prefixes to the primary label.
- Talk summary rows keep time and location in `accessibilityValue` while using the session title as the primary label.
- Location Detail venue descriptions now use the visible venue text directly, the map label is shorter, and the Maps action reads `Open [location] in Maps` with a concise `Gets directions` hint.

Manual verification: enable VoiceOver and spot-check Programme session details, Speaker detail session links, Location detail, and Settings. Confirm custom labels are concise, do not announce colon-prefixed categories, and still provide enough context through role, value, hint, or surrounding navigation title.

### Notification Test Reset

Automated UI tests pass `-UITestingResetNotifications` to clear pending and delivered local notifications before each launch. This prevents old scheduled reminders from affecting notification tests.

### Local Notification Reminder Scenario

To manually verify the default 10-minute reminder:

1. Launch with `-TestingDate 841582180`, which is 20 seconds before the first workshop's 10-minute reminder trigger.
2. Open Programme.
3. Favourite the first workshop.
4. Allow notification permission if prompted.
5. Wait about 20 seconds.
6. Expected: a local notification appears with title `Session Starting Soon` and body mentioning that the selected session is starting in 10 minutes.

### Verification Steps: 
1. Launch the app with the argument above. 
2. Go to the **Programme** tab. 
3. **Favourite** the first two workshops: *"SwiftUI Architecture in Practice"* and *"Swift Concurrency from the Ground Up"*. 
4. Wait up to 30 seconds. 
5. **Expected:** VoiceOver will announce the grouped sessions in a natural list: *"Exciting! You have 2 sessions starting now: 'SwiftUI Architecture in Practice' by Sarah Thornton and 'Swift Concurrency from the Ground Up' by Zara Ahmed. I hope you enjoy them!"* 



## Human Verification Still Recommended

These items need manual review because static tools cannot fully validate real assistive technology behavior:

- **Accessibility Announcements**:
    - **Handoff Verification**: Navigate to a location detail screen and tap "Open in Maps" with VoiceOver active. Verify you hear the "One moment..." announcement before the Maps app opens.
    - **Session Start Notification**: Favourite a talk. Background the app and lock the device. Verify that a system notification appears at the selected reminder timing. 
    - **Interaction Test**: Tap the notification banner (or double-tap with VoiceOver). Verify that the app opens and immediately displays the correct **Session Detail** screen.
- Any `performAccessibilityAudit` failure that looks like a tool false positive must be reviewed with the failing screenshot, issue type, and affected element before adding an ignore.
- VoiceOver reading order across Programme, Speakers, Locations, My Schedule, and Favourites.
- Favourite toggling with VoiceOver rotor actions and direct touch.
- Favourite toggle haptic patterns on a physical device; simulator builds cannot prove real tactile output.
- Favourite toggle sounds on a physical device, including silent-mode and volume behavior.
- Favourite feedback settings on a physical device: verify haptic and sound toggles independently control add/remove favourite feedback.
- My Schedule card appearance after favouriting sessions, especially with long titles.
- Reference-style session card appearance in Programme and My Schedule, including dark mode, Increase Contrast, Reduce Transparency, and largest accessibility Dynamic Type sizes.
- Redesigned Session Details appearance in portrait and landscape, especially the Time/Location rows, speaker card, and bottom favourite action at large Dynamic Type sizes.
- VoiceOver behavior for the Session Details toolbar favourite and the body favourite action, confirming users understand that both update their schedule.
- VoiceOver behavior for speaker photos in list rows and speaker detail screens.
- VoiceOver announcement for the speaker detail sessions heading, which should identify the speaker context.
- **Voice Control Verification**:
    - **"Show Names"**: Turn on Voice Control and say "Show names". Verify that every talk title in the Programme has a name overlay that matches its visible text.
    - **"Tap [Talk Title]"**: Try to open a session by saying only its title.
    - **"Tap [Day Name]"**: In the Programme, verify you can switch days by saying the visible day name (e.g., "Tap Wednesday").
    - **"Tap Star" / "Tap Favourite"**: Verify you can toggle a favourite by saying "Tap Star" or "Tap Favourite".
- Voice Control "Show Names" on Programme and My Schedule should expose favourite controls with usable star and session-specific names; on a detail screen, "Tap Star" should target the current session's favourite control.
- Siri and Shortcuts spoken responses for empty schedule and populated saved schedule.
- VoiceOver and Voice Control should make the relationship clear: favouriting a session adds it to the user's schedule, and unfavouriting removes it from the user's schedule.
- TipKit timing, placement, and dismissal behavior with VoiceOver, Voice Control, Switch Control, and large Dynamic Type.
- OpenDyslexic setting with VoiceOver: confirm the Settings button, toggle, and Done button announce clear labels, states, and hints. Confirm the visual-only font preview is skipped by VoiceOver.
- OpenDyslexic visual review: enable the setting and inspect Programme, Session Details, Speakers, Locations, and My Schedule at default and accessibility Dynamic Type sizes.
- Confirm compact metadata such as times, dates, tabs, navigation titles, and status badges remain stable and readable when OpenDyslexic is enabled.
- Reduce Motion: toggle a favourite with Reduce Motion off and confirm the star replacement transition appears, then enable Reduce Motion and confirm the star changes state without replacement motion.
- Dynamic Type layout at the largest accessibility sizes.
- Text clipping across Programme, Speakers, Locations, and My Schedule, especially after large Dynamic Type or localization changes.
- Reduce Transparency and Increase Contrast appearance on device or simulator.
- Switch Control focus order for list rows and nested controls.
- **Locale-Aware Time**: Toggle the 12/24-hour clock setting in System Settings. Verify that session times and VoiceOver announcements update to match the preferred format.
- External Maps handoff from location detail screens, including the compact Maps button's touch target, VoiceOver label, and TipKit popover placement.
- Test Magic Tap for Session Detail
- Test VoiceOver Actions rotor in Location Detail for open in map action.

## Future Improvements

- Add snapshot checks for large Dynamic Type layouts.
- Add a small accessibility regression checklist to pull requests.
- Consider an XCTest target for model/view behavior that affects accessibility text generation.
- Re-run `a11y-check` before release and after any navigation or list row refactor.
