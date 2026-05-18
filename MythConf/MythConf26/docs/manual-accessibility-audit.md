# Manual Accessibility Audit

This audit documents the manual checks performed for the iOSDevUK / MythConf accessibility improvements.

The checks follow the competition judging areas: Vision, Mobility, Cognitive, Creativity, Quality, Overall experience, plus Hearing and Speech bonus opportunities.

## Test environment

- App: MythConf26
- Platform: iOS Simulator and device where available
- Assistive technologies:
  - VoiceOver
  - Voice Control
  - Larger Text / Accessibility Dynamic Type
  - Differentiate Without Color
  - Increase Contrast
  - Reduce Motion
  - Dark Mode

## 1. Programme

### VoiceOver

| Check | Result | Notes |
|---|---|---|
| Day picker announces each day clearly | ✅ | Each segment includes day number and day label |
| Day summary is announced before sessions | ✅ | Summary includes day number, date, talk count, and activity count |
| Time ranges are spoken naturally | ✅ | `AccessibleTimeRange` provides spoken range text |
| Talk cards announce useful context | ✅ | Includes type, title, speaker, time, location, and saved state |
| Favourite action is available from talk card | ✅ | Custom accessibility action adds/removes favourite |
| Reading order starts with time, then sessions | ✅ | Sort priority applied to time and talk cards |

### Dynamic Type

| Check | Result | Notes |
|---|---|---|
| Parallel sessions remain readable | ✅ | Accessibility text sizes switch from horizontal to vertical layout |
| Important text remains available | ✅ | Talk title, speaker, location, and favourite action remain reachable |

### Differentiate Without Color

| Check | Result | Notes |
|---|---|---|
| Break/activity type is not only colour | ✅ | Rows include SF Symbol, text label, border, and VoiceOver label |
| Session type remains understandable | ✅ | Activity rows include explicit type text when differentiate-without-colour is enabled |

## 2. Session Detail

### VoiceOver

| Check | Result | Notes |
|---|---|---|
| Talk title is a heading | ✅ | Supports rotor navigation |
| Time is announced as time | ✅ | Uses visual and spoken time range |
| Location link is clear | ✅ | Announces destination and map behaviour |
| Speaker links are clear | ✅ | Each speaker opens a speaker detail page |
| Abstract has a heading | ✅ | Supports quick navigation |

### Structure

| Check | Result | Notes |
|---|---|---|
| View remains maintainable | ✅ | Detail page split into focused section views |
| Accessibility logic is reusable | ✅ | Uses shared accessibility helpers |

## 3. My Schedule

### VoiceOver

| Check | Result | Notes |
|---|---|---|
| Empty state is clear | ✅ | Explains how to add favourites |
| Saved session count is announced | ✅ | Schedule status card summarizes saved sessions |
| Conflict warnings are announced | ✅ | Overlapping saved sessions are grouped and described |
| Day headers are headings | ✅ | Supports rotor navigation |

### Cognitive support

| Check | Result | Notes |
|---|---|---|
| User can understand schedule state quickly | ✅ | Status card explains whether schedule is ready |
| Overlapping sessions are visible | ✅ | Conflict warning lists affected sessions |

## 4. Speakers

### VoiceOver

| Check | Result | Notes |
|---|---|---|
| Speaker rows announce useful information | ✅ | Speaker name and bio excerpt are grouped |
| Speaker photos avoid duplicate noise in lists | ✅ | Decorative by default |
| Speaker detail photo has meaningful label | ✅ | Detail page can expose portrait label |
| Sessions section is a heading | ✅ | Supports rotor navigation |
| Social links announce destination | ✅ | Links include service name and browser hint |

### Voice Control

| Check | Result | Notes |
|---|---|---|
| Social links are targetable | ✅ | Input labels include service names and open commands |
| Speaker rows are targetable | ✅ | Input labels include speaker names |

## 5. Locations

### VoiceOver

| Check | Result | Notes |
|---|---|---|
| Location rows announce name and description | ✅ | Navigation links include venue context |
| Map has meaningful context | ✅ | Map is grouped as venue map rather than noisy map internals |
| Venue description is readable | ✅ | Description has grouped accessibility label |

### Voice Control

| Check | Result | Notes |
|---|---|---|
| Venue rows are targetable | ✅ | Input labels include venue names and “Location” / “Venue” |

## 6. Favourite Button

### Mobility

| Check | Result | Notes |
|---|---|---|
| Hit target is at least 44pt | ✅ | Button image frame uses minimum 44x44 |
| State is clear | ✅ | Value announces Saved / Not saved |
| Action is clear | ✅ | Label changes between Add and Remove |

### Hearing bonus

| Check | Result | Notes |
|---|---|---|
| State change has non-audio feedback | ✅ | Add/remove favourite triggers haptic feedback |

### Speech bonus

| Check | Result | Notes |
|---|---|---|
| Voice Control can target action | ✅ | Input labels include Favourite, Save, Star, and talk title |

## 7. Top-level Navigation

| Check | Result | Notes |
|---|---|---|
| Programme tab has clear purpose | ✅ | Browse conference sessions by day |
| Speakers tab has clear purpose | ✅ | Browse speaker profiles and sessions |
| Locations tab has clear purpose | ✅ | Browse venues and maps |
| My Schedule tab has clear purpose | ✅ | Review saved sessions and conflicts |

## Known limitations

- The PR intentionally avoids broad visual redesign.
- The PR does not introduce third-party accessibility testing frameworks.
- Map interaction remains simple; the focus is on making venue context understandable.
- Captions and audio descriptions are not applicable because the app does not contain audio or video content.

## Summary

The app is now more usable as an accessible conference companion:

- VoiceOver users get structured headings, natural time ranges, grouped cards, and useful hints.
- Dynamic Type users get an adaptive layout for parallel sessions.
- Voice Control users get targetable labels for major actions and destinations.
- Users who cannot rely on colour get symbols, text, and borders.
- Users planning their day get saved schedule status and conflict warnings.
