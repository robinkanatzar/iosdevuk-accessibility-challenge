# Accessibility Input Labels Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up `accessibilityInputLabels` after the favourite terminology decision so Voice Control users get natural, visible, and disambiguating command names.

**Architecture:** This plan depends on `docs/superpowers/plans/2026-05-17-favourite-terminology-canonical.md` being implemented first. Keep `Favourite`, `Unfavourite`, and `Star` as valid input labels where they match the current visual context. Add session-title alternatives for repeated controls so Voice Control users can target the intended star when multiple session cards are visible.

**Tech Stack:** SwiftUI accessibility modifiers, XCTest UI tests, XcodeBuildMCP for build/test verification.

---

## Dependency

Run this plan only after the favourite terminology plan is complete:

```text
docs/superpowers/plans/2026-05-17-favourite-terminology-canonical.md
```

Expected canonical terms:

```swift
FavouriteButtonView
FavouriteToggleFeedback
viewModel.isFavourite(talk:)
viewModel.addFavourite(talk:)
viewModel.removeFavourite(talk:)
```

Do not rename these to schedule terminology in this plan.

## Input Label Policy

Use this policy throughout implementation:

- `Favourite`, `Unfavourite`, and `Star` are allowed on the session detail screen because the current session provides context.
- `Star` is allowed because it matches the visible icon and supports the natural command "Tap Star".
- Repeated controls in Programme and My Schedule must also include a session-specific input label such as `Favourite [session title]`, `Unfavourite [session title]`, or `[session title]`.
- `accessibilityInputLabels` should be short command aliases. They do not replace descriptive `accessibilityLabel`, `accessibilityValue`, and `accessibilityHint`.

## File Map

Modify:

- `MythConf/MythConf26/Favourites/FavouriteButtonView.swift`
  - Keep `Favourite`, `Unfavourite`, and `Star`.
  - Add title-specific input labels for repeated contexts.

- `MythConf/MythConf26/Programme/ParallelTalkCardView.swift`
  - Add `Open [talk title]` as a navigation-card input label.
  - Keep the custom favourite action favourite-based.

- `MythConf/MythConf26/Programme/SessionDetailView.swift`
  - Keep simple detail-screen labels such as `Favourite`, `Unfavourite`, and `Star`.
  - Add the title as a fallback alias.

- `MythConf/MythConf26UITests/MythConf26UITests.swift`
  - Keep favourite label assertions and add checks that labels do not include role words.

- `docs/accessibility_audits/README.md`
  - Document the Voice Control input-label decision.

Review but do not change unless verification shows a problem:

- `MythConf/MythConf26/Programme/ProgrammeView.swift`
  - Existing day-picker input labels are correct because they provide short day, full date, and ordinal day alternatives.

- `MythConf/MythConf26/Speakers/SocialLinksView.swift`
  - Existing social-link input labels are correct because they provide both service-only and speaker-specific alternatives.

## Task 1: Improve favourite star input labels

**Files:**
- Modify: `MythConf/MythConf26/Favourites/FavouriteButtonView.swift`

- [ ] **Step 1: Keep visible-icon and action aliases**

Use this pattern:

```swift
.accessibilityInputLabels(isFavourite
    ? [
        "Unfavourite",
        "Remove from favourites",
        "Unfavourite \(talk.talkTitle)",
        "Remove \(talk.talkTitle) from favourites",
        talk.talkTitle,
        "Star"
    ]
    : [
        "Favourite",
        "Add to favourites",
        "Favourite \(talk.talkTitle)",
        "Add \(talk.talkTitle) to favourites",
        talk.talkTitle,
        "Star"
    ]
)
```

Expected behavior:

- On a detail screen, `Tap Star`, `Tap Favourite`, or `Tap Unfavourite` works naturally.
- On repeated Programme/My Schedule cards, title-specific aliases reduce ambiguity.
- The input labels stay favourite-based and do not introduce schedule as the action term.

- [ ] **Step 2: Keep the primary label descriptive**

Use:

```swift
.accessibilityLabel(isFavourite ? "Remove \(talk.talkTitle) from favourites" : "Add \(talk.talkTitle) to favourites")
.accessibilityValue(isFavourite ? "Favourited" : "Not favourited")
.accessibilityHint(isFavourite ? "Removes this session from your schedule" : "Adds this session to your schedule")
```

Expected behavior:

- VoiceOver gets full context.
- Voice Control gets short aliases.
- The hint explains the user's schedule destination.

## Task 2: Improve session card input labels

**Files:**
- Modify: `MythConf/MythConf26/Programme/ParallelTalkCardView.swift`

