# iOSDevUK Accessibility Challenge 2026 submission

## Summary
### This PR's goal is to improve the accessibilty of the iOSDevUK app by making it easier to navigate, interact with and understand its content.

### I tried to leave the original design as is as much as possible. Testing was done on a real device, an iPhone 14 Pro running iOS 26.5. Below is an overview of the changes I made.

## Vision:
- Text now supports all dynamic type sizes, including accessibility sizes.
- The speakers’ images scale up as the text size increases.
- `LocationDetailView`’s navigation title was truncated at larger text sizes. The system’s navigation title was replaced with a custom text view so it could go onto another line. However, this caused the navigation bar back button to snap into place during transitions from `LocationsView`, so the system back button was replaced with a custom one to eliminate that snap.
- `ProgrammeView`’s picker now supports accessibility text sizes by using a navigation link for those text sizes instead of the segmented control.
- Updated `ParallelTalkCardView`’s accessibility label so that VoiceOver can read the current favourite status. Also, added an accessibility hint for the two actions on the view and how to perform them.
- Improved text contrast across various views, and added UI tests to catch regressions.
- Added provision for a high contrast border around the image in `SpeakerPhotoView` if increased contrast is switched on.
- Added logic to `Session` to make session start times and end times less ambiguous to VoiceOver users by using AM and PM when reading hour and minutes, making the speech flow and sound more natural.

## Mobility: 
- Added custom buttons to `LocationDetailView`’s map as single tap alternatives for zoom and pan gestures. These buttons also support large content viewer.
- Increased the default size of the favourite button across the app to `.font(.title)` to make it easier to hit.

## Cognitive:
- Sections of UI have had `.isHeader` added to them to assist rotor navigation in `SpeakerDetailView`, `LocationDetailView` and `TimeColumnView`.
- Implemented VoiceOver support for search in `SpeakersView` with debounce for accessibility notification announcements. The app announces the number of speakers when the user enters a search query, deletes characters, clears text or finishes searching.
- VoiceOver informs users of the number of locations in `LocationsView`.
- Changed day picker to display and read the full day name for all days because VoiceOver was reading `Sat` and `Sun` for Saturday and Sunday. This change makes the reading of all days consistent.

## Note
Thank you for organising this competition! It has helped me to deepen my knowledge of assistive technologies while reminding me there is more to learn.
