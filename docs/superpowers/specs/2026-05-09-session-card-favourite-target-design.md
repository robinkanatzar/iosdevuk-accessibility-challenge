# Session Card Favourite Target Design

Date: 2026-05-09

## Goal

Restore the visual quality of session cards while preserving separate, accessible actions for opening a session and toggling its favourite state.

The current split-control layout makes the favourite button a sibling of the session card. That is mechanically clear for accessibility, but it narrows the card content column and makes the My Schedule screen look worse than the original full-width card.

## Chosen Direction

Use a full-width session card with an explicit 44 x 44 point favourite target visually placed inside the card area.

This follows option C from the visual companion:

- The session card keeps its full-width shape.
- The favourite star remains visibly tappable.
- Title text reserves trailing space so it does not run underneath the star.
- VoiceOver and Voice Control still get a separate favourite action.

## Component Behavior

`ParallelTalkCardView` should render as one visual card row, not as a narrow card plus a large detached button.

The card content should remain the primary navigation target for opening session details. The favourite control should be placed at the lower trailing edge of the card with a minimum 44 x 44 point target.

The favourite control should keep the current semantic behavior:

- Contextual accessibility label using the talk title.
- Favourite state as an accessibility value and selected trait.
- Hint describing that it adds or removes the session from My Schedule.
- Voice Control input labels including "Favourite" and the talk title.

The navigation card should also retain its custom accessibility action for toggling favourites, so users who focus the card can still favourite without moving to the nested visual target.

## Layout Rules

- Full-width cards should be used for single sessions and compact-width stacked parallel sessions.
- The title column should reserve trailing room for the star target.
- Long titles should wrap naturally across multiple lines.
- At accessibility Dynamic Type sizes, stacked layouts remain valid and should avoid horizontal squeezing.
- The existing compact parallel-session fix remains in place: compact-width multi-session rows stack cards vertically instead of squeezing two cards side by side.

## Verification

Automated checks:

- `xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build`
- `a11y-check MythConf/MythConf26 --format json --per-view --no-trend`

Manual checks:

- Compare My Schedule against the original full-width visual style.
- Confirm the favourite star is easy to tap.
- Confirm tapping the main card still opens session details.
- Confirm VoiceOver can operate both the card and favourite action.
- Confirm Voice Control names remain sensible for the card and favourite target.
- Check Programme and My Schedule on compact iPhone widths and large Dynamic Type.