- [ ] **Step 1: Add an action-oriented input label to the navigation card**

Replace:

```swift
.accessibilityInputLabels([talk.talkTitle])
```

with:

```swift
.accessibilityInputLabels([
    talk.talkTitle,
    "Open \(talk.talkTitle)"
])
```

Expected behavior:

- Voice Control users can say the session title or `Open [session title]`.
- The navigation card remains separate from the favourite star.

- [ ] **Step 2: Keep the custom action favourite-based**

Use:

```swift
.accessibilityAction(named: isFavourite ? "Remove from favourites" : "Add to favourites") {
    toggleFavourite()
}
```

Expected behavior:

- VoiceOver custom actions match the chosen vocabulary.
- No custom action uses schedule as the action term.

## Task 3: Improve session detail bottom action input labels

**Files:**
- Modify: `MythConf/MythConf26/Programme/SessionDetailView.swift`

- [ ] **Step 1: Use detail-context-friendly input labels**

For the detail screen's bottom favourite action, use:

```swift
.accessibilityInputLabels(isFavourite
    ? ["Unfavourite", "Remove from favourites", "Star", talk.talkTitle]
    : ["Favourite", "Add to favourites", "Star", talk.talkTitle]
)
```

Expected behavior:

- `Tap Star` works because the button visually uses a star/favourite convention.
- `Tap Favourite` or `Tap Unfavourite` works because the current session is the screen context.
- The talk title remains available as a fallback alias.

- [ ] **Step 2: Keep value and hint clear**

Use:

```swift
.accessibilityValue(isFavourite ? "Favourited" : "Not favourited")
.accessibilityHint(isFavourite ? "Removes this session from your schedule" : "Adds this session to your schedule")
```

Expected behavior:

- The value says the current state.
- The hint explains why the action affects the user's schedule.

## Task 4: Add focused UI assertions

**Files:**
- Modify: `MythConf/MythConf26UITests/MythConf26UITests.swift`

- [ ] **Step 1: Keep favourite label assertions**

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

Expected behavior:

- XCTest verifies the primary accessibility labels remain favourite-based.
- The test does not attempt to inspect `accessibilityInputLabels` directly, because XCTest does not reliably expose every input alias.

- [ ] **Step 2: Keep the visible-button role regression**

Keep:

```swift
XCTAssertFalse(
    button.label.lowercased().contains(" button"),
    "Button label should not include its role: \(button.label)"
)
```

Expected behavior:

- Favourite label cleanup does not add role words such as "button".

## Task 5: Update accessibility documentation

**Files:**
- Modify: `docs/accessibility_audits/README.md`

- [ ] **Step 1: Add a Voice Control note**

Add:

```markdown
- Updated Voice Control input labels for favourite controls so the visible star can still be targeted with "Star", while repeated session cards also expose title-specific commands such as "Favourite [session title]".
```

- [ ] **Step 2: Add a human verification item**

Add:

```markdown
- Voice Control "Show Names" on Programme and My Schedule should expose favourite controls with usable star and session-specific names; on a detail screen, "Tap Star" should target the current session's favourite control.
```

Expected behavior:

- The docs explain why `Star` remains intentional.
- Manual review covers the part XCTest cannot fully prove.

## Task 6: Verify

**Files:**
- All files changed in Tasks 1-5

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

- The focused favourite-label test passes.

- [ ] **Step 4: Manual Voice Control spot check**

Enable Voice Control in the simulator or on device and open Programme.

Say:

```text
Show Names
```

Expected:

- Session cards can be targeted by talk title or `Open [talk title]`.
- Favourite star buttons expose either `Star` plus number disambiguation or title-specific favourite names.

Open a session detail screen and say:

```text
Tap Star
```

Expected:

- Voice Control toggles the current session's favourite state.

## Task 7: Commit

**Files:**
- All files changed in Tasks 1-6

- [ ] **Step 1: Commit the cleanup**

```bash
git add MythConf/MythConf26/Favourites/FavouriteButtonView.swift \
    MythConf/MythConf26/Programme/ParallelTalkCardView.swift \
    MythConf/MythConf26/Programme/SessionDetailView.swift \
    MythConf/MythConf26UITests/MythConf26UITests.swift \
    docs/accessibility_audits/README.md \
    docs/superpowers/plans/2026-05-16-accessibility-input-labels-cleanup.md
git commit -m "Improve favourite Voice Control labels"
```

Expected:

- The commit contains only the input-label cleanup and related docs/tests.
- The favourite terminology decision remains in its own earlier commit.
