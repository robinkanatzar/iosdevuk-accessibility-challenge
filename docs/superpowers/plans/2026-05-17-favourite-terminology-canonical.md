# Favourite Terminology Canonical Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `favourite` the canonical app action/state term while keeping the tab and destination name as `My Schedule`.

**Architecture:** Keep the existing favourite model API and storage as the source of truth. Treat "favourite" as the action/state and "My Schedule" as the user-facing collection where favourited sessions appear. Do not implement `isScheduled`, `addToSchedule`, or `removeFromSchedule`; instead, clean up inconsistent schedule wording so controls, VoiceOver, Voice Control, Siri, TipKit, tests, and docs consistently explain that favouriting a session adds it to the user's schedule.

**Tech Stack:** SwiftUI, App Intents, TipKit, XCTest UI tests, existing `ViewModel`, existing `favourites.json` persistence, XcodeBuildMCP for build/test verification.

---

## Decision

This plan supersedes `docs/superpowers/plans/2026-05-11-schedule-terminology-renaming.md` if the product decision is to keep `favourite` as canonical.

Use this terminology:

- Action: `Favourite` / `Unfavourite`
- State: `Favourited` / `Not favourited`
- Destination: `My Schedule`
- Explanation: favourited sessions appear in `My Schedule`

Keep this visible text unchanged:

```swift
Label("My Schedule", systemImage: "star")
.navigationTitle("My Schedule")
```

## File Map

Modify:

- `MythConf/MythConf26/Favourites/FavouriteButtonView.swift`
  - Keep the type name.
  - Keep the star affordance.
  - Make labels and input labels consistently favourite-based.

- `MythConf/MythConf26/Favourites/FavouriteToggleFeedback.swift`
  - Keep the type name unless there is already conflicting schedule wording from previous work.

- `MythConf/MythConf26/Programme/ParallelTalkCardView.swift`
  - Keep `isFavourite`.
  - Use favourite state in accessibility values and custom actions.
  - Keep hints that explain the user's schedule destination.

- `MythConf/MythConf26/Programme/SessionDetailView.swift`
  - Rename local schedule action title/copy to favourite action title/copy.
  - Keep the toolbar star and bottom button.

- `MythConf/MythConf26/MySchedule/MyScheduleView.swift`
  - Keep tab/screen name `My Schedule`.
  - Keep empty state wording that explains there are no favourites yet.

- `MythConf/MythConf26/AppIntents/ConferenceSessionStore.swift`
  - Keep favourite store names.
  - Keep `favourites.json`.

- `MythConf/MythConf26/AppIntents/ConferenceSessionIntents.swift`
  - Rename add/remove intents and Siri phrases toward favourite terminology while preserving `Read My Schedule`.

- `MythConf/MythConf26/Tips/MythConfTips.swift`
  - Explain that tapping the star favourites a session and keeps it in the user's schedule.

- `MythConf/MythConf26UITests/MythConf26UITests.swift`
  - Assert favourite labels and values, while leaving My Schedule navigation tests intact.

- `docs/accessibility_audits/README.md`
  - Record the terminology decision as an accessibility clarity improvement.

Do not modify:

- `MythConf/MythConf26/HomeView.swift` tab label `My Schedule`.
- `favourites.json` file name or on-disk format.
- `Model/conf.json`.

## Task 1: Keep model and persistence favourite-based

**Files:**
- Modify: `MythConf/MythConf26/Model/ViewModel.swift`
- Modify: `MythConf/MythConf26/AppIntents/ConferenceSessionStore.swift`

- [ ] **Step 1: Keep the current model API**

The app model should keep these names:

```swift
var favouritesBySession: [[Session]] = []
var favouriteIds: [UUID] = []

func loadFavourites()
func saveFavourites()
func addFavourite(talk: Talk)
func removeFavourite(talk: Talk)
func isFavourite(talk: Talk) -> Bool
```

Expected behavior:

- No `scheduledIds`, `scheduledBySession`, `loadSchedule`, `addToSchedule`, `removeFromSchedule`, or `isScheduled` APIs are introduced.
- Existing code that reads and writes favourite state remains close to the persisted file name.

- [ ] **Step 2: Keep App Intent storage favourite-based**

The intent store should keep these names:

```swift
private static let favouritesFileName = "favourites.json"

static func favouriteSessions() -> [ConferenceSessionEntity]
static func favouriteIDs() -> [UUID]
static func addFavourite(_ id: UUID) throws -> Bool
static func removeFavourite(_ id: UUID) throws -> Bool
```

Expected behavior:

- Siri and the app keep sharing the same persisted favourites.
- No migration is required.

## Task 2: Standardize favourite control accessibility

**Files:**
- Modify: `MythConf/MythConf26/Favourites/FavouriteButtonView.swift`

- [ ] **Step 1: Keep the favourite button type and state**

Use:

```swift
struct FavouriteButtonView: View {
    @Environment(ViewModel.self) private var viewModel
    let talk: Talk

    private var isFavourite: Bool {
        viewModel.isFavourite(talk: talk)
    }
}
```

