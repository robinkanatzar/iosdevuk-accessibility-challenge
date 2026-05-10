# Siri App Intents Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Siri/App Shortcuts support for existing MythConf behaviours: hearing session details, adding sessions to My Schedule, removing sessions from My Schedule, and hearing the current My Schedule.

**Architecture:** Use a single user-facing `ConferenceSessionEntity` that represents the app's existing `Talk` plus its scheduled `Session` metadata. App Intents will read bundled conference data through a lightweight store and mutate the same `favourites.json` file already used by `ViewModel`, while the app refreshes favourites when it becomes active.

**Tech Stack:** SwiftUI, AppIntents, Xcode file-system synchronized groups, existing JSON model loading, existing UI test bundle, manual Siri/Shortcuts verification.

---

## Recommendation

The best App Intent entity is **Conference Session**.

The app has several unique entities:

- `Talk`: title, description, speakers, location, and stable UUID.
- `Session`: scheduled time block that contains one or more talks.
- `Speaker`: speaker profile, photo, social links, and talk IDs.
- `Location`: venue name, coordinates, and description.
- Favourites / My Schedule: a persisted collection of favourite talk UUIDs in `favourites.json`.

The user-facing object is not just a raw `Talk`; users see and act on scheduled session cards. A Siri entity should therefore combine a talk with its session time, type, speaker names, and location. This lets Siri answer naturally: title, speaker, day, time, room, and favourite state.

Recommended Siri intents:

- **Get Session Details**: voice-only readout of an existing session detail screen.
- **Add Session to Your Schedule**: same behaviour as tapping the star to favourite a session.
- **Remove Session from Your Schedule**: same behaviour as tapping the star again.
- **Read Your Schedule**: voice-only summary of existing favourites in My Schedule.

Do not add intents for creating sessions, creating speakers, creating locations, reminders, tickets, ratings, notes, or search filters because the app does not currently provide those features.

---

## Files

Create:

- `MythConf/MythConf26/AppIntents/ConferenceSessionStore.swift`
  - Converts existing `ConfData`, `Talk`, `Session`, `Speaker`, and `Location` data into intent entities.
  - Reads and writes the existing `favourites.json` file.
- `MythConf/MythConf26/AppIntents/ConferenceSessionEntity.swift`
  - Defines the App Entity and query Siri uses for voice parameter resolution.
- `MythConf/MythConf26/AppIntents/ConferenceSessionIntents.swift`
  - Defines the four App Intents and app shortcut phrases.

Modify:

- `MythConf/MythConf26/MythConfApp.swift`
  - Refresh favourites from disk when the app becomes active after a Siri action.

Project file:

- No manual `MythConf/MythConf26.xcodeproj/project.pbxproj` edit should be needed because the app target uses `PBXFileSystemSynchronizedRootGroup` for `MythConf26`.

Info.plist and capabilities:

- No SiriKit extension is needed.
- No `NSSiriUsageDescription` is needed for these App Intents because the app is not recording speech or using SiriKit domains.
- The app target must compile the new `AppIntents` files. With the synchronized project structure, placing the files under `MythConf/MythConf26/AppIntents/` is sufficient.

---

### Task 1: Add a Store for App Intent Data and Favourite Mutations

**Files:**

- Create: `MythConf/MythConf26/AppIntents/ConferenceSessionStore.swift`

- [ ] **Step 1: Create the AppIntents folder**

Run:

```bash
mkdir -p MythConf/MythConf26/AppIntents
```

Expected: the folder exists under the synchronized app source root.

- [ ] **Step 2: Create the store**

Create `MythConf/MythConf26/AppIntents/ConferenceSessionStore.swift` with:

```swift
//
//  ConferenceSessionStore.swift
//  MythConf26
//

import Foundation

enum ConferenceSessionStore {
    private static let favouritesFileName = "favourites.json"

    static func allSessions() -> [ConferenceSessionEntity] {
        let confData = loadConfData()
        let favourites = Set(favouriteIDs())
        let speakersByID = Dictionary(uniqueKeysWithValues: confData.speakers.map { ($0.id, $0) })
        let locationsByID = Dictionary(uniqueKeysWithValues: confData.locations.map { ($0.id, $0) })
        let talksByID = Dictionary(uniqueKeysWithValues: confData.talks.map { ($0.id, $0) })

        let entities = confData.sessions.flatMap { daySessions in
            daySessions.flatMap { session in
                session.contentIDs.compactMap { talkID -> ConferenceSessionEntity? in
                    guard session.containsTalk,
                          let talk = talksByID[talkID],
                          let location = locationsByID[talk.locationID] else {
                        return nil
                    }

                    let speakerNames = talk.speakerIDs.compactMap { speakersByID[$0]?.name }

                    return ConferenceSessionEntity(
                        id: talk.id,
                        title: talk.talkTitle,
                        sessionType: session.sessionType.displayName,
                        speakerNames: formattedList(speakerNames),
                        locationName: location.name,
                        dayAndDate: session.dayAndDate,
                        timeRange: session.timeRange,
                        startDate: session.startTime,
                        summary: firstSentence(from: talk.talkDescription),
                        details: talk.talkDescription,
                        isFavourite: favourites.contains(talk.id)
                    )
                }
            }
        }

        return entities.sorted { lhs, rhs in
            if lhs.startDate == rhs.startDate {
                return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
            }
            return lhs.startDate < rhs.startDate
        }
    }

    static func sessions(matching searchText: String) -> [ConferenceSessionEntity] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return Array(allSessions().prefix(8))
        }

        return allSessions().filter { session in
            [
                session.title,
                session.sessionType,
                session.speakerNames,
                session.locationName,
                session.dayAndDate
            ]
            .joined(separator: " ")
            .localizedCaseInsensitiveContains(trimmed)
        }
    }

    static func session(for id: UUID) -> ConferenceSessionEntity? {
        allSessions().first { $0.id == id }
    }

    static func favouriteSessions() -> [ConferenceSessionEntity] {
        let favourites = Set(favouriteIDs())
        return allSessions().filter { favourites.contains($0.id) }
    }

    static func favouriteIDs() -> [UUID] {
        let url = urlToFileInDocuments(favouritesFileName)
        guard let data = try? Data(contentsOf: url),
              let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
            return []
        }
        return ids
    }

    @discardableResult
    static func addFavourite(_ id: UUID) throws -> Bool {
        var ids = favouriteIDs()
        guard !ids.contains(id) else { return false }
        ids.append(id)
        try saveFavouriteIDs(ids)
        return true
    }

    @discardableResult
    static func removeFavourite(_ id: UUID) throws -> Bool {
        let ids = favouriteIDs()
        let updated = ids.filter { $0 != id }
        guard updated.count != ids.count else { return false }
        try saveFavouriteIDs(updated)
        return true
    }

    private static func saveFavouriteIDs(_ ids: [UUID]) throws {
        let data = try JSONEncoder().encode(ids)
        try data.write(to: urlToFileInDocuments(favouritesFileName), options: [.atomic])
    }

    private static func formattedList(_ values: [String]) -> String {
        switch values.count {
        case 0:
            return "Unknown speaker"
        case 1:
            return values[0]
        case 2:
            return "\(values[0]) and \(values[1])"
        default:
            let leading = values.dropLast().joined(separator: ", ")
            return "\(leading), and \(values[values.count - 1])"
        }
    }

    private static func firstSentence(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let sentenceEnd = trimmed.firstIndex(where: { ".!?".contains($0) }) else {
            return trimmed
        }
        return String(trimmed[...sentenceEnd])
    }
}
```

- [ ] **Step 3: Check compile risks**

Confirm the code only uses existing app model APIs:

- `loadConfData()`
- `urlToFileInDocuments(_:)`
- `Session.containsTalk`
- `Session.dayAndDate`
- `Session.timeRange`
- `SessionType.displayName`

Expected: no new app feature is introduced; this is a Siri-facing adapter over existing data.

- [ ] **Step 4: Commit**

```bash
git add MythConf/MythConf26/AppIntents/ConferenceSessionStore.swift
git commit -m "Add conference session intent store"
```

Do not stage unrelated dirty files.

---

