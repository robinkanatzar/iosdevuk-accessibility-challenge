# iOSDevUK Accessibility Challenge 2026

Welcome to the iOSDevUK Accessibility Challenge! 
Your mission, if you choose to accept, is to make the iOSDevUK conference app more accessible. (See MythConf/ in this repo for the code)
You'll have from May 7th until May 21st (GAAD) to work on the code and submit a pull request on this repo.

For more details, including judging criteria, you can check out [this link](https://www.iosdevuk.com/competition).

For all other questions, you can [email me at hello@robinkanatzar.com](mailto:hello@robinkanatzar.com)

Best of luck to you all!

---

## Accessibility Improvements

The following changes have been made to the MythConf app to improve its accessibility across Apple's Human Interface Guidelines categories.

### Creativity & engineering depth

A handful of changes warrant separate billing because they go beyond applying a SwiftUI modifier — they involve research, custom helpers, or coordination across multiple system behaviours.

**`AccessibilityAnnouncer` — reliable VoiceOver announcements with retry** (`AccessibilityAnnouncer`, `FavouriteButtonView`, `SpeakersView`)\
`UIAccessibility.post(notification: .announcement, ...)` is best-effort: iOS frequently drops announcements posted while VoiceOver is still speaking other feedback (a button's activation tick, a focus change, a navigation transition). The new helper:
1. Posts each announcement as an `NSAttributedString` with `.accessibilitySpeechQueueAnnouncement: true` so it queues behind in-flight speech rather than fighting with it.
2. Delays the post by ~0.4s so VoiceOver's own activation feedback can finish first.
3. Observes `UIAccessibility.announcementDidFinishNotification` and re-posts up to twice if the system reports the announcement was unsuccessful.

The helper is used both for the favourite-toggle confirmation and for the speaker-search result-count announcement.

**`labelOverride` pattern — coordinating a custom announcement with VoiceOver auto-labels** (`FavouriteButtonView`)\
When a button's accessibility label changes (e.g. "Add to favourites" → "Remove from favourites"), VoiceOver auto-announces the new label, which would interrupt and overlap the custom message. A `labelOverride: Bool?` state variable freezes the button's accessibility label at its pre-tap value for four seconds. The custom message plays cleanly; once the freeze lifts, VoiceOver naturally re-reads the button with its updated label if focus remains on it. The icon and colour update instantly — only the spoken label is held — so sighted users never see a delay.

**Defensive `ViewModel` lookups** (`ViewModel`)\
The talk, speaker, and location lookup helpers used the `confData.X.filter{ $0.id == id }[0]` pattern, which trap-crashes the entire app on any missing reference. They now use `first(where:)` with safe fallback strings ("Speaker to be announced", "Location to be announced") and an `assertionFailure` so bad references still surface loudly during development. The same change replaces the hand-rolled "A and B" join (which silently truncated talks with three or more speakers) with `formatted(.list(type: .and))`, producing locale-aware "A, B, and C" output.

**Enlarged touch target with corner-anchored visible icon** (`FavouriteButtonView`, `ParallelTalkCardView`)\
The favourite button's hit area is 88×88 points — double the HIG minimum. To avoid stretching the talk card layout, the visible star is anchored to the bottom-right corner of the hit area, and the talk card reserves only ~28pt of bottom space (scaled with Dynamic Type). The remaining 60pt of invisible hit area extends up over text but doesn't push layout, giving users with reduced dexterity a generous target without bloating the cards.

**Differentiated haptics** (`FavouriteButtonView`)\
Add fires `.success`; remove fires `.impact(weight: .light)`. Two distinguishable patterns let a user without sight or sound tell which action occurred — not just that something happened.

**VoiceOver-friendly time formatter** (`Session`)\
The visible 24-hour two-digit time strings ("09:30", "14:00") are read by speech engines as digit streams ("zero nine thirty", "fourteen zero zero"). `Session.accessibilityTimeText` reformats to 12-hour AM/PM, strips the colon (which speech engines render as a pause), and elides the minute digits entirely on the hour, so "16:00" reads as "4 PM" rather than "four zero zero". The exact contract is pinned by six Swift Testing cases including an exhaustive sweep of every session in `conf.json`.

**Reduce Motion suppression of discrete symbol effects** (`FavouriteButtonView`)\
`.symbolEffectsRemoved(_:)` only governs *indefinite* symbol effects, so the favourite-star `.bounce` still played when the user had Reduce Motion on. `FavouriteButtonView` now reads `@Environment(\.accessibilityReduceMotion)` and conditionally omits the `.symbolEffect` modifier from the view tree entirely, so the star changes state with no animation under Reduce Motion. The fix and the underlying SDK gotcha are documented in code so future contributors don't reach for the wrong API.

**Per-URL splitting of speaker social links, official brand icons, 50pt targets** (`SocialLinksView`, `Assets.xcassets`)\
The bundled conference data packs multiple URLs into a single `SocialItem.socialLink` field separated by newlines. `URL(string:)` is lenient enough to accept the combined string, but the resulting URL has embedded newlines and the system cannot open it — leaving Voice Control commands like "Open GitHub" producing no result. `SocialLinksView` now splits each `socialLink` on newlines and renders one icon-only `Link` per URL in a wrapping `LazyVGrid` of 50×50pt cells — above the HIG 44pt minimum and comfortably finger-sized. Each link carries a host-derived friendly accessibility label ("GitHub", "LinkedIn", "Mastodon", "Bluesky", "Twitter / X") exposed via `.accessibilityLabel` and `.accessibilityInputLabels`, so VoiceOver and Voice Control announce and target each profile independently. The generic web/blog bucket is announced as "Website" rather than the raw "Www" token so speech engines don't spell it character-by-character. Glyph resolution is two-tier: the official brand glyphs are loaded from `Assets.xcassets` (`social-github`, `social-linkedin`, `social-mastodon`, `social-bluesky`, `social-twitter-x`, `social-website`) as template images that inherit `foregroundStyle(.primary)` for light/dark mode; SF Symbols are used as a fallback for unknown brands. The original packing bug was surfaced by `SpeakerAccessibilityTests.everySocialLinkParsesAsAURL` in the Tier 1 test suite.

### Vision

**Speaker photos now have text alternatives** (`SpeakerPhotoView`)\
Every speaker photo is labelled with the speaker's name (e.g. "Jane Smith's profile photo"). When no personal photo is available the fallback image is labelled "Profile photo not available". Previously the images were invisible to VoiceOver, giving users no indication of whose photo they were viewing.

**Map view now has an accessible description** (`LocationDetailView`)\
The interactive map on each location detail screen is labelled "Map showing the location of [Venue Name]" with a hint directing users to the text description below. The embedded `Marker` was originally leaking through as VoiceOver's focused element — the system supplied its own "shows more info" trait that shadowed the outer label and hint. `.accessibilityElement()` is now applied to the Map ahead of the label/hint, collapsing the marker subtree so the custom hint is what VoiceOver speaks.

**Time and venue announced together on session detail** (`SessionDetailView`)\
The time element on the session-detail screen previously read only "Time 9:30 AM to 10:15 AM"; the venue was a separate focus stop further along the row. The time's accessibility label is now extended to include the venue name ("Time 9:30 AM to 10:15 AM, at Tilsley Theatre") so the first focus stop gives both pieces in one announcement, while the venue `NavigationLink` remains a separate, independently tappable focus stop.

**Increase Contrast warnings on tab bar and pinned headers resolved** (`HomeView`, `MyScheduleView`)\
Materials are always translucent — even `.thickMaterial` lets enough of the scrolling content through to fail Accessibility Inspector's contrast threshold. When `colorSchemeContrast == .increased`, `HomeView` applies `.toolbarBackground(.visible, for: .tabBar)` so the Liquid Glass tab bar renders opaque, and the pinned section headers in `MyScheduleView` swap to a fully opaque `Color(.systemBackground)`. Users who haven't opted into Increase Contrast keep Apple's intended translucent look.

**Break and social rows convey type without relying on colour alone** (`BreakRowView`)\
Rows such as Lunch, Tea Break, and Conference Dinner used a tinted background as the only visual distinction between session types. Each row now has a combined accessibility label that reads the session type and time range aloud (e.g. "Lunch, 12:30 to 14:00"), making the information available to users who cannot perceive colour.

**Increased Contrast and Reduce Transparency adaptation** (`ParallelTalkCardView`, `BreakRowView`)\
When the user has enabled Increase Contrast or Reduce Transparency in Settings, the tinted card and row backgrounds increase from 10–12% opacity to 25%, and talk cards gain a visible colour border. This ensures session-type colours remain distinguishable for users with low vision without relying on the default faint tinting.

**Decorative dividers hidden from VoiceOver** (`DayScheduleView`, `SpeakerDetailView`)\
Horizontal divider lines are decorative separators with no semantic meaning. They are now marked as hidden from the accessibility tree, removing unnecessary noise from VoiceOver navigation.

**Speaker rows and talk summary cards read as single elements** (`SpeakerRowView`, `TalkSummaryView`)\
A speaker row (photo + name + bio excerpt) and a talk summary card (title + time + location) each previously fragmented into multiple separate VoiceOver focus stops. Each composite element is now grouped so VoiceOver reads all the information in a single announcement, reducing the effort needed to scan a list.

**Talk card includes time so VoiceOver gives complete information on focus** (`ParallelTalkCardView`, `ParallelSessionsRowView`)\
The session time was previously rendered in a separate left-hand column outside each talk card, so VoiceOver users had to focus the time element and the card element separately to understand a row. The time has been moved to the top-left of each card, the time column has been removed, and the card's accessibility label now reads "Talk from 09:30 to 10:15: [title], by [speakers], [location]" — giving the full context in a single focus stop.

**Talk card layout scales with Dynamic Type** (`ParallelTalkCardView`, `TimeColumnView`)\
The time column inside each talk card uses `@ScaledMetric` so its minimum width grows with the user's chosen text size, preventing the start and end times from truncating at AX text sizes. The reserved space at the bottom of each card (kept clear so the favourite star is not on top of the location text) also scales with Dynamic Type so the icon stays out of the way at every size.

**Caption text on tinted backgrounds passes WCAG contrast at default contrast** (`AccessibilityModifiers`, applied across `ParallelTalkCardView`, `BreakRowView`, `TimeColumnView`, `SpeakerRowView`, `TalkSummaryView`, `LocationsView`, `LocationDetailView`, `SessionDetailView`, `UpNextCardView`)\
A reusable `contrastAdaptiveSecondary()` modifier replaces every `.foregroundStyle(.secondary)` on text that sits on tinted backgrounds. The modifier originally rendered `.secondary` and only lifted to `.primary` when the user had Increase Contrast on, but a re-audit using Accessibility Inspector flagged the talk-card end time, speakers and location captions plus the Up Next card header as below the WCAG 4.5:1 threshold at default contrast — Inspector audits the default state, where `.secondary` sits below 4.5:1 over a 10 %-opacity card tint. The modifier now renders `.primary` unconditionally; visual hierarchy is carried by font size and weight rather than colour, which is the HIG-recommended pattern. The Up Next card header (`UpNextCardView`) keeps the colour identity on the status icon (orange dot for live, accent clock otherwise) and switches the header text to `.primary` for the same reason.

**Differentiate Without Color** (`SessionType`, `BreakRowView`, `ParallelTalkCardView`)\
Each session type now has an associated SF Symbol (`cup.and.saucer` for tea, `fork.knife` for lunch, `train.side.front.car` for the rail trip, and so on). The break row shows the symbol alongside the type name as a permanent shape-based cue. When the user enables Differentiate Without Color, talk cards and break rows additionally render a stroked colour border so session type can be distinguished by shape and outline rather than fill alone.

**Favourite star backed by material for legibility on tinted cards** (`FavouriteButtonView`)\
The yellow star previously sat directly on the tinted card background and could vanish on lightning-talk cards (yellow on yellow). The star now sits on a circular `.regularMaterial` backing with a more contrasty orange fill, keeping it readable on every session-type colour while preserving the conventional gold-star metaphor for "favourite".

### Mobility

**Favourite button has an enlarged touch target on the programme list** (`FavouriteButtonView`, `ParallelTalkCardView`)\
On every talk card in the programme schedule — the high-volume entry point where users scan and favourite multiple sessions in succession — the favourite button uses an 88×88-point hit area, double the HIG minimum. Users with reduced dexterity, tremor, or limited fine motor control can comfortably activate it. The visible star is anchored to the bottom-right corner of the hit area, and the card reserves a small (Dynamic-Type-aware) bottom space so the enlarged target does not bloat the layout. A `compact` variant of the same button is used in the `SessionDetailView` toolbar where conventional iOS toolbar sizing applies; users who need the larger target can still favourite from the programme list at the 88pt size.

**Accessibility announcement on favourite toggle** (`FavouriteButtonView`)\
When a talk is added to favourites, VoiceOver announces "Added to favourites. Switch to My Schedule to see all your saved sessions." When removed, it announces "Removed from favourites." This gives VoiceOver users immediate confirmation of the action and directs them to the My Schedule tab, which already shows all saved sessions in order — achieving the same goal as in-list navigation without relying on complex rotor mechanics.

**Voice Control input label on the favourite button** (`FavouriteButtonView`)\
Voice Control users can activate the favourite button by saying "Tap Favourite", "Tap Star", or "Tap Save" rather than having to recite the full accessibility label. When several talk cards are visible Voice Control will number them automatically.

**Voice Control input label on talk cards** (`ParallelTalkCardView`)\
The card's full accessibility label is over seventy characters long (session type + time + title + speakers + location). `.accessibilityInputLabels` has been set to just the talk title so a Voice Control user can say "Tap [Talk Title]" instead.

**Tab bar input labels** (`HomeView`)\
Each tab carries multiple natural input labels — "Programme" / "Schedule" / "Sessions", "Speakers" / "People", "Locations" / "Map" / "Venues", "My Schedule" / "Favourites" / "Saved" — so a Voice Control user can say whichever phrase comes naturally to them rather than having to remember the exact tab title.

**Venue link on session detail meets the 44pt minimum** (`SessionDetailView`)\
The venue `NavigationLink` was a Label whose natural height is ~22pt at default font sizes — under the HIG 44pt minimum and flagged by Accessibility Inspector as a too-small hit region. `.frame(minHeight: 44)` and `.contentShape(.rect)` enlarge the tappable rectangle to 44pt so the entire row catches taps rather than just the text glyphs.

### Cognitive

**Section headings announce as headers** (`SpeakerDetailView`, `MyScheduleView`)\
The "Sessions" heading on speaker detail pages and the day headings on My Schedule now carry the `.isHeader` accessibility trait. VoiceOver users can navigate by headings using the rotor, letting them jump straight to key sections without reading every element on screen.

**Each speaker social profile is its own labelled link** (`SocialLinksView`)\
Speakers with multiple sites (GitHub, Mastodon, LinkedIn, Bluesky, personal website) are now rendered as one icon-only `Link` per URL in a 50×50pt grid, each labelled with the host-derived network name ("GitHub", "Mastodon", "LinkedIn", "Bluesky", "Twitter / X", "Website") and hinted as "Opens in browser". VoiceOver and Voice Control users can address each profile individually — "Tap GitHub", "Tap LinkedIn" — instead of being shown a single combined entry that previously couldn't open at all because of newlines packed into the data string. The generic catch-all bucket is announced as "Website" rather than the raw "Www" token so speech engines don't spell it character-by-character.

**Favourite button label conveys state and hint explains its action** (`FavouriteButtonView`)\
The accessibility label flips between "Add to favourites" and "Remove from favourites" so VoiceOver users hear the current state directly without an extra "Selected" announcement on top. The button also carries a hint ("Adds this session to your saved schedule" / "Removes this session from your saved schedule") so users understand the consequence of activating it before they double-tap.

**Voice Control input labels for composite rows** (`SpeakerRowView`, `TalkSummaryView`)\
After grouping rows into single combined elements, Voice Control users activate them by speaking a label. `.accessibilityInputLabels` has been set to the speaker name and talk title respectively, so users can say the shortest, most natural command (e.g. "tap Jane Smith") rather than having to speak a long combined description.

**Hints across navigable rows** (`SpeakerRowView`, `TalkSummaryView`, `ParallelTalkCardView`, `LocationsView`, `SessionDetailView`)\
Every navigable row now has an `.accessibilityHint` describing the consequence of activating it: "Opens speaker profile", "Opens session details", "Opens venue details and map". This sets the user's expectation before they double-tap, reducing the cognitive load of figuring out where each control will take them.

**Adaptive announcement on first favourite** (`FavouriteButtonView`)\
The "Switch to My Schedule…" guidance is helpful the first time a user adds a favourite but becomes verbose noise on every subsequent action. A persisted `hasSeenFavouritesHint` flag means the long form is spoken once per app install; afterwards, adds are confirmed with a concise "Added to favourites." Removes are always concise.

**Day picker speaks full weekday names** (`ProgrammeView`)\
The Programme day picker is a segmented control showing abbreviated weekday names ("Mon", "Tue", "Sat", "Sun") because all five days have to fit horizontally on iPhone. iOS speech engines mis-pronounce the three-letter abbreviations — "Sat" reads as the verb and "Sun" as the celestial body — so each segment now carries a separate `.accessibilityLabel` built from `.weekday(.wide)` ("Saturday", "Sunday"). The visible UI stays compact; VoiceOver hears the full word.

**Search announces result count** (`SpeakersView`)\
When a user types in the speakers search field, the count of matching speakers is announced via `AccessibilityAnnouncer` (e.g. "12 speakers match"). VoiceOver users get immediate feedback on how their query is narrowing without having to navigate into the list to count results.

**Temporal context throughout the Programme and My Schedule** (`SessionLiveStatus`, `ConferencePhase`, `ConferencePhaseBannerView`, `ParallelTalkCardView`, `UpNextCardView`)\
A conference attendee's highest-frequency cognitive question is "where am I in the schedule, and what's next on my list?". Three new pieces answer it without making the user compute time from clock readings:

- A **conference phase banner** at the top of the Programme tab reads `ConfData.phase(now:)` and renders "Conference starts in 3 days" / "Day 2 of 3" / "Conference has ended", with a phase-tinted background and the `.isHeader` accessibility trait so it appears in the VoiceOver heading rotor.
- Each talk card gains a **"Now" / "In N min" badge** in the corner when the session is currently underway or starting within 15 minutes. The same status is prepended to the card's accessibility label ("Now. Workshop from 2 PM to 4 PM: ...") so VoiceOver users hear the temporal context before the rest of the announcement.
- The **My Schedule tab promotes the user's next favourited session** to the top of the screen when it's currently live or starting within the next two hours. The promoted card flips its header from "UP NEXT" to "ON NOW" as the start time passes, and reads "Up next. <title>, at <venue>. Starts in 12 minutes." or "On now. <title>, at <venue>. Ends at 4 PM." for VoiceOver. Hidden outside the window so the screen stays quiet when nothing imminent is on the list.

All three reactive pieces share a single `TimelineView(.everyMinute)` so the views roll over automatically as time passes — no manual refresh, no `Timer` plumbing. Every factory and formatter takes an explicit `now: Date` argument so the logic is fully testable without depending on the real wall clock. A new `TemporalContextTests` suite pins thirteen boundary cases including the round-up at sub-minute intervals, the midnight day-rollover, and the empty-window state.

### Hearing (bonus)

**Differentiated haptic feedback when toggling a favourite** (`FavouriteButtonView`)\
A `.success` haptic fires when a talk is added to favourites, and a lighter `.impact(weight: .light)` haptic fires when a talk is removed. Two distinct tactile patterns let a user without sight or sound tell whether the action added or removed the talk, rather than just confirming that something happened. This is a non-auditory equivalent to a paired sound cue.

---

## Bug fixes

**Favourite button independently focusable by VoiceOver** (`ParallelTalkCardView`)\
The favourite star button was originally nested inside the talk card's `NavigationLink` label and hidden from VoiceOver, with the toggle exposed only as a custom accessibility action. Custom actions require the VoiceOver Actions rotor — a non-obvious gesture that most users will not discover. The button has been moved into an overlay on the card so it sits alongside the `NavigationLink` as a sibling element. Both can now be focused and double-tapped independently: the card navigates to the session detail, the button toggles the favourite.

(See "Creativity & engineering depth" above for the announcement reliability and defensive-lookup fixes that started life as bug fixes but warrant separate billing.)

## Quality

The project includes **43 unit tests (Swift Testing)** organised into ten suites that together replace what the Accessibility Inspector audit checks at the data level — every spoken label is exercised exhaustively against the real bundled `conf.json` on every CI run:

- **`FavouritesTests`** (`@Suite(.serialized)`) — add/remove cycle, no-op remove, per-talk independence, `favouritesBySession` integrity.
- **`LookupTests`** — talk/speaker/location lookup consistency, title↔ID round trip, every talk produces a non-empty location and speaker string, multi-speaker join contract.
- **`TalkCardAccessibilityLabelTests`** — exact spoken-label shape (prefix/infix/suffix) plus a corpus check that no talk produces a malformed sentence.
- **`SessionTypeTests`** — every non-dummy `SessionType` has both a display name and an SF Symbol so the shape-based cue is always present.
- **`SessionTimeAccessibilityTests`** — six pinning tests for the 12-hour AM/PM time formatter, including exhaustive iteration over every real session in `conf.json` to confirm none contains a colon, has a leading zero, or lacks an AM/PM suffix.
- **`AccessibilityLabelExhaustivenessTests`** — iterates every talk in the data and asserts the spoken label expands every clause; placeholder fallback strings ("Talk to be announced", "Speaker to be announced", "Location to be announced") would fail the test, catching broken references in `conf.json` before they reach VoiceOver.
- **`ForbiddenStringTests`** — no `Optional(...)` leakage, no raw UUIDs, no double spaces, no leading/trailing whitespace across every accessibility string produced by `ViewModel`.
- **`SessionTypeSymbolResolutionTests`** — every declared SF Symbol resolves via `UIImage(systemName:)` at runtime, catching typo'd icon names that would otherwise surface as empty rectangles with no description.
- **`SpeakerAccessibilityTests`** — every speaker has a usable name, bios are either empty or meaningful, every newline-separated URL chunk in `socialLink` parses with a scheme, and the host-to-label routing used by `SocialLinksView` resolves the major networks (GitHub, Mastodon, LinkedIn, Bluesky, Twitter / X).
- **`TemporalContextTests`** — every boundary of `SessionLiveStatus` (more than 15 min away, exactly 15, sub-minute, at start, midway, past end), the accessibility-prefix and badge-text formatters, and `ConfData.phase(now:)` for upcoming / today / mid-conference / finished states. Every factory takes an explicit `now: Date` so the suite is fully wall-clock-independent.

Run with: `xcodebuild test -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`

The same command runs in CI on every push via [`.github/workflows/test.yml`](.github/workflows/test.yml).

Manual on-device validation results — VoiceOver, Voice Control, Increase Contrast, Differentiate Without Color, AX5 Dynamic Type, Reduce Motion, and the Accessibility Inspector audit — are recorded in [`docs/accessibility-audit.md`](docs/accessibility-audit.md), along with an appendix explaining how to reproduce each section of the audit on a device or simulator.
