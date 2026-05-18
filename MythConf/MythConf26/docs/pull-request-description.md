# Accessible Conference Companion: VoiceOver, Voice Control, Dynamic Type, Schedule Status, and Conflict Warnings

## Summary

This PR improves the MythConf / iOSDevUK app as an accessible conference companion.

The goal is not only to make individual controls announce correctly, but to make the real conference experience easier to navigate: browsing the programme, understanding time slots, saving sessions, detecting schedule conflicts, opening speaker profiles, and finding venues.

## What changed

### Reusable accessibility layer

Added a small conference-specific accessibility helper layer under:

- `MythConf26/Accessibility/ConferenceAccessibilityRole.swift`
- `MythConf26/Accessibility/View+ConferenceAccessibility.swift`
- `MythConf26/Accessibility/AccessibleTimeRange.swift`
- `MythConf26/Accessibility/SessionAccessibilitySummary.swift`
- `MythConf26/Accessibility/ViewModel+Accessibility.swift`

This keeps labels, values, hints, traits, Voice Control input labels, decorative image handling, and spoken time ranges consistent without adding dependencies or changing the app architecture.

### Programme

- Added a Programme day summary with day number, date, talk count, and activity count.
- Improved spoken time ranges.
- Improved talk card labels to include session type, title, speaker, time, location, and saved state.
- Added VoiceOver custom actions for adding/removing favourites from talk cards.
- Adapted parallel sessions for accessibility Dynamic Type sizes by switching from horizontal to vertical layout.
- Added non-colour cues for breaks, lunch, registration, rail trip, and social activities.

### Session detail

- Split the detail screen into focused section views:
  - `SessionDetailHeaderView`
  - `SessionDetailSpeakersSectionView`
  - `SessionDetailAbstractSectionView`
- Added headings for rotor navigation.
- Improved time, location, speaker, and abstract semantics.
- Added clearer location and speaker link semantics.

### My Schedule

- Added a saved schedule status card.
- Added schedule conflict detection for overlapping saved sessions.
- Added a conflict warning view listing affected sessions.
- Improved empty state semantics.

### Speakers

- Improved speaker row semantics.
- Hid decorative speaker photos from list VoiceOver output.
- Exposed speaker portrait labels where useful.
- Improved social link labels, hints, and Voice Control input labels.
- Added headings for speaker detail sections.

### Locations

- Improved venue list link semantics.
- Grouped the map into a meaningful venue map element.
- Improved venue description semantics.

### Favourite button

- Increased effective hit target to at least 44pt.
- Added clear saved / not saved value.
- Added Voice Control input labels.
- Added haptic feedback for add/remove favourite actions.

### Documentation and tests

Added:

- `README-ACCESSIBILITY.md`
- `docs/judging-matrix.md`
- `docs/manual-accessibility-audit.md`
- Unit tests for:
  - `AccessibleTimeRange`
  - `SessionAccessibilitySummary`
  - `ScheduleConflictDetector`

## Judging categories

### Vision

- VoiceOver labels, values, hints, headings, and grouped elements.
- Natural spoken time ranges.
- Decorative images hidden where appropriate.
- Map represented with meaningful venue context.
- Parallel session layout adapts for accessibility text sizes.
- Break/activity rows no longer rely on colour alone.

### Mobility

- Larger favourite button target.
- Clear button and link traits.
- Custom favourite actions available from talk cards.
- Major actions have clear hints and predictable navigation.

### Cognitive

- Programme day summary.
- My Schedule status summary.
- Schedule conflict warning.
- Clear empty state.
- Section headings across detail screens.
- More predictable reading order.

### Creativity

- Adds accessible conference-planning support, not just generic labels.
- Detects overlapping saved sessions.
- Builds a small conference-specific accessibility layer without adding dependencies.

### Quality

- No third-party dependencies.
- Original visual design is preserved.
- Session detail is split into focused views.
- Core accessibility logic is tested.
- Manual accessibility audit is documented.

### Overall experience

The end-to-end flow is now more accessible:

1. Browse Programme.
2. Understand time slots.
3. Open session details.
4. Save sessions.
5. Review My Schedule.
6. Detect conflicts.
7. Open speaker profiles.
8. Open social links.
9. Find venues.

### Hearing bonus

- Favourite add/remove actions include non-audio haptic feedback.

### Speech bonus

- Voice Control input labels added for key actions and destinations, including Favourite, Save, Star, tab names, speaker names, talk titles, venue names, and social links.

## How to verify

### Fast path

1. Run the app.
2. Enable VoiceOver.
3. Open Programme.
4. Move through the day picker, day summary, time slots, and talk cards.
5. Open a session detail page.
6. Add and remove a favourite.
7. Open My Schedule.
8. Review saved schedule status and conflict warnings.
9. Open Speakers and speaker detail.
10. Open Locations and a venue detail page.

### Dynamic Type

1. Enable Larger Accessibility Sizes.
2. Increase text size.
3. Open Programme.
4. Confirm parallel sessions stack vertically.

### Differentiate Without Color

1. Enable Differentiate Without Color.
2. Open Programme.
3. Confirm break/activity rows include symbol, text, and border cues.

### Voice Control

Try:

- “Tap Favourite”
- “Tap Save”
- “Tap Programme”
- “Tap Speakers”
- “Tap Locations”
- “Tap My Schedule”
- “Tap [speaker name]”
- “Tap [venue name]”

### Tests

Run the test suite and confirm the accessibility helper tests pass.

## Notes

This PR intentionally avoids broad visual redesign. The focus is inclusive interaction, readable semantics, Dynamic Type resilience, and conference-specific planning support.
