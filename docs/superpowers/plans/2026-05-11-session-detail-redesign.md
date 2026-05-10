# Session Detail Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign `SessionDetailView` from the current sparse detail screen toward the richer reference layout in Image #2 while preserving and improving accessibility.

**Architecture:** Keep `SessionDetailView` as the detail destination for `TalkReference`, but split the visual sections into small private subviews/properties inside the file unless the implementation grows too large. Reuse existing data from `ViewModel`, `Talk`, `Session`, `SpeakerRowView`, and `FavouriteButtonView`; do not add new app features or data.

**Tech Stack:** SwiftUI, existing navigation destinations, existing favourite model, TipKit save-session context, XCTest UI tests, XcodeBuildMCP for build/test verification.

---

## Target UX

Move from the current simple layout:

- Inline navigation title only.
- Plain time/location row.
- Plain speaker row.
- Divider.
- Abstract text.
- Favourite only in the toolbar.

To a richer detail layout:

- Standard inline navigation title set to "Session Details".
- Favourite star remains in the trailing toolbar using the existing `FavouriteButtonView`.
- Large session title in the content body.
- Time and location presented as two clear information rows with icon tiles and labels.
- Speaker section with uppercase heading and a card-style speaker row.
- "About This Session" section with uppercase heading and readable body copy.
- Prominent bottom "Add to Schedule" / "Remove from Schedule" action.

## Accessibility Requirements

- Keep the screen usable with VoiceOver, Voice Control, Switch Control, Full Keyboard Access, and Dynamic Type.
- The default system back button must remain in place so navigation behavior and accessibility stay standard.
- The favourite action must be available both visually and accessibly:
  - Toolbar star keeps the existing `FavouriteButtonView` semantics.
  - Bottom primary button must not create confusing duplicate VoiceOver actions if both controls are visible.
- Time and location rows must expose meaningful labels and values:
  - Time: label "Time", value from `session.timeRange`.
  - Location: label "Location", value from `viewModel.locationNameFrom(locationID:)`, hint "Shows location details".
- Speaker card remains a real navigation target to speaker detail and keeps a useful label/hint.
- Section headings should use `.accessibilityAddTraits(.isHeader)`.
- At accessibility Dynamic Type sizes, rows should stack and text must not clip.
- Decorative icons must be hidden from accessibility when the surrounding text already conveys meaning.
- No information should be conveyed by color alone.

## Files

Modify:

- `MythConf/MythConf26/Programme/SessionDetailView.swift`
  - Main implementation.
  - Add custom detail layout sections.
  - Preserve `SaveSessionTip.hasViewedSaveContext = true`.

- `MythConf/MythConf26UITests/MythConf26UITests.swift`
  - Add focused assertions only if new identifiers are introduced.
  - Preserve existing accessibility audit behavior.

- `docs/accessibility_audits/README.md`
  - Document the session detail UI/accessibility update and manual checks.

Do not modify:

- `Model/conf.json`
- Existing speaker/location/session data.
- App Intents or TipKit behavior except preserving the save-session context.

## Task 1: Refactor Session Detail Layout

- [x] Extract repeated data into private computed properties:
  - `locationName`
  - `isFavourite`
- [x] Replace the current plain `ScrollView` content with sectioned content:
  - `sessionTitleSection`
  - `sessionInfoSection`
  - `speakerSection`
  - `aboutSection`
  - `scheduleActionSection`
- [x] Keep the content in a `ScrollView` so landscape and Dynamic Type remain safe.

## Task 2: Navigation Bar and Toolbar

- [x] Keep the default navigation back button and do not hide the system navigation bar.
- [x] Set `.navigationTitle("Session Details")`.
- [x] Use `.navigationBarTitleDisplayMode(.inline)`.
- [x] Keep the existing trailing toolbar item with `FavouriteButtonView(talk: talk)`.
- [x] Ensure the toolbar favourite keeps its existing accessibility label, value, hint, and 44 x 44 point target.

## Task 3: Time and Location Rows

- [x] Replace the current single `HStack` with two `SessionInfoRow` style rows.
- [x] Use icon tiles, label text, and value text:
  - clock icon for time
  - map pin icon for location
- [x] Make the location row a `NavigationLink` to `LocationNavigationID`.
- [x] Add stable identifiers:
  - `sessionDetail.time`
  - `sessionDetail.location`

## Task 4: Speaker Card Section

- [x] Add uppercase heading "Speaker" or "Speakers" depending on speaker count.
- [x] Present each speaker in a card-style `NavigationLink`.
- [x] Reuse `SpeakerRowView` where possible, or create a private speaker card if the current row styling does not match the reference.
- [x] Preserve speaker detail navigation and hint.
- [x] Add identifier `sessionDetail.speaker.<speakerID>`.

## Task 5: About Section

- [x] Add uppercase heading "About This Session".
- [x] Present `talk.talkDescription` with readable body text.
- [x] Ensure text grows naturally for accessibility Dynamic Type.
- [x] Add identifier `sessionDetail.about`.

## Task 6: Bottom Schedule Action

- [x] Add a prominent full-width button:
  - "Add to Schedule" when not favourite.
  - "Remove from Schedule" when favourite.
- [x] Use the same underlying model operations and feedback as the favourite star.
- [x] Avoid inaccessible duplication:
  - The top star can remain the quick icon control.
  - The bottom button should have a clear visible label and `accessibilityInputLabels`.
- [x] Add identifier `sessionDetail.scheduleAction`.

## Task 7: Tests and Docs

- [x] Update or add UI test assertions for:
  - `sessionDetail.time`
  - `sessionDetail.location`
  - `sessionDetail.about`
  - `sessionDetail.scheduleAction`
- [x] Keep existing audit tests passing where the simulator allows.
- [x] Update `docs/accessibility_audits/README.md` with:
  - redesigned session detail layout
  - duplicate favourite controls and why both are accessible
  - manual checks for VoiceOver, Voice Control, Dynamic Type, dark mode, Increase Contrast, and Reduce Transparency

## Verification

Use XcodeBuildMCP, not raw `xcodebuild`, unless MCP is unavailable:

1. `session_show_defaults`
2. `build_run_sim`
3. Focused `test_sim` for any updated UI tests

Expected:

- Build/run succeeds on the configured iPhone 17 simulator.
- UI tests either pass or, if the known simulator UI-test timeout recurs, the timeout is documented separately from compile/build status.

Result on 2026-05-11:

- `build_run_sim` succeeded on the configured iPhone 17 simulator.
- Focused UI test `MythConf26UITests/testSessionDetailUsesAccessibleDetailSections` passed.

## Open Decisions Before Implementation

- The top bar decision is resolved: use the standard system navigation bar with inline title "Session Details" and keep the favourite star in the trailing toolbar.
- Whether the bottom schedule button should coexist with the toolbar star in all size classes. Recommendation: keep both; they serve different users and mirror common detail-screen patterns.
