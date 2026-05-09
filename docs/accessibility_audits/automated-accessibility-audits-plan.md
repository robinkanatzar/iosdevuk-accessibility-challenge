# Automated Accessibility Audits Implementation Plan

Date: 2026-05-09

## Goal

Add repeatable UI-test based accessibility audits for MythConf26 using Xcode's `performAccessibilityAudit` API, plus targeted XCTest assertions for app-specific accessibility semantics that Apple's audit cannot prove.

## References Reviewed

- Holy Swift, "Xcode 15 New Feature: Streamlined Accessibility Audits": `performAccessibilityAudit` runs from XCTest UI tests and reports issues such as contrast, element detection, hit regions, text clipping, and trait problems.
- Create with Swift, "Testing your app's accessibility in UI tests": audit the current visible UI, navigate to important screens, and use the audit closure to ignore known false positives.
- Augmented Code, "Performing accessibility audits with UI tests on iOS": run audits after launching and after navigation, and use `XCUIAccessibilityAuditType` filtering carefully.
- Local examples: `../Examples/ios-swiftui-accessibility-techniques-main/iOSswiftUIa11yTechniques/Documentation/XCTestAccessibility.md` and its UI tests. Main lesson: combine `performAccessibilityAudit()` with manual assertions for labels, duplicate labels, role words, and expected element existence. Do not rely on the audit alone for headings, decorative images, page titles, or VoiceOver order.

## Architecture

Use the existing `MythConf26UITests` target as the automation home. Keep the tests small and screen-oriented: launch, navigate to a stable screen, assert key accessibility labels/identifiers, run `performAccessibilityAudit`, scroll visible content, run again.

The audit suite should have three layers:

1. **System audits** using `XCUIApplication.performAccessibilityAudit()` on each primary screen.
2. **Semantic assertions** for labels and app-specific expectations, such as favourite button labels and "Sessions by [speaker name]".
3. **Manual verification checklist** for areas XCTest cannot validate, such as actual VoiceOver reading order, haptic/sound feedback, and Switch Control scanning.

## Files To Modify

- `MythConf/MythConf26UITests/MythConf26UITests.swift`
  - Replace the scaffold with reusable launch, navigation, audit, and assertion helpers.
- `MythConf/MythConf26UITests/MythConf26UITestsLaunchTests.swift`
  - Keep or simplify launch screenshot coverage. Do not duplicate the main audit suite.
- `MythConf/MythConf26/MythConfApp.swift`
  - Add a UI-testing reset hook so favourites start from a known state.
- `MythConf/MythConf26/HomeView.swift`
  - Add stable identifiers to tab roots if XCTest needs them.
- `MythConf/MythConf26/Programme/ProgrammeView.swift`
  - Add identifiers for the day picker and programme root.
- `MythConf/MythConf26/Programme/ParallelTalkCardView.swift`
  - Add deterministic identifiers for the session card navigation target and favourite button context.
- `MythConf/MythConf26/Speakers/SpeakersView.swift`
  - Add identifiers for the speaker list and search field context.
- `MythConf/MythConf26/Speakers/SpeakerRowView.swift`
  - Add row identifiers based on speaker id.
- `MythConf/MythConf26/Speakers/SpeakerDetailView.swift`
  - Add identifiers for the detail root and sessions heading.
- `MythConf/MythConf26/Locations/LocationsView.swift`
  - Add identifiers for location rows.
- `MythConf/MythConf26/MySchedule/MyScheduleView.swift`
  - Add identifiers for empty and populated states.
- `docs/accessibility_audits/README.md`
  - Document how to run the automated audits and what still requires human verification.

## Phase 1: Establish Stable Test Hooks

### Task 1.1: Add a UI-testing reset hook

Modify `MythConf/MythConf26/MythConfApp.swift` so UI tests can reset persisted favourites before launch:

```swift
@main
struct MythConf: App {
    @State private var viewModel = ViewModel()

    init() {
        if CommandLine.arguments.contains("-UITestingResetFavourites") {
            let favouritesURL = urlToFileInDocuments("favourites.json")
            try? FileManager.default.removeItem(at: favouritesURL)
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(viewModel)
                .foregroundStyle(.primary, .secondary, .tertiary)
        }
    }
}
```

Verification:

```sh
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: `** BUILD SUCCEEDED **`.

### Task 1.2: Add identifiers only where tests need stable navigation

Add identifiers without changing visible UI or VoiceOver wording.

Recommended identifiers:

```swift
// HomeView.swift
ProgrammeView()
    .accessibilityIdentifier("tab.programme")

SpeakersView()
    .accessibilityIdentifier("tab.speakers")

LocationsView()
    .accessibilityIdentifier("tab.locations")

MyScheduleView()
    .accessibilityIdentifier("tab.mySchedule")
```

```swift
// ProgrammeView.swift
Picker("Conference day", selection: $selectedDayIndex) { ... }
    .accessibilityIdentifier("programme.dayPicker")
```

```swift
// ParallelTalkCardView.swift
NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
    cardContent
}
.accessibilityIdentifier("programme.card.\(talk.id.uuidString)")