### Task 2: Add the Conference Session App Entity and Voice Query

**Files:**

- Create: `MythConf/MythConf26/AppIntents/ConferenceSessionEntity.swift`

- [ ] **Step 1: Create the entity and query**

Create `MythConf/MythConf26/AppIntents/ConferenceSessionEntity.swift` with:

```swift
//
//  ConferenceSessionEntity.swift
//  MythConf26
//

import AppIntents
import Foundation

struct ConferenceSessionEntity: AppEntity, Identifiable, Sendable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Conference Session")
    static var defaultQuery = ConferenceSessionQuery()

    let id: UUID
    let title: String
    let sessionType: String
    let speakerNames: String
    let locationName: String
    let dayAndDate: String
    let timeRange: String
    let startDate: Date
    let summary: String
    let details: String
    let isFavourite: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(dayAndDate), \(timeRange) - \(locationName)"
        )
    }

    var spokenDetails: String {
        "\(title) is a \(sessionType.lowercased()) by \(speakerNames), on \(dayAndDate) from \(timeRange), in \(locationName). \(summary)"
    }

    var shortScheduleLine: String {
        "\(timeRange), \(title), in \(locationName)"
    }
}

struct ConferenceSessionQuery: EntityStringQuery {
    func entities(for identifiers: [ConferenceSessionEntity.ID]) async throws -> [ConferenceSessionEntity] {
        let sessions = await ConferenceSessionStore.allSessions()
        return sessions.filter { identifiers.contains($0.id) }
    }

    func entities(matching string: String) async throws -> [ConferenceSessionEntity] {
        await ConferenceSessionStore.sessions(matching: string)
    }

    func suggestedEntities() async throws -> [ConferenceSessionEntity] {
        let sessions = await ConferenceSessionStore.allSessions()
        return Array(sessions.prefix(12))
    }

    func defaultResult() async -> ConferenceSessionEntity? {
        await ConferenceSessionStore.allSessions().first
    }
}
```

- [ ] **Step 2: Verify Siri can resolve voice input**

Confirm `entities(matching:)` searches these user-speakable fields:

- Session title.
- Session type, such as "Talk" or "Workshop".
- Speaker names.
- Location name.
- Day/date text.

Expected: phrases like "add SwiftData in Production to my schedule" and "tell me about Sarah Thornton's session" have searchable text to resolve against.

- [ ] **Step 3: Commit**

```bash
git add MythConf/MythConf26/AppIntents/ConferenceSessionEntity.swift
git commit -m "Add conference session app entity"
```

Do not stage unrelated dirty files.

---

### Task 3: Add Siri Intents and App Shortcuts

**Files:**

- Create: `MythConf/MythConf26/AppIntents/ConferenceSessionIntents.swift`

- [ ] **Step 1: Create the intents**

Create `MythConf/MythConf26/AppIntents/ConferenceSessionIntents.swift` with:

```swift
//
//  ConferenceSessionIntents.swift
//  MythConf26
//

import AppIntents
import Foundation

private struct MythConfIntentError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}

struct GetSessionDetailsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Session Details"
    static var description = IntentDescription("Hear the time, speaker, location, and summary for a MythConf session.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Session",
        requestValueDialog: IntentDialog("Which MythConf session do you want details for?")
    )
    var session: ConferenceSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Get details for \(\.$session)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog("\(session.spokenDetails)"))
    }
}

struct AddSessionToMyScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Session to Your Schedule"
    static var description = IntentDescription("Add an existing MythConf session to your schedule.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Session",
        requestValueDialog: IntentDialog("Which MythConf session should I add to your schedule?")
    )
    var session: ConferenceSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$session) to your schedule")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let added = try await ConferenceSessionStore.addFavourite(session.id)
            if added {
                return .result(dialog: IntentDialog("Added \(session.title) to your schedule. It is on \(session.dayAndDate) from \(session.timeRange), in \(session.locationName)."))
            } else {
                return .result(dialog: IntentDialog("\(session.title) is already in your schedule. It is on \(session.dayAndDate) from \(session.timeRange), in \(session.locationName)."))
            }
        } catch {
            throw MythConfIntentError(message: "I could not update your schedule. Please try again.")
        }
    }
}

struct RemoveSessionFromMyScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Remove Session from Your Schedule"
    static var description = IntentDescription("Remove an existing MythConf session from your schedule.")
    static var openAppWhenRun = false

    @Parameter(
        title: "Session",
        requestValueDialog: IntentDialog("Which MythConf session should I remove from your schedule?")
    )
    var session: ConferenceSessionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Remove \(\.$session) from your schedule")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        do {
            let removed = try await ConferenceSessionStore.removeFavourite(session.id)
            if removed {
                return .result(dialog: IntentDialog("Removed \(session.title) from your schedule."))
            } else {
                return .result(dialog: IntentDialog("\(session.title) was not in your schedule."))
            }
        } catch {
            throw MythConfIntentError(message: "I could not update your schedule. Please try again.")
        }
    }
}

struct ReadMyScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Read Your Schedule"
    static var description = IntentDescription("Hear a summary of the sessions currently saved in your schedule.")
    static var openAppWhenRun = false

    static var parameterSummary: some ParameterSummary {
        Summary("Read your schedule")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let sessions = await ConferenceSessionStore.favouriteSessions()

        guard !sessions.isEmpty else {
            return .result(dialog: IntentDialog("Your schedule is empty. Add sessions from the Programme by asking me to add a session to your schedule."))
        }

        let sessionCountText = sessions.count == 1 ? "1 session" : "\(sessions.count) sessions"
        let visibleSessions = sessions.prefix(5).map(\.shortScheduleLine).joined(separator: ". ")
        let remainingCount = sessions.count - 5

        if remainingCount > 0 {
            return .result(dialog: IntentDialog("You have \(sessionCountText) in your schedule. \(visibleSessions). There are \(remainingCount) more sessions in the app."))
        } else {
            return .result(dialog: IntentDialog("You have \(sessionCountText) in your schedule. \(visibleSessions)."))
        }
    }
}

struct MythConfShortcutsProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .blue

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetSessionDetailsIntent(),
            phrases: [
                "Tell me about \(\.$session) in \(.applicationName)",
                "Get details for \(\.$session) in \(.applicationName)",
                "What is \(\.$session) in \(.applicationName)"
            ],
            shortTitle: "Session Details",
            systemImageName: "text.bubble"
        )

        AppShortcut(
            intent: AddSessionToMyScheduleIntent(),
            phrases: [
                "Add \(\.$session) to my schedule in \(.applicationName)",
                "Add \(\.$session) to your schedule in \(.applicationName)",
                "Save \(\.$session) in \(.applicationName)",
                "Favourite \(\.$session) in \(.applicationName)"
            ],
            shortTitle: "Add Session",
            systemImageName: "star"
        )

        AppShortcut(
            intent: RemoveSessionFromMyScheduleIntent(),
            phrases: [
                "Remove \(\.$session) from my schedule in \(.applicationName)",
                "Remove \(\.$session) from your schedule in \(.applicationName)",
                "Unfavourite \(\.$session) in \(.applicationName)",
                "Delete \(\.$session) from my schedule in \(.applicationName)"
            ],
            shortTitle: "Remove Session",
            systemImageName: "star.slash"
        )

        AppShortcut(
            intent: ReadMyScheduleIntent(),
            phrases: [
                "Read my schedule in \(.applicationName)",
                "Read your schedule in \(.applicationName)",
                "What is on my schedule in \(.applicationName)",
                "Tell me my schedule in \(.applicationName)"
            ],
            shortTitle: "Read Schedule",
            systemImageName: "calendar"
        )
    }
}
```

- [ ] **Step 2: Confirm voice-only behaviour**

Check the four `perform()` implementations:

- They all set `openAppWhenRun = false`.
- They all return `IntentDialog`.
- Add and remove return meaningful confirmations.
- Already-added and not-in-schedule states return meaningful confirmations.
- Read My Schedule handles the empty state and limits speech to five sessions.

Expected: Siri can complete the shortcut without a screen and without needing the app to open.

- [ ] **Step 3: Confirm these intents only expose existing behaviours**

