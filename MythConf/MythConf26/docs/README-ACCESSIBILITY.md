# Accessibility Improvements for MythConf / iOSDevUK 2026

This PR improves the app as an accessible conference companion, not just as a visually browsable schedule.

The work focuses on the competition judging categories: Vision, Mobility, Cognitive, Creativity, Quality, Overall experience, plus Hearing and Speech bonus opportunities.

## Fast evaluation path

1. Open the app with VoiceOver enabled.
2. Go to Programme.
3. Move through the day picker, day summary, time slots, and talk cards.
4. Open a talk detail page.
5. Add and remove a favourite.
6. Open My Schedule.
7. Review the saved schedule status and any conflict warnings.
8. Go to Speakers and open a speaker profile.
9. Open social links with VoiceOver or Voice Control.
10. Go to Locations and open a venue map.

## Highlights

### Vision

- Added consistent VoiceOver labels, values, hints, headings, and grouped elements.
- Improved time ranges with visual and spoken formats.
- Added semantic structure to Programme, session details, speakers, locations, and My Schedule.
- Added non-colour cues for breaks, lunch, registration, and social activities.
- Adapted parallel session layout for accessibility Dynamic Type sizes.

### Mobility

- Improved button and link semantics.
- Added larger favourite button hit targets.
- Added custom VoiceOver actions for saving and removing favourites.
- Improved row and card navigation with clear actions and hints.

### Cognitive

- Added Programme day summaries showing day number, date, talk count, and activity count.
- Added My Schedule status summary.
- Added schedule conflict warnings when saved sessions overlap.
- Improved empty state semantics for My Schedule.
- Added clear section headings for session details and speaker profiles.

### Creativity

- Added conference-specific schedule support instead of only generic accessibility labels.
- Introduced schedule conflict detection to help users plan their day.
- Added a small reusable conference accessibility layer without changing the app architecture or adding dependencies.

### Quality

- Accessibility helpers are isolated under `MythConf26/Accessibility`.
- Session detail UI is split into focused section views.
- Changes avoid third-party dependencies.
- The original visual design is preserved where possible.

### Hearing bonus

- Favourite add/remove actions now provide non-audio haptic confirmation.

### Speech bonus

- Added Voice Control input labels for important actions and navigation targets:
  - Favourite
  - Save
  - Star
  - Programme
  - Speakers
  - Locations
  - My Schedule
  - Speaker names
  - Talk titles
  - Venue names

## Files added

- `MythConf26/Accessibility/ConferenceAccessibilityRole.swift`
- `MythConf26/Accessibility/View+ConferenceAccessibility.swift`
- `MythConf26/Accessibility/AccessibleTimeRange.swift`
- `MythConf26/Accessibility/SessionAccessibilitySummary.swift`
- `MythConf26/Accessibility/ViewModel+Accessibility.swift`
- `MythConf26/MySchedule/ScheduleConflictDetector.swift`
- `MythConf26/MySchedule/ScheduleStatusView.swift`
- `MythConf26/MySchedule/ScheduleConflictWarningView.swift`
- `MythConf26/Programme/ProgrammeDaySummaryView.swift`
- `MythConf26/Programme/SessionDetailHeaderView.swift`
- `MythConf26/Programme/SessionDetailSpeakersSectionView.swift`
- `MythConf26/Programme/SessionDetailAbstractSectionView.swift`

## Manual test checklist

### VoiceOver

- Programme day picker announces day number and label.
- Programme day summary announces day, date, talks, and activities.
- Time ranges are spoken naturally.
- Talk cards announce type, title, speakers, time, location, and saved state.
- Favourite action is available from the talk card actions rotor.
- Session detail page has headings for title, speakers, and abstract.
- Speaker rows announce speaker name and context.
- Social links announce the destination and that they open in a browser.
- Location details announce venue name and map context.
- My Schedule announces saved session count and conflicts.

### Dynamic Type

- Increase text size to an accessibility size.
- Programme parallel sessions should stack vertically instead of becoming cramped.
- Text should remain readable without clipping important content.

### Differentiate Without Color

- Breaks and conference activities include symbols and text.
- Session type is not communicated by colour alone.

### Voice Control

Try commands such as:

- “Tap Favourite”
- “Tap Save”
- “Tap Programme”
- “Tap Speakers”
- “Tap Locations”
- “Tap My Schedule”
- “Tap [speaker name]”
- “Tap [venue name]”

### Haptics

- Add a favourite.
- Remove a favourite.
- Confirm that each action gives non-audio feedback on device.

## Notes

This PR intentionally keeps the app close to the original visual design. The focus is on inclusive interaction, readable semantics, Dynamic Type resilience, and conference-specific planning support.