FavouriteButtonView(talk: talk)
    .accessibilityIdentifier("programme.favourite.\(talk.id.uuidString)")
```

```swift
// SpeakersView.swift
List(filteredSpeakers) { speaker in ... }
    .accessibilityIdentifier("speakers.list")
```

```swift
// SpeakerRowView.swift
.accessibilityIdentifier("speakers.row.\(speaker.id)")
```

```swift
// SpeakerDetailView.swift
Text("Sessions")
    .accessibilityIdentifier("speakerDetail.sessionsHeading")
```

```swift
// LocationsView.swift
NavigationLink(value: LocationNavigationID(value: location.id)) { ... }
    .accessibilityIdentifier("locations.row.\(location.id)")
```

Verification:

```sh
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: `** BUILD SUCCEEDED **`.

## Phase 2: Replace Scaffold UI Tests With Audit Harness

### Task 2.1: Create reusable launch and audit helpers

Modify `MythConf/MythConf26UITests/MythConf26UITests.swift`:

```swift
import XCTest

@MainActor
final class MythConf26UITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestingResetFavourites"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func auditVisibleScreen(
        _ name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        XCTContext.runActivity(named: "Accessibility audit: \(name)") { _ in
            if #available(iOS 17.0, *) {
                XCTAssertNoThrow(
                    try app.performAccessibilityAudit { issue in
                        isKnownFalsePositive(issue, screenName: name)
                    },
                    file: file,
                    line: line
                )
            }
        }
    }

    private func isKnownFalsePositive(
        _ issue: XCUIAccessibilityAuditIssue,
        screenName: String
    ) -> Bool {
        // Start strict. Add ignores only after a human reviews the screenshot,
        // issue description, and affected element.
        false
    }
}
```

Notes:

- Keep the false-positive list empty at first.
- If a false positive appears, add the narrowest possible filter and document it in this file with the screen name and reason.
- Avoid broad `issue.auditType == .contrast` ignores unless the team has verified the reported element is genuinely acceptable.

### Task 2.2: Add tab navigation helper

Add helpers to the same UI test file:

```swift
private enum AppTab: String {
    case programme = "Programme"
    case speakers = "Speakers"
    case locations = "Locations"
    case mySchedule = "My Schedule"
}

private func openTab(_ tab: AppTab) {
    let button = app.tabBars.buttons[tab.rawValue]
    XCTAssertTrue(button.waitForExistence(timeout: 2), "Missing tab: \(tab.rawValue)")
    button.tap()
}
```

Verification:

```sh
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Expected initially: tests compile and pass if only helpers are present.

## Phase 3: Add Screen-Level Accessibility Audits

### Task 3.1: Audit Programme

Add:

```swift
func testProgrammeAccessibilityAudit() throws {
    openTab(.programme)
    XCTAssertTrue(app.navigationBars["MythConf 2026"].waitForExistence(timeout: 2))
    XCTAssertTrue(app.segmentedControls["programme.dayPicker"].exists)

    try auditVisibleScreen("Programme initial day")

    app.swipeUp()
    try auditVisibleScreen("Programme after first scroll")

    let friday = app.buttons["Fri"]
    if friday.exists {
        friday.tap()
        try auditVisibleScreen("Programme Friday")
    }
}
```

Expected coverage:

- Navigation title exists.
- Day picker is reachable.
- Visible session cards, favourite buttons, breaks, and time columns pass Apple's audit.
- Below-the-fold content gets audited after scroll.

### Task 3.2: Audit Speakers list and detail

Add:

```swift
func testSpeakersAccessibilityAudit() throws {
    openTab(.speakers)
    XCTAssertTrue(app.navigationBars["Speakers"].waitForExistence(timeout: 2))
    XCTAssertTrue(app.collectionViews["speakers.list"].exists || app.tables["speakers.list"].exists)

    try auditVisibleScreen("Speakers list")

    let speaker = app.buttons["Sarah Thornton"].firstMatch
    XCTAssertTrue(speaker.waitForExistence(timeout: 2))
    speaker.tap()

    XCTAssertTrue(app.navigationBars["Sarah Thornton"].waitForExistence(timeout: 2))
    XCTAssertTrue(app.staticTexts["Sessions by Sarah Thornton"].exists)
    try auditVisibleScreen("Speaker detail")
}
```

Expected coverage:

- Speaker rows expose useful combined labels.
- Speaker detail photo label is not a raw asset filename.
- The sessions heading exposes the speaker context.

### Task 3.3: Audit Locations list and detail

Add:

```swift
func testLocationsAccessibilityAudit() throws {
    openTab(.locations)
    XCTAssertTrue(app.navigationBars["Locations"].waitForExistence(timeout: 2))

    try auditVisibleScreen("Locations list")

    let location = app.buttons["Tyndall Lecture Theatre"].firstMatch
    XCTAssertTrue(location.waitForExistence(timeout: 2))
    location.tap()

    XCTAssertTrue(app.navigationBars["Tyndall Lecture Theatre"].waitForExistence(timeout: 2))
    XCTAssertTrue(app.links["Open in Maps"].exists || app.buttons["Open in Maps"].exists)
    try auditVisibleScreen("Location detail")
}
```

Expected coverage:

- Location rows are combined sensibly.
- Map summary and external map action are visible to automation.

### Task 3.4: Audit My Schedule empty and populated states

Add:

```swift
func testMyScheduleAccessibilityAudit() throws {
    openTab(.mySchedule)
    XCTAssertTrue(app.navigationBars["My Schedule"].waitForExistence(timeout: 2))
    XCTAssertTrue(app.staticTexts["No Favourites Yet"].exists)
    try auditVisibleScreen("My Schedule empty")
}

