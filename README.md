# iOSDevUK Accessibility Challenge 2026 — Submission

## Vision (HIG, 0–5)

- **VoiceOver reads each row, card and detail screen as one logical chunk** instead of as a stream of disconnected fragments. The talk title, speakers, location and time on a programme card all come out as a single sentence. Decorative coloured bars and dividers between rows are skipped silently.
- **Section titles act as headings.** The Headings rotor jumps cleanly between things like "Speakers", "About", "Sessions", "About this location" and the day headers in My Schedule.
- **Two custom rotors** make long screens fast to navigate: a *Favourites* rotor in the Programme tab jumps between the talks the user has starred in the day they're viewing, and a *Speakers* rotor in a session's detail page jumps between speakers (handy for panels).
- **Speaker photos are decorative**, so they're hidden from VoiceOver. The parent row already announces the speaker's name; reading "photo of Alex Morgan" right after "Alex Morgan" would just be a duplicate.
- **The map is a single labelled element** rather than a noisy MapKit subtree. VoiceOver reads "Map showing [location name]" once and stops. A prominent **Open in Apple Maps** button below the map provides an accessible alternative for users who can't or don't want to use the inline map.
- **Everything scales with the user's text size**, including speaker photos, the time column on the schedule, and the location map. At the largest accessibility text sizes, programme rows reflow so the time appears on top and the talk card sits below at full width — instead of squashing both into a narrow column.
- **A text label tells you the session type**, so users don't have to rely on the coloured bar to tell a talk from a tea break. The label sits on each card as a small capsule. When Increase Contrast is enabled the capsule darkens and gains a stroke so it stays legible.
- **Times sound natural to VoiceOver.** The visible schedule keeps 24-hour times like "15:00 – 17:00", but the spoken form is "3 PM to 5 PM" / "3:30 PM to 5:30 PM" — built manually so this works in en-GB and any other 24-hour locale, where iOS would otherwise drop the AM/PM and read "fifteen".
- **Day names sound natural too.** The day picker still shows "Sat" and "Sun" visually, but VoiceOver hears "Saturday" and "Sunday" (iOS would otherwise read "sat" / "sun" literally). In My Schedule, dates use ordinals — "Thursday, 2nd September" — so VoiceOver says "second" instead of "two".
- **The app speaks up when something changes**: it announces the new day after the picker changes, the result count after a search, "Added to favourites" / "Removed from favourites" on toggle, and which tab the user has just switched into.
- **Navigating into a detail screen resets VoiceOver focus to the top** of the new screen instead of leaving it wherever the user was on the previous one. Pushed detail pages always start at the back button / title.

## Mobility (HIG, 0–5)

- **Every tap target is at least 44×44.** The favourite-star button, each social link icon, and the Open-in-Apple-Maps button all expand to that minimum even when the visual icon is smaller.
- **One tap target per programme card.** The favourite star inside a parallel talk card looks tappable, but VoiceOver only sees the card itself — and toggles the favourite via a clear custom action ("Add to favourites" / "Remove from favourites"). That avoids the classic two-overlapping-targets confusion that hurts users on Switch Control or Voice Control.
- **No multi-finger or long-press gestures are required anywhere.** Single tap activates everything.
- **Voice Control works without "Show numbers".** Visible button labels match what VoiceOver announces, so spoken commands like "Tap Open in Apple Maps", "Tap Programme", or "Tap Add to favourites" land on the right element.
- **Layouts reflow at large text sizes** instead of clipping or hiding controls — programme cards stack vertically, social-link icons stack vertically — so every interactive element stays reachable.

## Cognitive (HIG, 0–5)

- **Every link tells you what's behind it before you tap.** A short hint on each navigation row reads "Opens speaker profile", "Opens session details", "Opens location details", or "Opens the Maps app for directions".
- **Spoken text is plain, conversational English** — "Time, 09:30 to 10:30", "Now on the Speakers screen", "Removed from favourites" — not jargon or screen-reader Morse.
- **Time comes first when reading a schedule row**, because the schedule is sorted by time. A user skimming a programme hears the time slot first ("3 PM to 4 PM") and can decide quickly whether to keep listening to the rest of the card.
- **Every state change is confirmed out loud** — day picker, search filter, favourite toggle, tab switch — so users don't have to chase focus around the screen to find out what happened.
- **Inline maps have a text fallback.** A user who finds pan-and-zoom confusing or impossible can hit "Open in Apple Maps" and get the same place in a fully-accessible system app instead.
- **Section headings and custom rotors give shortcuts** through long screens, so users don't have to memorise their position or swipe past everything to find what they need.
- **Nothing times out, flashes, or demands a gesture.** Every flow is self-paced.

## How to test

Open in Xcode 17+, run on a device. With VoiceOver on:

1. Tab between Programme / Speakers / Locations / My Schedule — hear the announcement after each switch.
2. In Programme, two-finger rotate to **Favourites**, swipe — jumps between favourited talks in the visible day.
3. In a Session detail, two-finger rotate to **Speakers**, swipe — jumps between speakers.
4. Two-finger rotate to **Headings** — jumps between section headers.
5. Toggle Larger Text → AX5: programme rows stack time-on-top, photos and map height grow.
6. Toggle Differentiate Without Color: session type is conveyed by the badge text.
7. Toggle Increase Contrast: badge background darkens with a stroke.
8. Open Voice Control → "Tap Open in Apple Maps" / "Tap Programme" — both work.
