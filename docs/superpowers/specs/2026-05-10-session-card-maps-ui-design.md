# Session Card and Maps Button UI Design

Date: 2026-05-10

## Goal

Improve the MythConf session card UI to match the supplied `Errors/card.png` reference while preserving accessibility as the top priority. Also improve the location detail Maps action using the compact button direction from the visual companion.

## Approved Direction

- **Session cards:** use the **Recommended: Reference Style, Adaptive** direction.
- **Maps button:** use the **Compact** direction.

## Session Card Design

The existing `ParallelTalkCardView` will be restyled into a softer reference-style card:

- Pale adaptive card background.
- Strong blue top accent bar.
- Uppercase outlined session type chip.
- Larger, clearer title hierarchy.
- Speaker and location metadata rows with SF Symbols.
- Separate circular favourite button in the top trailing area.
- Rounded corners and a subtle border/shadow that works in light and dark mode.

The card will continue to be used by both Programme and My Schedule because both screens already share `ParallelTalkCardView`.

## Maps Button Design

`LocationDetailView` will keep the current functional button behavior but use a compact visual treatment:

- Full-width rounded button/card under the venue description.
- Leading copy that identifies the action, such as "Open in Maps".
- Compact supporting text such as "Use Apple Maps for directions".
- Trailing map/arrow SF Symbol or compact icon treatment.
- Clear visual affordance without taking as much space as the session card.

## Accessibility Requirements

Accessibility remains the primary acceptance criterion:

- The session card remains one navigation target with a clear VoiceOver label, value, hint, and custom favourite action.
- The favourite star remains a separate visible 44 x 44 point target with unique labels and Voice Control input labels.
- The Maps button remains a real `Button`, not a decorative card, with label `Open [location] in Maps`.
- The Maps button keeps the TipKit popover and invalidates the Maps tip when tapped.
- Dynamic Type must not clip title, speaker, location, or button text.
- At accessibility Dynamic Type sizes, metadata should stack vertically and the card should grow rather than compress.
- The design must support dark mode, Increase Contrast, Reduce Transparency, and Bold Text where practical.
- Information must not be conveyed by color alone; the session type remains visible text.

## Implementation Plan

1. Introduce reusable styling helpers only if they reduce duplication inside the touched views.
2. Update `ParallelTalkCardView`:
   - Add Dynamic Type-aware layout for reference card styling.
   - Move the session type into a visible chip.
   - Use icon + text metadata rows.
   - Preserve existing accessibility identifiers and labels.
   - Keep `FavouriteButtonView` as the separate favourite control.
3. Update `LocationDetailView`:
   - Replace the current bordered-prominent button styling with the compact Maps action card/button.
   - Preserve `openURL`, TipKit invalidation, and accessibility label behavior.
4. Update tests where needed:
   - Keep `openInMapsElement(for:)` passing by preserving the button label.
   - Add or update assertions only if identifiers or labels change.
   - Re-run build and the focused accessibility/UI tests if the simulator allows.
5. Update `docs/accessibility_audits/README.md` with the UI/accessibility changes and manual verification notes.

## Verification Plan

Automated:

- `xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build`
- Focused UI tests for Programme, Locations, My Schedule populated state, and favourite label changes.

Manual/human:

- Compare the Programme and My Schedule cards against `Errors/card.png`.
- Check the compact Maps button on a location detail screen.
- Verify VoiceOver labels/actions for session card, favourite button, and Maps button.
- Verify Voice Control names for the favourite and Maps controls.
- Check largest accessibility Dynamic Type sizes for card title and metadata.
- Check dark mode, Increase Contrast, and Reduce Transparency.

## Out of Scope

- Changing conference data.
- Adding new session actions.
- Reworking tab navigation.
- Replacing MapKit map behavior.
- Changing Siri or TipKit functionality beyond preserving current behavior.

## Open Risk

The current UI test runner has previously hung in Xcode's simulator launch/debugger layer. Build verification is reliable; UI test verification should still be attempted, but a simulator/Xcode hang should be documented separately from app failures.