func testMyScheduleWithFavouriteAccessibilityAudit() throws {
    openTab(.programme)

    let favouriteButton = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Add '")).firstMatch
    XCTAssertTrue(favouriteButton.waitForExistence(timeout: 2))
    favouriteButton.tap()

    openTab(.mySchedule)
    XCTAssertTrue(app.navigationBars["My Schedule"].waitForExistence(timeout: 2))
    XCTAssertFalse(app.staticTexts["No Favourites Yet"].exists)
    try auditVisibleScreen("My Schedule populated")
}
```

Expected coverage:

- Empty state is accessible.
- Favourited card layout is audited separately from Programme.

## Phase 4: Add App-Specific Semantic Assertions

These tests catch regressions that `performAccessibilityAudit` often misses.

### Task 4.1: Favourite button labels change after toggle

```swift
func testFavouriteButtonLabelChangesAfterToggle() throws {
    openTab(.programme)

    let addButton = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Add '")).firstMatch
    XCTAssertTrue(addButton.waitForExistence(timeout: 2))
    let addLabel = addButton.label
    XCTAssertTrue(addLabel.contains("to favourites"))

    addButton.tap()

    let removeButton = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Remove '")).firstMatch
    XCTAssertTrue(removeButton.waitForExistence(timeout: 2))
    XCTAssertTrue(removeButton.label.contains("from favourites"))
}
```

### Task 4.2: Labels should not duplicate control roles

```swift
func testVisibleButtonsDoNotRepeatButtonInLabel() throws {
    openTab(.programme)

    for index in 0..<min(app.buttons.count, 20) {
        let button = app.buttons.element(boundBy: index)
        guard button.exists else { continue }
        XCTAssertFalse(
            button.label.lowercased().contains(" button"),
            "Button label should not include its role: \(button.label)"
        )
    }
}
```

### Task 4.3: Speaker detail contextual sessions heading

```swift
func testSpeakerDetailSessionsHeadingIsContextual() throws {
    openTab(.speakers)

    let speaker = app.buttons["Sarah Thornton"].firstMatch
    XCTAssertTrue(speaker.waitForExistence(timeout: 2))
    speaker.tap()

    XCTAssertTrue(app.staticTexts["Sessions by Sarah Thornton"].waitForExistence(timeout: 2))
}
```

## Phase 5: CI and Documentation

### Task 5.1: Add run command to README

Update `docs/accessibility_audits/README.md`:

````md
## Automated UI Accessibility Audits

Run from the repository root:

```sh
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' test
```

The UI test target uses Apple's `performAccessibilityAudit` on Programme, Speakers, Locations, and My Schedule, plus targeted assertions for MythConf-specific accessibility labels.
````

### Task 5.2: Add CI command when this repo has CI

If a CI workflow is added later, run the same `xcodebuild ... test` command on a pinned simulator/runtime. Keep the destination explicit because `performAccessibilityAudit` requires iOS 17 or newer.

## False Positive Policy

Use this rule before ignoring an audit issue:

1. Capture the failing screenshot or XCTest attachment.
2. Identify the exact `auditType`, screen, and element.
3. Confirm manually that the report is a tool false positive.
4. Add the narrowest possible ignore in `isKnownFalsePositive`.
5. Document the ignore with a comment and re-run the full UI test suite.

Do not add broad ignores for entire audit types unless every instance on that screen has been manually reviewed.

## What Still Requires Human Verification

Automated UI audits do not replace manual assistive technology testing. Keep these in the human checklist:

- VoiceOver reading order across all tabs and detail screens.
- Switch Control focus order and grouping.
- Voice Control command names with "Show Names" and "Show Numbers".
- Haptic and sound feedback for favourite add/remove on a physical device.
- Real Dynamic Type behavior at the largest accessibility sizes.
- Reduce Transparency and Increase Contrast appearance.
- External Maps handoff from location detail.

## Recommended Implementation Order

1. Add UI-test reset hook.
2. Add stable identifiers for navigation and assertions.
3. Replace scaffold UI test file with audit harness.
4. Add Programme and My Schedule audits first because they cover session cards and favourite controls.
5. Add Speakers and Locations audits.
6. Add semantic assertion tests.
7. Run `xcodebuild ... test`.
8. Document any false positives or manual verification gaps.
9. Commit in two parts:
   - `Add accessibility UI audit hooks`
   - `Add automated accessibility UI audits`
