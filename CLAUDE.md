# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **iOSDevUK Accessibility Challenge 2026** — a competition (May 7–21, 2026, GAAD) to improve the accessibility of a SwiftUI iOS conference app called **MythConf**. The goal is to submit a pull request with accessibility improvements to this repo.

The app is in `MythConf/MythConf26/` and targets iOS with SwiftUI + Swift 6 (`@Observable`).

## Conventions

- Use **British English** spelling throughout — in user-facing strings, code comments, and identifiers (e.g. `favourites`, `colour`, `organise`).
- Follow **test-driven development**: write a failing XCTest before implementing any logic, then make it pass with the minimal change required.

## Building and Running

Open `MythConf/MythConf26.xcodeproj` in Xcode and run on simulator or device. There is no CLI build system — use Xcode or `xcodebuild`:

```bash
# Build from command line (substitute your simulator ID)
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Architecture

**Data flow:** `conf.json` (bundled) → `loadConfData()` → `ViewModel` → injected via `@Environment(ViewModel.self)` into all views.

**`ViewModel`** (`Model/ViewModel.swift`) is the single `@Observable` class passed as an environment object from `MythConfApp`. It holds the full `ConfData` and manages favourites (persisted to `favourites.json` in the Documents directory).

**`ConfData`** (`Model/ConfData.swift`) is the top-level decoded struct containing:
- `speakers: [Speaker]` — with `id: String`, photo derived from `name.replacing(" ", with: "")`
- `talks: [Talk]` — with `UUID` id, `speakerIDs: [String]`, `locationID: String`
- `locations: [Location]`
- `sessions: [[Session]]` — outer array = days, inner = time slots per day; `Session.contentIDs: [UUID]` points to talk IDs

**Navigation** uses typed `NavigationPath` values (`TalkReference`, `SpeakerNavigationID`, `LocationNavigationID`) registered through the `.conferenceNavigationDestinations()` view modifier (`Navigation/NavigationTypes.swift`). All four tabs wrap their content in `NavigationStack` and call this modifier.

**Tab structure** (`HomeView`):
- **Programme** → `ProgrammeView` (day picker) → `DayScheduleView` → `ParallelSessionsRowView` / `BreakRowView` → `SessionDetailView`
- **Speakers** → `SpeakersView` (searchable list) → `SpeakerDetailView`
- **Locations** → `LocationsView` → `LocationDetailView`
- **My Schedule** → `MyScheduleView` (filtered favourites by day)

**`SessionType`** (`Model/SessionType.swift`) enum drives display name and color for each session kind. Only `.talk` and `.workshop` `containsTalk` and navigate to `SessionDetailView`.

## Accessibility Context

The challenge is specifically about SwiftUI accessibility. Key areas already using accessibility APIs:
- `ProgrammeView` picker labels use `.accessibilityLabel`
- `FavouriteButtonView` has `.accessibilityLabel` for star toggle state

When improving accessibility, standard SwiftUI modifiers to consider: `.accessibilityLabel`, `.accessibilityHint`, `.accessibilityValue`, `.accessibilityElement(children:)`, `.accessibilityAddTraits`, `.accessibilityRemoveTraits`, Dynamic Type support, sufficient color contrast, and VoiceOver navigation order.