Expected behavior:

- The type name and state match the canonical favourite term.
- The visible star remains the visual affordance.

- [ ] **Step 2: Use favourite labels with My Schedule hints**

Use:

```swift
.accessibilityLabel(isFavourite ? "Remove \(talk.talkTitle) from favourites" : "Add \(talk.talkTitle) to favourites")
.accessibilityValue(isFavourite ? "Favourited" : "Not favourited")
.accessibilityHint(isFavourite ? "Removes this session from your schedule" : "Adds this session to your schedule")
```

Expected behavior:

- VoiceOver announces the action/state as favourite.
- The hint explains why this affects the user's schedule.

- [ ] **Step 3: Keep useful Voice Control input labels**

Use this pattern for the star button:

```swift
.accessibilityInputLabels(isFavourite
    ? ["Unfavourite", "Remove from favourites", "Star", talk.talkTitle]
    : ["Favourite", "Add to favourites", "Star", talk.talkTitle]
)
```

Expected behavior:

- On a detail screen, `Favourite`, `Unfavourite`, and `Star` are valid because there is one current session.
- In repeated card contexts, `talk.talkTitle` gives Voice Control a title-specific disambiguation path.
- `Star` remains available because it matches the visible icon the user sees.

## Task 3: Standardize programme card semantics

**Files:**
- Modify: `MythConf/MythConf26/Programme/ParallelTalkCardView.swift`

- [ ] **Step 1: Keep `isFavourite` state**

Use:

```swift
private var isFavourite: Bool {
    viewModel.isFavourite(talk: talk)
}
```

- [ ] **Step 2: Keep favourite state in the accessibility value**

Use:

```swift
.accessibilityValue(
    "\(session.liveStatus(now: Date()).title), \(session.timeRange), \(speakers), \(locationName), \(isFavourite ? "Favourited" : "Not favourited")"
)
```

- [ ] **Step 3: Use favourite custom actions**

Use:

```swift
.accessibilityAction(named: isFavourite ? "Remove from favourites" : "Add to favourites") {
    toggleFavourite()
}
```

Expected behavior:

- Cards use favourite state consistently.
- The custom action still lets VoiceOver users favourite without moving to the star control.

## Task 4: Standardize session detail bottom action

**Files:**
- Modify: `MythConf/MythConf26/Programme/SessionDetailView.swift`

- [ ] **Step 1: Rename the visible bottom action to favourite wording**

Use:

```swift
private var favouriteActionTitle: String {
    isFavourite ? "Remove from Favourites" : "Add to Favourites"
}
```

- [ ] **Step 2: Use favourite accessibility labels and values**

Use:

```swift
private var favouriteActionAccessibilityLabel: String {
    isFavourite ? "Remove \(talk.talkTitle) from favourites" : "Add \(talk.talkTitle) to favourites"
}
```

On the button:

```swift
.accessibilityLabel(favouriteActionAccessibilityLabel)
.accessibilityValue(isFavourite ? "Favourited" : "Not favourited")
.accessibilityHint(isFavourite ? "Removes this session from your schedule" : "Adds this session to your schedule")
```

- [ ] **Step 3: Keep detail-screen input labels short**

Use:

```swift
.accessibilityInputLabels(isFavourite
    ? ["Unfavourite", "Remove from favourites", "Star", talk.talkTitle]
    : ["Favourite", "Add to favourites", "Star", talk.talkTitle]
)
```

Expected behavior:

- On the detail screen, the current session provides context.
- A user can say `Tap Star`, matching the visible icon.
- A user can also say `Favourite` or `Unfavourite`.

## Task 5: Keep My Schedule as destination copy

**Files:**
- Modify: `MythConf/MythConf26/MySchedule/MyScheduleView.swift`
- Review: `MythConf/MythConf26/HomeView.swift`

- [ ] **Step 1: Keep the tab and navigation title**

Keep:

```swift
Label("My Schedule", systemImage: "star")
.navigationTitle("My Schedule")
```

- [ ] **Step 2: Keep empty state favourite-based**

Use:

```swift
ContentUnavailableView(
    "No Favourites Yet",
    systemImage: "star",
    description: Text("Tap the star on any session in the Programme to add it to your schedule.")
)
```

Expected behavior:

- The screen says what is missing: favourites.
- The destination name remains `My Schedule`.

## Task 6: Standardize Siri/App Intents

**Files:**
- Modify: `MythConf/MythConf26/AppIntents/ConferenceSessionIntents.swift`

- [ ] **Step 1: Use favourite action intent names**

Use:

```swift
struct FavouriteSessionIntent: AppIntent
struct UnfavouriteSessionIntent: AppIntent
struct ReadMyScheduleIntent: AppIntent
```

- [ ] **Step 2: Use favourite spoken confirmations**

Use:

```swift
return .result(dialog: IntentDialog("Favourited \(session.title). It is now in your schedule."))
return .result(dialog: IntentDialog("Removed \(session.title) from favourites. It is no longer in your schedule."))
```

