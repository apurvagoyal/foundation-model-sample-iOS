# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LA Olympics 2028 — an iOS app that serves as an Olympic virtual assistant, combining event schedule browsing with an AI-powered chat interface built on Apple's FoundationModels framework (on-device LLM). The app queries embedded JSON data for medal results and schedules, and uses on-device AI for content tagging, question classification, and natural language responses.

## Build & Run

- **IDE:** Xcode 26.0+
- **Platform:** iOS 26.0 (iPhone & iPad)
- **Open project:** `open foundation-model-sample-iOS-main/la-olympics-2028/la-olympics-2028.xcodeproj`
- **Build/Run:** `Cmd+R` in Xcode or `xcodebuild -project foundation-model-sample-iOS-main/la-olympics-2028/la-olympics-2028.xcodeproj -scheme la-olympics-2028 -destination 'platform=iOS Simulator,name=iPhone 16' build`
- **No test targets** currently exist in the project.
- **No package manager** (no SPM, CocoaPods, or Carthage dependencies).

## Architecture

**MVVM pattern** with two data flow paths:

```
Views (SwiftUI) → ViewModels → DataServices → FoundationModels / JSON Data
```

### Source layout (`foundation-model-sample-iOS-main/la-olympics-2028/la-olympics-2028/`)

- **`la_olympics_2028App.swift`** — App entry point
- **`Views/`** — SwiftUI views: `ContentView` (root TabView), `ScheduleView`, `VirtualAssistantView`
- **`ViewModels/`** — `VirtualAssistantViewModel` (ObservableObject, manages chat state and LLM session)
- **`models/`** — Data models (`OlympicModels.swift`), services (`OlympicDataService`, `VirtualAssistantDataService`), AI result types (`ContentTaggingResult`), error types (`ModelError`)
- **`Helpers/`** — `AppStrings` (centralized string constants and AI prompt templates), `CalendarEventFetcher` (EventKit integration)
- **`Data/`** — Embedded JSON: `olympicsdata.json` (medal results), `olympicsschedule_updated.json` (event schedule)

### Two parallel service/VM paths for the assistant

1. **`VirtualAssistantViewModel`** — Uses `ObservableObject` + `@Published`, creates its own `LanguageModelSession` with a system prompt directly. Currently has significant commented-out code from experimentation.
2. **`VirtualAssistantDataService`** — Uses `@Observable`, separates concerns more cleanly. Runs a multi-step pipeline: content tagging (extracts sport/gender from query) → JSON filtering → AI-powered summarization. The active view (`VirtualAssistantView`) primarily uses this service path.

### FoundationModels integration patterns

- Two model use cases: `SystemLanguageModel(useCase: .contentTagging)` for extracting structured tags, `SystemLanguageModel(useCase: .general)` for free-form responses
- `@Generable` macro on structs (`ContentTaggingResult`, `Category`, `Prompt`) enables structured output generation
- `@Guide` attributes constrain AI output fields
- Always check `model.availability == .available` before creating sessions
- Sessions track state via `session.isResponding` to prevent concurrent requests

### Query processing flow (VirtualAssistantDataService)

1. Classify question category (rules / medals / other) via `questionCategory()`
2. For medal queries: extract content tags → filter `olympicsdata.json` by sport/gender keywords → if single result, format directly; if multiple, use AI to generate summary
3. For rules queries: use `generateContent()` with general model
4. For other queries: use general model for free-form response

## Key Swift compiler settings

- `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — all types default to MainActor unless explicitly opted out
- `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`

## Permissions

- **Calendar:** Full access required (`NSCalendarsFullAccessUsageDescription`) for matching user calendar events with Olympic schedule