Map each intent to current app UI:

- `GetSessionDetailsIntent` maps to `SessionDetailView`.
- `AddSessionToMyScheduleIntent` maps to `FavouriteButtonView` add.
- `RemoveSessionFromMyScheduleIntent` maps to `FavouriteButtonView` remove.
- `ReadMyScheduleIntent` maps to `MyScheduleView`.

Expected: no unrelated feature has been added.

- [ ] **Step 4: Commit**

```bash
git add MythConf/MythConf26/AppIntents/ConferenceSessionIntents.swift
git commit -m "Add MythConf Siri shortcuts"
```

Do not stage unrelated dirty files.

---

### Task 4: Refresh Favourites After Siri Mutations

**Files:**

- Modify: `MythConf/MythConf26/MythConfApp.swift`

- [ ] **Step 1: Add scene phase tracking**

Change `MythConfApp.swift` from:

```swift
@main
struct MythConf: App {
    @State private var viewModel = ViewModel()
```

to:

```swift
@main
struct MythConf: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = ViewModel()
```

- [ ] **Step 2: Reload favourites when the app becomes active**

Change the `WindowGroup` content from:

```swift
WindowGroup {
    HomeView()
        .environment(viewModel)
        .foregroundStyle(.primary, .secondary, .tertiary)
}
```

to:

```swift
WindowGroup {
    HomeView()
        .environment(viewModel)
        .foregroundStyle(.primary, .secondary, .tertiary)
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            viewModel.loadFavourites()
        }
}
```

Expected: if Siri adds or removes a session while the app is backgrounded, My Schedule refreshes when the user returns.

- [ ] **Step 3: Commit**

```bash
git add MythConf/MythConf26/MythConfApp.swift
git commit -m "Refresh favourites after Siri actions"
```

Do not stage unrelated dirty files.

---

### Task 5: Build and Automated Verification

**Files:**

- No source changes.

- [ ] **Step 1: Build the app**

Run:

```bash
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected:

```text
** BUILD SUCCEEDED **
```

- [ ] **Step 2: Run the UI test bundle**

Run:

```bash
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Expected:

```text
** TEST SUCCEEDED **
```

If a simulator named `iPhone 17` is not installed, first list destinations:

```bash
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -showdestinations
```

Then rerun build/test with an installed iOS simulator destination.

- [ ] **Step 3: Verify no unrelated changes were staged**

Run:

```bash
git status --short
```

Expected staged files, if committing task-by-task, are only:

- `MythConf/MythConf26/AppIntents/ConferenceSessionStore.swift`
- `MythConf/MythConf26/AppIntents/ConferenceSessionEntity.swift`
- `MythConf/MythConf26/AppIntents/ConferenceSessionIntents.swift`
- `MythConf/MythConf26/MythConfApp.swift`

Existing unrelated dirty files must remain unstaged unless the implementer intentionally owns them in a separate task.

---

### Task 6: Manual Siri and Shortcuts Verification

**Files:**

- No source changes.

- [ ] **Step 1: Install the app on a simulator or device**

Run:

