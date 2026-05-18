
# Judging Matrix

| Category | Improvements | Where to verify |
|---|---|---|
| Vision | VoiceOver labels, values, hints, headings, spoken time ranges, grouped elements, decorative image hiding, non-colour cues | Programme, Session Detail, Speakers, Locations, My Schedule |
| Mobility | Larger favourite target, button/link traits, custom favourite action, clearer navigation targets | Talk cards, Favourite button, Speaker links, Location links |
| Cognitive | Programme day summary, saved schedule summary, conflict warnings, clearer empty states, section headings | Programme, My Schedule, Session Detail |
| Creativity | Accessible conference companion features, schedule conflict detection, reusable conference accessibility layer | My Schedule, Accessibility helpers |
| Quality | Focused helper layer, focused session detail section views, no third-party dependencies, preserved visual design | Code review |
| Overall experience | End-to-end flow works across Programme, details, saving, personal schedule, speakers, and venues | Manual 10-minute evaluation path |
| Hearing bonus | Non-audio haptic feedback for favourite changes | Favourite button on device |
| Speech bonus | Voice Control input labels for key actions and destinations | Tabs, Favourite, Speakers, Locations, Social links |

## Detailed verification script

### 1. Programme

Expected:

- Day picker announces each day clearly.
- Day summary announces day number, date, talks, and activities.
- Time ranges are spoken naturally.
- Parallel sessions are individually navigable.
- At accessibility text sizes, parallel sessions stack vertically.

### 2. Talk card

Expected:

- Announces session type, title, speakers, time, location, and saved state.
- Double tap opens detail.
- Actions rotor includes Add to favourites or Remove from favourites.
- Voice Control can target Favourite / Save / Star.

### 3. Session detail

Expected:

- Talk title is a heading.
- Time and location are clear.
- Location link opens venue details.
- Speaker links open speaker profiles.
- Abstract has a heading.

### 4. My Schedule

Expected:

- Empty state is clear when no sessions are saved.
- Saved schedule summary announces number of saved sessions.
- Conflict warning appears if multiple saved sessions overlap in the same time slot.
- Conflict warning announces affected talks.

### 5. Speakers

Expected:

- Speaker rows announce useful context.
- Speaker detail has clear headings.
- Speaker photos do not create duplicate noise in lists.
- Social links announce destination and browser behaviour.

### 6. Locations

Expected:

- Location rows announce venue name and description.
- Map is represented as a meaningful venue map rather than a confusing collection of map elements.
- Venue description is readable.

## Risk control

- No new third-party dependencies.
- No broad architectural rewrite.
- No custom fonts.
- No visual redesign beyond accessibility-specific additions.
- Changes are local to existing features plus a small accessibility helper layer.
