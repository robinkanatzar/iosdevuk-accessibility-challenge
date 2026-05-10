# Session Card and Maps Button UI Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle session cards to match the adaptive reference card and restyle the Maps action as a compact accessible button.

**Architecture:** Keep the existing view structure: `ParallelTalkCardView` remains the shared Programme/My Schedule card, and `LocationDetailView` remains the location detail screen. Update visual styling in place while preserving accessibility identifiers, labels, hints, custom actions, TipKit behavior, and real button/navigation controls.

**Tech Stack:** SwiftUI, TipKit, MapKit, XCTest UI accessibility audits, XcodeBuildMCP simulator verification.

---

### Task 1: Restyle Session Card

**Files:**
- Modify: `MythConf/MythConf26/Programme/ParallelTalkCardView.swift`

- [x] **Step 1: Add adaptive design environment**

Add `dynamicTypeSize`, `colorScheme`, and `legibilityWeight` so the card can adapt to accessibility sizes, dark mode, and Bold Text.

- [x] **Step 2: Replace the card content layout**

Change `cardContent` to a pale rounded card with a blue top accent, uppercase chip, large title, and metadata rows using `person` and `mappin.circle` symbols.

- [x] **Step 3: Preserve accessibility behavior**

Keep the `NavigationLink` label, value, hint, custom favourite action, and `programme.card.*` identifier. Keep `FavouriteButtonView` as a separate target with `programme.favourite.*`.

### Task 2: Restyle Maps Button

**Files:**
- Modify: `MythConf/MythConf26/Locations/LocationDetailView.swift`

- [x] **Step 1: Replace bordered button styling**

Convert the current bordered-prominent button into a full-width compact Maps action button with leading text and trailing icon.

- [x] **Step 2: Preserve action semantics**

Keep the button label as `Open [location] in Maps`, keep `openURL(mapsURL)`, keep TipKit invalidation, and add a stable accessibility identifier.

### Task 3: Update Documentation

**Files:**
- Modify: `docs/accessibility_audits/README.md`

- [x] **Step 1: Document UI/accessibility changes**

Add notes that session cards were restyled with adaptive layout and the Maps action was restyled while preserving accessible controls.

- [x] **Step 2: Document human verification**

Add manual checks for the reference-style card, compact Maps button, Dynamic Type, VoiceOver, Voice Control, dark mode, Increase Contrast, and Reduce Transparency.

### Task 4: Verify

**Files:**
- Test: `MythConf/MythConf26UITests/MythConf26UITests.swift`

- [x] **Step 1: Build with XcodeBuildMCP**

Run XcodeBuildMCP `session_show_defaults`, configure only if needed, then build/run or build using simulator defaults.

- [x] **Step 2: Run focused UI tests if available**

Use XcodeBuildMCP `test_sim` for focused Programme, Locations, My Schedule populated, and favourite-label tests. If the simulator launch layer hangs, document the Xcode/MCP failure separately from app build status.

- [x] **Step 3: Review test impact**

No test label change is expected because the Maps button label and session/favourite identifiers remain stable. Update tests only if verification proves an identifier or label changed.

## Verification Result

- XcodeBuildMCP `build_run_sim` succeeded for scheme `MythConf26` on the configured iPhone 17 simulator.
- XcodeBuildMCP `test_sim` timed out after 120 seconds for both the focused accessibility set and a single lightweight favourite-label UI test. This appears to be the simulator/UI-test launch timeout already documented for this project, not a Swift compile failure.
- No XCTest source changes were required because the Maps button keeps the same accessible label and existing card/favourite identifiers remain stable.
