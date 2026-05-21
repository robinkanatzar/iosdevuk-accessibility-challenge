# iOSDevUK Accessibility Challenge 2026

This submission was created for the iOSDevUK Accessibility Competition by İrem Karaoğlu Sansak. The following sections outline the accessibility improvements made throughout the app.

---

## Vision Improvements
- Added a Settings tab with a dyslexia-friendly font toggle that switches the app to Lexend and explains it can improve reading proficiency and reduce visual stress.
- Changed the time column from a fixed width to a minimum width with fixed sizing, reducing clipping risk with larger text.

## Screen Reader Improvements

- Added clearer tab accessibility hints for Programme, Speakers, Locations, My Schedule, and Settings.
- Improved talk cards with richer accessibility labels, favourite state via accessibilityValue, and custom favourite/unfavourite accessibility actions.
- Added VoiceOver announcements when favourites are added or removed.
- Improved speaker rows and session detail speaker links with labels that include speaker name, short bio preview, and “Double tap for full biography.”
- Marked section headers such as “Sessions” and schedule day headers with header traits.
- Hid decorative speaker photos and talk card colour strips from accessibility so VoiceOver focuses on meaningful content.
- Improved social link labels to clarify that links open in a browser.

## Sensory Improvements
Added a haptic feedback toggle. When off, tab changes, day selection, and favourite actions no longer trigger sensory feedback.
