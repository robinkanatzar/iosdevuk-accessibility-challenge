# Accessibility Remediation Summary

Date: 2026-05-09

This folder contains the accessibility audit inputs and the remediation plan for the MythConf26 SwiftUI app. The implementation work has been applied to `main` and focuses on VoiceOver behavior, Dynamic Type support, target sizing, semantic labels, and contrast/transparency resilience.

## What Was Fixed

### Programme and Session Cards

- Split the session card navigation target from the favourite button so each control has a clear, separate accessibility action.
- Added richer VoiceOver labels, values, hints, and input labels for talk cards.
- Added a custom accessibility action for toggling favourites from a talk card.
- Made programme rows reflow vertically at accessibility Dynamic Type sizes.
- Improved time column sizing so time labels keep a stable, readable touch and VoiceOver area.
- Added visible session type text so the category is not conveyed only through color.
- Updated break/session backgrounds to respect Reduce Transparency and increased contrast settings.

### Favourites

- Increased the favourite button hit target to at least 44 x 44 points.
- Added contextual labels such as "Add [talk title] to favourites" and "Remove [talk title] from favourites".
- Added selected state, accessibility value, hint, and input labels for Voice Control.

### Speakers

- Hid decorative speaker photos from VoiceOver where the image duplicates adjacent speaker text.
- Added clear row grouping so speaker name and summary read as one useful list item.
- Improved Dynamic Type behavior for speaker summaries by allowing full text at accessibility sizes.
- Added contextual social link labels, for example links that include the speaker name.
- Added heading traits on detail sections where the text functions as a real heading.
- Added an empty search result state for speaker search.

### Locations

- Summarized the map as a single accessible element with label, value, and hint.
- Added a visible "Open in Maps" link so map navigation is available outside the embedded map.
- Improved location row grouping and Dynamic Type behavior.

### App Shell and Visual Semantics

- Kept tab labels accessible by using standard `Label`-based tab items.
- Replaced decorative foreground styling with semantic foreground styles.
- Improved reduced-transparency behavior in schedule header areas.

## Automated Verification

Run from the repository root:

```sh
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Result on 2026-05-09: build succeeded.

```sh
a11y-check MythConf/MythConf26 --format json --per-view --no-trend
```

Result on 2026-05-09:

- Score: 100
- Grade: A+
- Errors: 0
- Warnings: 0

## Human Verification Still Recommended

These items need manual review because static tools cannot fully validate real assistive technology behavior:

- VoiceOver reading order across Programme, Speakers, Locations, My Schedule, and Favourites.
- Favourite toggling with VoiceOver rotor actions and direct touch.
- Voice Control command names for session cards, favourite buttons, social links, and map links.
- Dynamic Type layout at the largest accessibility sizes.
- Reduce Transparency and Increase Contrast appearance on device or simulator.
- Switch Control focus order for list rows and nested controls.
- External Maps handoff from location detail screens.

## Future Improvements

- Add UI tests or snapshot checks for large Dynamic Type layouts.
- Add a small accessibility regression checklist to pull requests.
- Consider an XCTest target for model/view behavior that affects accessibility text generation.
- Re-run `a11y-check` before release and after any navigation or list row refactor.
