# Repository Guidelines

## Project Structure & Module Organization
This repository contains a single SwiftUI iOS app in `MythConf/MythConf26.xcodeproj` with all source under `MythConf/MythConf26/`.

- `Model/` holds app data types, JSON loading, and shared helpers.
- `Programme/`, `Speakers/`, `Locations/`, `MySchedule/`, and `Favourites/` hold feature views.
- `Assets.xcassets/` contains app icons, photos, and color assets.
- `Model/conf.json` is bundled conference content used at runtime.

Avoid editing `MythConf/MythConf26.xcodeproj/xcuserdata/` unless you are intentionally changing local Xcode state.

## Build, Test, and Development Commands
Use Xcode or the command line from the repo root:

- `xcodebuild -list -project MythConf/MythConf26.xcodeproj` lists the available scheme and configurations.
- `xcodebuild -project MythConf/MythConf26.xcodeproj -scheme MythConf26 -destination 'platform=iOS Simulator,name=iPhone 16' build` builds the app for a simulator.
- Open `MythConf/MythConf26.xcodeproj` in Xcode for interactive development and preview support.

There is no XCTest target in the current project, so build verification is the primary automated check.

## Coding Style & Naming Conventions
Follow standard SwiftUI style:

- Use 4-space indentation and keep line breaks readable.
- Name views with `View` suffixes, for example `SpeakerDetailView`.
- Use `camelCase` for properties and functions, `PascalCase` for types and enums.
- Keep file names aligned with the primary type in the file.
- Prefer small, focused SwiftUI views over large monoliths.

## Testing Guidelines
No test bundle is present yet. When adding tests, place them in a new XCTest target and name files after the unit under test, such as `ViewModelTests.swift`. Until then, verify changes by building the app and manually checking the affected flows in the simulator.

## Commit & Pull Request Guidelines
Git history uses short, imperative commit subjects such as `Update README` and `Add conference app code`. Keep future commits similarly concise.

Pull requests should include:

- A clear summary of the accessibility change.
- Screenshots or screen recordings for UI work.
- Notes on simulator/device used for verification.
- Links to any related issue or challenge instructions.

## Agent-Specific Instructions
Keep changes scoped to `MythConf/MythConf26/` unless the task explicitly requires project file edits. Preserve existing conference data and assets unless a change depends on them. Always use the `xcode`, `XcodeBuildMCP`, and `sosumi` MCP servers for development, build, and documentation tasks in this project.

For build, run, and test verification, use this fallback order:

1. Use `XcodeBuildMCP` first.
2. If `XcodeBuildMCP` times out, fails, or does not expose the needed workflow, try the `xcode` MCP next.
3. Use raw `xcodebuild` only after both MCP routes are not enough.
