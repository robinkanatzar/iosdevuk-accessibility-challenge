# TipKit Feature Discovery Implementation Plan

Date: 2026-05-10

## Recommendation

Add a small set of contextual TipKit tips for existing MythConf features that are useful but easy to miss:

1. **Save Sessions**
   - Anchored to the favourite star.
   - Explains that the star saves sessions into My Schedule.
   - Invalidates after the first successful add to favourites.

2. **Switch Days**
   - Anchored to the Programme day picker.
   - Explains that the Programme screen can browse each conference day.
   - Invalidates after the selected day changes.

3. **Find a Speaker**
   - Inline at the top of the Speakers list.
   - Explains that the list can be searched by speaker name.
   - Invalidates after the user enters search text.

4. **Open in Maps**
   - Anchored to the location detail Maps button.
   - Explains that venue details can be handed off to Apple Maps.
   - Invalidates after the user opens Maps.

These tips are deliberately limited to high-impact discovery points. They do not add new app features and they avoid turning every tab or row into onboarding.

## Implemented Files

Created:

- `MythConf/MythConf26/Tips/MythConfTips.swift`

Modified:

- `MythConf/MythConf26/MythConfApp.swift`
- `MythConf/MythConf26/Programme/ProgrammeView.swift`
- `MythConf/MythConf26/Favourites/FavouriteButtonView.swift`
- `MythConf/MythConf26/Programme/SessionDetailView.swift`
- `MythConf/MythConf26/Speakers/SpeakersView.swift`
- `MythConf/MythConf26/Locations/LocationDetailView.swift`
- `docs/accessibility_audits/README.md`

## Tip Definitions

The app stores each tip's eligibility state on the owning tip type. The explicit `Bool` type annotations are required by this Xcode/TipKit macro toolchain.

```swift
import SwiftUI
import TipKit

struct SaveSessionTip: Tip {
    @Parameter
    static var hasViewedSaveContext: Bool = false

    @Parameter
    static var hasSavedFavourite: Bool = false

    var title: Text { Text("Save Sessions") }
    var message: Text? { Text("Tap the star to keep sessions in My Schedule.") }
    var image: Image? { Image(systemName: "star") }

    var rules: [Rule] {
        #Rule(Self.$hasViewedSaveContext) { $0 == true }
        #Rule(Self.$hasSavedFavourite) { $0 == false }
    }

    var options: [TipOption] {
        MaxDisplayCount(2)
    }
}
```

The same pattern is used for:

- `ConferenceDayPickerTip`
- `SpeakerSearchTip`
- `OpenInMapsTip`

## App Setup

`MythConfApp.swift` imports TipKit and configures it once in `init()`:

```swift
try? Tips.configure([
    .datastoreLocation(.applicationDefault),
    .displayFrequency(.daily)
])
```

Existing UI test launches with `-UITestingResetFavourites` also call `Tips.hideAllTipsForTesting()` so automated accessibility screenshots and element detection remain stable.

## Integration Details

### Programme

- `ProgrammeView` imports TipKit.
- `ConferenceDayPickerTip` is attached to the segmented day picker with `.popoverTip(dayPickerTip, arrowEdge: .top)`.
- `SaveSessionTip.hasViewedSaveContext`, `ConferenceDayPickerTip.hasViewedProgramme`, and `ConferenceDayPickerTip.hasMultipleConferenceDays` are set in `onAppear`.
- Changing `selectedDayIndex` invalidates the day picker tip.

### Favourite Button

- `FavouriteButtonView` imports TipKit.
- `SaveSessionTip` is attached to the star button with `.popoverTip(saveSessionTip, arrowEdge: .bottom)`.
- Adding a favourite sets `SaveSessionTip.hasSavedFavourite = true` and invalidates the tip.
- Removing a favourite keeps the tip invalidated because the user has already learned the save action.

### Session Detail

- `SessionDetailView` marks the screen as a save context with `SaveSessionTip.hasViewedSaveContext = true`.
- The existing toolbar favourite button provides the same save tip anchor on detail screens.

### Speakers

- `SpeakersView` imports TipKit.
- `TipView(speakerSearchTip)` appears at the top of the list only while `searchText` is empty.
- Opening Speakers sets `SpeakerSearchTip.hasViewedSpeakers = true`.
- Entering non-empty search text sets `SpeakerSearchTip.hasSearchedSpeakers = true` and invalidates the tip.

### Locations

- `LocationDetailView` imports TipKit and uses `openURL`.
- The previous Maps `Link` was changed to a `Button` so the app can invalidate the tip before handing off to Apple Maps.
- Opening a location sets `OpenInMapsTip.hasViewedLocationDetail = true`.
- Tapping Maps sets `OpenInMapsTip.hasOpenedMaps = true` and invalidates the tip.

## Accessibility Notes

- Tips support feature discovery without replacing accessible labels, hints, or semantic controls.
- Tip content is short and action-oriented so it works well with VoiceOver.
- The tips are tied to existing visible controls: star, day picker, search list area, and Maps action.
- Tips are hidden during UI accessibility audits so they do not create unstable automated results.
- Human verification is still needed for VoiceOver timing, dismissal behavior, Switch Control focus, and large Dynamic Type presentation.

## Verification

Build command:

```sh
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Result on 2026-05-10: build succeeded after adding explicit `Bool` types to TipKit `@Parameter` declarations.