- [ ] **Step 3: Keep My Schedule read intent wording**

Keep:

```swift
static var title: LocalizedStringResource = "Read Your Schedule"
Summary("Read your schedule")
```

- [ ] **Step 4: Use shortcut phrases that match the chosen vocabulary**

Use:

```swift
"Favourite \(\.$session) in \(.applicationName)"
"Unfavourite \(\.$session) in \(.applicationName)"
"Read my schedule in \(.applicationName)"
"What is on my schedule in \(.applicationName)"
```

Expected behavior:

- Siri action vocabulary is favourite-based.
- Reading the saved collection remains schedule-based.

## Task 7: Standardize TipKit copy

**Files:**
- Modify: `MythConf/MythConf26/Tips/MythConfTips.swift`

- [ ] **Step 1: Keep tip state favourite-based**

Use:

```swift
static var hasSavedFavourite = false
```

- [ ] **Step 2: Explain the relationship to My Schedule**

Use:

```swift
Text("Tap the star to favourite sessions and keep them in your schedule.")
```

Expected behavior:

- The tip teaches the star action.
- The tip explains where favourited sessions appear.

## Task 8: Update tests

**Files:**
- Modify: `MythConf/MythConf26UITests/MythConf26UITests.swift`

- [ ] **Step 1: Keep favourite label test expectations**

Use:

```swift
func testFavouriteButtonLabelChangesAfterToggle() throws {
    openTab(.programme)

    let addButton = firstButton(labelBeginningWith: "Add ")
    XCTAssertTrue(addButton.waitForExistence(timeout: 5))
    XCTAssertTrue(addButton.label.contains("to favourites"))

    addButton.tap()

    let removeButton = firstButton(labelBeginningWith: "Remove ")
    XCTAssertTrue(removeButton.waitForExistence(timeout: 5))
    XCTAssertTrue(removeButton.label.contains("from favourites"))
}
```

- [ ] **Step 2: Keep My Schedule tests**

Keep assertions that the tab and navigation title are `My Schedule`.

Expected behavior:

- Tests prove favourite controls use favourite wording.
- Tests preserve `My Schedule` as the collection name.

## Task 9: Update documentation

**Files:**
- Modify: `docs/accessibility_audits/README.md`

- [ ] **Step 1: Document the terminology decision**

Add:

```markdown
- Standardized the saved-session action as "favourite" while keeping "My Schedule" as the destination for favourited sessions.
- Kept favourite state values such as "Favourited" and "Not favourited" so VoiceOver announces the current state clearly.
```

- [ ] **Step 2: Add manual verification**

Add:

```markdown
- VoiceOver and Voice Control should make the relationship clear: favouriting a session adds it to your schedule, and unfavouriting removes it from your schedule.
```

## Task 10: Verify

**Files:**
- All files updated in Tasks 1-9

- [ ] **Step 1: Show XcodeBuildMCP defaults**

Run: `session_show_defaults`

Expected:

- Project path points to `MythConf/MythConf26.xcodeproj`.
- Scheme is `MythConf26`.
- Simulator is configured.

- [ ] **Step 2: Build and run**

Run: `build_run_sim`

Expected:

- Build succeeds.
- App launches on the configured simulator.

- [ ] **Step 3: Run focused UI tests**

Run `test_sim` with:

```swift
extraArgs: ["-only-testing:MythConf26UITests/MythConf26UITests/testFavouriteButtonLabelChangesAfterToggle"]
```

Expected:

- The favourite label test passes.

- [ ] **Step 4: Manual assistive technology spot checks**

Check:

- VoiceOver on Programme card: state includes `Favourited` or `Not favourited`.
- VoiceOver custom action: `Add to favourites` or `Remove from favourites`.
- Voice Control on detail screen: `Tap Star`, `Tap Favourite`, or `Tap Unfavourite` works.
- Voice Control on Programme/My Schedule: title-specific star buttons can be disambiguated.

## Task 11: Commit

**Files:**
- All files changed in Tasks 1-10

- [ ] **Step 1: Commit the terminology cleanup**

```bash
git add MythConf/MythConf26/Favourites/FavouriteButtonView.swift \
    MythConf/MythConf26/Favourites/FavouriteToggleFeedback.swift \
    MythConf/MythConf26/Programme/ParallelTalkCardView.swift \
    MythConf/MythConf26/Programme/SessionDetailView.swift \
    MythConf/MythConf26/MySchedule/MyScheduleView.swift \
    MythConf/MythConf26/AppIntents/ConferenceSessionStore.swift \
    MythConf/MythConf26/AppIntents/ConferenceSessionIntents.swift \
    MythConf/MythConf26/Tips/MythConfTips.swift \
    MythConf/MythConf26UITests/MythConf26UITests.swift \
    docs/accessibility_audits/README.md \
    docs/superpowers/plans/2026-05-17-favourite-terminology-canonical.md
git commit -m "Standardize favourite terminology"
```

Expected:

- The commit keeps favourite as canonical and preserves `My Schedule` as the destination name.
