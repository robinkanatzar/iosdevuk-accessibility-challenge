# Session Card Favourite Target Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore full-width session cards while keeping a separate accessible favourite target.

**Architecture:** Keep `ParallelSessionsRowView` as the row layout owner and change `ParallelTalkCardView` so the card and favourite star are sibling controls in an overlay-style composition. The visual result should look like one full-width card, while hit testing and accessibility still expose the favourite action separately.

**Tech Stack:** SwiftUI, Xcode build verification, `a11y-check`, iOS Simulator screenshot verification.

---

### Task 1: Restore Full-Width Session Card Composition

**Files:**
- Modify: `MythConf/MythConf26/Programme/ParallelTalkCardView.swift`
- Modify: `MythConf/MythConf26/Favourites/FavouriteButtonView.swift`

- [ ] **Step 1: Confirm the existing visual regression**

Run the app on the simulator and inspect My Schedule with favourited talks. The current implementation shows the session card and favourite button as visibly separate columns, narrowing title text and making the card look worse than the original design.

- [ ] **Step 2: Make the card and favourite button visual siblings inside one card area**

In `ParallelTalkCardView`, replace the top-level `HStack` with a `ZStack(alignment: .bottomTrailing)`:

```swift
ZStack(alignment: .bottomTrailing) {
    NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
        cardContent
    }
    .accessibilityLabel("\(session.sessionType.displayName): \(talk.talkTitle)")
    .accessibilityValue("\(session.timeRange), \(speakers), \(locationName), \(isFavourite ? "Favourited" : "Not favourited")")
    .accessibilityHint("Shows session details")
    .accessibilityAction(named: isFavourite ? "Remove from favourites" : "Add to favourites") {
        toggleFavourite()
    }
    .buttonStyle(.plain)

    FavouriteButtonView(talk: talk)
        .padding(.trailing, 14)
        .padding(.bottom, 14)
}
```

- [ ] **Step 3: Reserve trailing title space for the star target**

In `cardContent`, give the inner text stack enough trailing padding so the title, speaker, and location do not render beneath the overlaid star:

```swift
.padding(.leading, 16)
.padding(.top, 16)
.padding(.trailing, 72)
.padding(.bottom, 52)
```

- [ ] **Step 4: Keep the favourite star visually lightweight**

In `FavouriteButtonView`, apply `.buttonStyle(.plain)` to avoid the large detached default button background. Keep the existing 44 x 44 point frame, labels, hints, input labels, value, and selected trait.

- [ ] **Step 5: Verify automated checks**

Run:

```bash
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build
a11y-check MythConf/MythConf26 --format json --per-view --no-trend
```

Expected:

- Xcode build exits 0 with `** BUILD SUCCEEDED **`.
- `a11y-check` reports score 100, grade A+, 0 errors, and 0 warnings.

- [ ] **Step 6: Verify the visual regression on simulator**

Install and launch the rebuilt app on the booted simulator:

```bash
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/MythConf26-hiznyojkiztecwcpgltokqnmosrq/Build/Products/Debug-iphonesimulator/MythConf26.app
xcrun simctl launch booted cjp.com.MythConf26
xcrun simctl io booted screenshot session-card-option-c-after.png
```

Expected:

- My Schedule cards look full-width again.
- The favourite star appears inside the lower trailing area of the card.
- Long titles wrap naturally without being squeezed by a detached button column.
