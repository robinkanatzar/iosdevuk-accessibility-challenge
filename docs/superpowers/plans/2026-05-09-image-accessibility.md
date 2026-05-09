# Image Accessibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make image accessibility intent explicit for speaker photos and document image accessibility rules for future SwiftUI image additions.

**Architecture:** Keep image accessibility behavior inside `SpeakerPhotoView` so callers choose whether a speaker photo is decorative or meaningful. List rows will continue hiding redundant thumbnails from VoiceOver, while speaker detail will expose a useful "Photo of ..." label for the larger content image.

**Tech Stack:** SwiftUI, Xcode build verification, `a11y-check`, manual VoiceOver review on simulator/device.

---

### Task 1: Add Explicit Speaker Photo Accessibility Modes

**Files:**
- Modify: `MythConf/MythConf26/Speakers/SpeakerPhotoView.swift`
- Modify: `MythConf/MythConf26/Speakers/SpeakerRowView.swift`
- Modify: `MythConf/MythConf26/Speakers/SpeakerDetailView.swift`

- [ ] **Step 1: Establish current behavior**

Read `SpeakerPhotoView.swift` and confirm it always hides speaker images:

```swift
.accessibilityHidden(true)
```

Expected: this is correct for list thumbnails but too broad for the larger image on speaker detail.

- [ ] **Step 2: Add a display intent enum to `SpeakerPhotoView`**

Replace the top of `SpeakerPhotoView` with this shape:

```swift
/// A circular speaker photo at a given size, falling back to a default if no photo exists.
struct SpeakerPhotoView: View {
    enum AccessibilityMode {
        case decorative
        case labelled
    }

    let speaker: Speaker
    let size: CGFloat
    let accessibilityMode: AccessibilityMode

    init(
        speaker: Speaker,
        size: CGFloat,
        accessibilityMode: AccessibilityMode = .decorative
    ) {
        self.speaker = speaker
        self.size = size
        self.accessibilityMode = accessibilityMode
    }

    private var imageName: String {
        UIImage(named: speaker.photoName) != nil ? speaker.photoName : "default"
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(.circle)
            .accessibilityHidden(accessibilityMode == .decorative)
            .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: Text {
        Text("Photo of \(speaker.name)")
    }
}
```

Rationale: the default remains decorative so existing list use stays safe, and detail screens can opt into an accessible image label without exposing raw asset names.

- [ ] **Step 3: Keep speaker list rows decorative**

In `SpeakerRowView.swift`, keep the existing call unchanged:

```swift
SpeakerPhotoView(speaker: speaker, size: 56)
```

Expected: the default `.decorative` mode hides the thumbnail because the row already contains the speaker name and summary.

- [ ] **Step 4: Label the detail screen photo**

In `SpeakerDetailView.swift`, change the header image call from:

```swift
SpeakerPhotoView(speaker: speaker, size: 80)
```

to:

```swift
SpeakerPhotoView(speaker: speaker, size: 80, accessibilityMode: .labelled)
```

Expected: VoiceOver users on the detail screen can discover the large visible photo as "Photo of [speaker name]" instead of hearing an asset filename or nothing.

- [ ] **Step 5: Run verification**

Run:

```bash
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build
a11y-check MythConf/MythConf26 --format json --per-view --no-trend
```

Expected:

- Xcode build exits 0 with `** BUILD SUCCEEDED **`.
- `a11y-check` remains grade A+ with 0 errors and 0 warnings.

- [ ] **Step 6: Commit**

```bash
git add MythConf/MythConf26/Speakers/SpeakerPhotoView.swift MythConf/MythConf26/Speakers/SpeakerDetailView.swift
git commit -m "Improve speaker image accessibility"
```

Do not stage unrelated untracked files.

---

### Task 2: Document Image Accessibility Rules

**Files:**
- Modify: `docs/accessibility_audits/README.md`

- [ ] **Step 1: Add an Images section**

Add this section after "Locations" and before "App Shell and Visual Semantics":

```markdown
### Images

- Kept redundant speaker thumbnails decorative in speaker list rows because the adjacent row text already identifies the speaker.
- Exposed larger speaker detail photos with contextual labels such as "Photo of Sarah Thornton".
- Avoided raw asset names being announced by VoiceOver by using explicit labels for meaningful images and hidden semantics for decorative images.
- Confirmed SF Symbol icons are either part of labelled controls or paired with visible text through `Label`.
```

- [ ] **Step 2: Add manual verification guidance**

In the "Human Verification Still Recommended" list, add:

```markdown
- VoiceOver behavior for speaker photos in list rows and speaker detail screens.
```

Expected: the README reflects the new image-specific accessibility rule and the remaining human/device check.

- [ ] **Step 3: Run documentation and static verification**

Run:

```bash
a11y-check MythConf/MythConf26 --format json --per-view --no-trend
```

Expected: grade A+ with 0 errors and 0 warnings.

- [ ] **Step 4: Commit**

```bash
git add docs/accessibility_audits/README.md
git commit -m "Document image accessibility decisions"
```

Do not stage unrelated untracked files.

---

### Task 3: Manual Review Checklist

**Files:**
- No code files.

- [ ] **Step 1: Review speaker list with VoiceOver**

Open the Speakers tab and swipe through the list.

Expected:

- Each speaker row reads the speaker name and bio summary.
- Speaker thumbnails are not separate swipe stops.
- No asset names such as `SarahThornton` or `default` are announced.

- [ ] **Step 2: Review speaker detail with VoiceOver**

Open a speaker detail page and swipe through the header.

Expected:

- The photo is reachable as a separate element.
- VoiceOver reads "Photo of [speaker name]".
- The speaker name remains a heading.
- Social links remain reachable with contextual labels.

- [ ] **Step 3: Review symbol-only favourite control**

Open Programme or My Schedule and focus a favourite star.

Expected:

- VoiceOver reads the contextual favourite label, not `star` or `star.fill`.
- The value is "Favourited" or "Not favourited".
- The hint explains whether the action adds or removes the session from My Schedule.

- [ ] **Step 4: Record outcome**

Add manual verification notes to the PR or release notes:

```markdown
Image accessibility manual checks:
- Speaker list thumbnails: pass/fail
- Speaker detail photo label: pass/fail
- Favourite star symbol label: pass/fail
- Device/simulator used:
```