```bash
xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Then run the app from Xcode, or install the build product onto the booted simulator.

Expected: app launches and the Shortcuts app can discover MythConf shortcuts after indexing.

- [ ] **Step 2: Verify Get Session Details**

In Siri or Shortcuts, try:

```text
Tell me about SwiftData in Production in MythConf
```

Expected spoken response:

```text
SwiftData in Production: Relationships, Schema Migrations, and the Gotchas No One Warns You About is a talk by David Kowalski, on Friday, Sep 3 from 14:40 – 15:20, in Faraday Seminar Room. SwiftData's clean API makes it feel straightforward right up until the moment you try to do something slightly non-trivial in a real app.
```

- [ ] **Step 3: Verify Add Session to Your Schedule**

Try:

```text
Add SwiftData in Production to my schedule in MythConf
```

Expected spoken response:

```text
Added SwiftData in Production: Relationships, Schema Migrations, and the Gotchas No One Warns You About to your schedule. It is on Friday, Sep 3 from 14:40 – 15:20, in Faraday Seminar Room.
```

Open the app and check My Schedule.

Expected: the selected session appears in My Schedule.

- [ ] **Step 4: Verify duplicate add confirmation**

Repeat:

```text
Add SwiftData in Production to my schedule in MythConf
```

Expected spoken response:

```text
SwiftData in Production: Relationships, Schema Migrations, and the Gotchas No One Warns You About is already in your schedule. It is on Friday, Sep 3 from 14:40 – 15:20, in Faraday Seminar Room.
```

- [ ] **Step 5: Verify Read Your Schedule**

Try:

```text
What is on my schedule in MythConf
```

Expected spoken response:

```text
You have 1 session in your schedule. 14:40 – 15:20, SwiftData in Production: Relationships, Schema Migrations, and the Gotchas No One Warns You About, in Faraday Seminar Room.
```

- [ ] **Step 6: Verify Remove Session from Your Schedule**

Try:

```text
Remove SwiftData in Production from my schedule in MythConf
```

Expected spoken response:

```text
Removed SwiftData in Production: Relationships, Schema Migrations, and the Gotchas No One Warns You About from your schedule.
```

Open the app and check My Schedule.

Expected: the selected session is no longer in My Schedule.

- [ ] **Step 7: Verify entity disambiguation**

Try a partial phrase that could match more than one session:

```text
Add Swift to my schedule in MythConf
```

Expected: Siri asks a follow-up question or presents matching session choices using `ConferenceSessionQuery.entities(matching:)`.

---

## Enhanced Siri Experience Notes

Parameter resolution:

- `ConferenceSessionQuery` searches title, session type, speaker names, location, and day/date.
- `requestValueDialog` prompts for the missing session parameter.
- `DisplayRepresentation` subtitles show day, time, and location when Siri or Shortcuts needs disambiguation.

Voice-only support:

- Intents do not require a visible UI.
- Every intent returns an `IntentDialog`.
- `ReadMyScheduleIntent` limits speech to five sessions and reports remaining count.
- An empty schedule gets a clear spoken state rather than failing.

Error handling:

- Favourite file write failures are converted into a user-friendly spoken error.
- Adding an already-favourited session and removing a non-favourited session are handled as successful conversational outcomes.

Suggested invocation phrases:

- "Tell me about [session] in MythConf"
- "Get details for [session] in MythConf"
- "Add [session] to my schedule in MythConf"
- "Add [session] to your schedule in MythConf"
- "Save [session] in MythConf"
- "Favourite [session] in MythConf"
- "Remove [session] from my schedule in MythConf"
- "Remove [session] from your schedule in MythConf"
- "Unfavourite [session] in MythConf"
- "Read my schedule in MythConf"
- "Read your schedule in MythConf"
- "What is on my schedule in MythConf"

Future Siri additions that still fit the existing app:

- `GetSpeakerDetailsIntent` using a `SpeakerEntity`, because speaker detail already exists.
- `GetLocationDetailsIntent` using a `LocationEntity`, because location detail already exists.
- `OpenMyScheduleIntent` with `openAppWhenRun = true`, because My Schedule already exists.

Do not implement future intents until the session intents build and verify cleanly.

---

## Self-Review

Spec coverage:

- Unique entities are identified.
- The recommended entity is explained.
- Multiple Siri actions are included, all mapped to existing app behaviour.
- Exact Swift code is included for the store, `AppEntity`, `EntityQuery`, intents, `perform()` implementations, app shortcuts, spoken dialog, and shortcut phrases.
- Voice-only support is covered by `IntentDialog` responses and `openAppWhenRun = false`.
- Code integration lists created files, modified files, project file expectations, Info.plist/capability expectations, and verification commands.

Placeholder scan:

- No `TBD`, `TODO`, or "implement later" placeholders are present.

Type consistency:

- `ConferenceSessionStore` returns `ConferenceSessionEntity`.
- `ConferenceSessionQuery` uses `ConferenceSessionEntity.ID` and awaits the main-actor-isolated store calls required by the project's default actor isolation.
- Intent parameters use `ConferenceSessionEntity`.
- Shortcut phrases reference `\(\.$session)` only in intents that define `session`.
