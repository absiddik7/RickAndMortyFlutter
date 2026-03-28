# Rick & Morty Explorer

### A Production-Style Flutter Character Explorer with Offline Cache and Local Editing

[![Flutter](https://img.shields.io/badge/Flutter-Cross--Platform-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0%20%3C4.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Provider](https://img.shields.io/badge/State%20Management-Provider-4CAF50?style=for-the-badge)](https://pub.dev/packages/provider)

*A feature-rich character explorer built with Flutter, demonstrating Provider-based state management, repository-driven data flow, API integration, local caching, favorites persistence, and editable local overrides.*

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Implementation Approach](#implementation-approach)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [State Management](#state-management-provider-pattern)
- [Data Models](#data-models)
- [UI Components](#ui-components)
- [Getting Started](#getting-started)
- [Design Decisions](#design-decisions)

---

## Overview

The **Rick & Morty Explorer** is a Flutter application that fetches character data from the Rick and Morty API, displays it in a responsive grid-based interface, and supports local persistence features such as favorites and profile edits.

The app combines remote API data with local SQLite storage to provide a smoother user experience, including cached fallback behavior when network requests fail.

### Key Highlights

- **Provider Architecture**: State handled through ChangeNotifier and MultiProvider
- **API + Local Merge**: Remote character data merged with local favorites and edits
- **Offline-Friendly Behavior**: Cached character data used as fallback on API failure
- **Character Editing**: Local override support with reset-to-API behavior
- **Infinite Scrolling**: Paged loading from API with loading placeholders

---

## Features

### Character Browsing
| Feature | Description |
|---------|-------------|
| **Character Grid** | Displays characters in a 2-column card layout |
| **Infinite Pagination** | Loads additional pages when reaching scroll end |
| **Shimmer Loading** | Skeleton placeholders during initial and pagination loading |
| **Detail Navigation** | Tap any character card to open a detailed profile screen |

### Search and Filtering
| Feature | Description |
|---------|-------------|
| **Search** | Real-time filtering by character name and species |
| **Status Chips** | Filter by `All`, `Alive`, `Dead`, and `unknown` |
| **No-Match Handling** | Friendly empty message when no character matches filters |

### Favorites Management
| Feature | Description |
|---------|-------------|
| **Favorite Toggle** | Mark/unmark characters as favorites from detail/grid views |
| **Favorites Screen** | Dedicated grid for favorited characters |
| **Persistent Storage** | Favorites saved locally in SQLite |

### Local Edit Workflow
| Feature | Description |
|---------|-------------|
| **Edit Character** | Update character fields locally through a form screen |
| **Edited Indicator** | Visual badge on detail screen for modified characters |
| **Reset to API Data** | Remove local override and restore original API-backed data |

---

## Screenshots

<div align="center">

### Core Screens

| Character List | Character Details | Edit Character | Favorites |
|:--------------:|:-----------------:|:--------------:|:---------:|
| ![Character List Demo](https://dummyimage.com/320x640/e5e7eb/111827&text=Character+List+Demo) | ![Character Details Demo](https://dummyimage.com/320x640/e5e7eb/111827&text=Character+Details+Demo) | ![Edit Character Demo](https://dummyimage.com/320x640/e5e7eb/111827&text=Edit+Character+Demo) | ![Favorites Demo](https://dummyimage.com/320x640/e5e7eb/111827&text=Favorites+Demo) |

### Search and Filter States

| Search Applied | Status Filter | No Matching Results | Edited Status |
|:--------------:|:--------------------:|:-------------------:|:-------------------:|
| ![Search Demo](https://dummyimage.com/320x640/e5e7eb/111827&text=Search+Demo) | ![Alive Filter Demo](https://dummyimage.com/320x640/e5e7eb/111827&text=Alive+Filter+Demo) | ![Dead Filter Demo](https://dummyimage.com/320x640/e5e7eb/111827&text=Dead+Filter+Demo) | ![No Results Demo](https://dummyimage.com/320x640/e5e7eb/111827&text=No+Results+Demo) |

</div>

Replace each placeholder image URL above with your uploaded screenshot URL when ready.

---

## Architecture

### Layered Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                     UI (Widgets)                    │    │
│  │   Screens │ Cards │ Detail/Edit Forms              │    │
│  └─────────────────────────┬───────────────────────────┘    │
│                            │                                │
│  ┌─────────────────────────▼───────────────────────────┐    │
│  │          PROVIDER (ChangeNotifier State)            │    │
│  │               CharacterProvider                     │    │
│  └─────────────────────────┬───────────────────────────┘    │
└────────────────────────────┼────────────────────────────────┘
				 │
┌────────────────────────────▼────────────────────────────────┐
│                      DOMAIN LAYER                           │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    Data Model                       │    │
│  │                    Character                        │    │
│  └─────────────────────────────────────────────────────┘    │
└────────────────────────────┬────────────────────────────────┘
				 │
┌────────────────────────────▼────────────────────────────────┐
│                       DATA LAYER                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   Repository                        │    │
│  │               CharacterRepository                   │    │
│  └─────────────────────────┬───────────────────────────┘    │
│                            │                                │
│  ┌─────────────────────────▼───────────────────────────┐    │
│  │                 Data Sources                        │    │
│  │      Rick & Morty API │ SQLite (sqflite)           │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| **Presentation** | Screens, widgets, user interaction, navigation |
| **Provider** | Search/filter state, pagination, favorites/edit actions |
| **Domain** | Character model and immutable state updates via `copyWith` |
| **Data** | API calls, SQLite caching, favorites/overrides persistence |

---

## Implementation Approach

### 1. Provider-Based State Management

The app uses **ChangeNotifier + Provider** for central state updates and reactive UI rebuilds.

**Why Provider?**
- Lightweight and easy to scale for this project size
- Clear and readable update flow
- Direct integration with Flutter widget tree

### 2. Repository Pattern with Data Merge

`CharacterRepository` fetches API results, caches base character data, then merges:
- favorite flags from local table
- edited field overrides from local table

This ensures the UI always reflects user-local changes without losing API sync.

### 3. Offline Fallback Strategy

If API requests fail, cached character records are loaded from SQLite. Local favorites and edits are still applied on top of cached data.

### 4. Local Edit + Reset Flow

Users can edit character properties locally. Edits are persisted in an `overrides` table and can be removed with a reset action to restore API-backed values.

---

## Tech Stack

<div align="center">

| Category | Technology | Version Constraint | Purpose |
|:--------:|:----------:|:------------------:|:--------|
| Framework | Flutter | SDK-managed | Cross-platform UI framework |
| Language | Dart | `>=3.0.0 <4.0.0` | Application language |
| State Management | provider | `^6.1.1` | Reactive app state |
| Networking | http | `^1.1.0` | API communication |
| Local Database | sqflite | `^2.3.0` | Persistent local storage |
| Path Utilities | path | `^1.8.3` | Database path handling |
| Image Caching | cached_network_image | `^3.3.0` | Cached network images |
| Loading Skeleton | shimmer | `^3.0.0` | Loading placeholders |
| Utilities | intl | `^0.18.1` | Date/formatting utilities |

</div>

---

## Project Structure

```
rick_morty/
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── db/
│   │   │   └── database_helper.dart
│   │   ├── model/
│   │   │   └── character_model.dart
│   │   ├── provider/
│   │   │   └── character_provider.dart
│   │   ├── repository/
│   │   │   └── character_repository.dart
│   │   └── utils/
│   │       └── constant/
│   │           └── app_constants.dart
│   │
│   └── ui/
│       ├── screens/
│       │   ├── character_list_screen.dart
│       │   ├── character_detail_screen.dart
│       │   ├── edit_character_screen.dart
│       │   └── favorites_screen.dart
│       └── widgets/
│           ├── character_card.dart
│           └── character_grid_card.dart
│
├── test/
│   └── widget_test.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## State Management (Provider Pattern)

### Update Flow

```
┌─────────────┐     ┌────────────────────┐     ┌─────────────┐
│    USER     │────▶│ CharacterProvider  │────▶│ Repository  │
│ INTERACTION │     │ (ChangeNotifier)   │     │ + DB/API    │
└─────────────┘     └─────────┬──────────┘     └──────┬──────┘
                              │                       │
                              ▼                       │
                        ┌─────────────┐               │
                        │ notify      │◀──────────────┘
                        │ listeners   │
                        └──────┬──────┘
                               ▼
                        ┌─────────────┐
                        │ UI Rebuild  │
			            └─────────────┘
```

### Provider Responsibilities

| Component | Responsibilities |
|----------|-------------------|
| **CharacterProvider** | Fetch paged data, manage loading/error flags, apply search/status filtering, toggle favorites, persist edits, reset local overrides |

---

## Data Models

### Character Model

| Property | Type | Description |
|----------|------|-------------|
| `id` | int | Unique character identifier |
| `name` | String | Character name |
| `status` | String | Alive/Dead/unknown |
| `species` | String | Species value |
| `type` | String | Type metadata |
| `gender` | String | Gender value |
| `originName` | String | Origin location name |
| `locationName` | String | Current location name |
| `image` | String | Character image URL |
| `isFavorite` | bool | Local favorite flag |
| `isEdited` | bool | Local edit marker |

### Local Database Tables

| Table | Purpose |
|-------|---------|
| `characters` | Cached API character records |
| `favorites` | Favorite character IDs |
| `overrides` | User-edited character fields |

---

## UI Components

| Component | Purpose | Key Behavior |
|-----------|---------|-------------|
| `CharacterListScreen` | Main exploration screen | Search, status chips, paginated grid, shimmer loading |
| `CharacterDetailScreen` | Character detail view | Hero image, metadata chips, favorite toggle, edit entry |
| `EditCharacterScreen` | Local edit form | Validated text fields, save updates, reset to API data |
| `FavoritesScreen` | Favorite collection | Grid view of locally favorited characters |
| `CharacterGridCard` | Reusable grid card | Cached image, status/species chips, optional favorite button |

---

## Getting Started

### Prerequisites

| Requirement | Version |
|-------------|---------|
| Flutter SDK | Compatible with project Dart SDK constraint |
| Dart SDK | `>=3.0.0 <4.0.0` |
| Android Studio / VS Code | Latest |
| Xcode (for iOS builds on macOS) | Latest stable |

### Installation and Run

```bash
# 1. Clone
git clone <your-repository-url>

# 2. Enter project
cd rick_morty

# 3. Install dependencies
flutter pub get

# 4. Run
flutter run
```

---

## Design Decisions

### Why Provider?

| Consideration | Decision |
|---------------|----------|
| **Complexity Level** | Provider is sufficient and clean for this app scope |
| **Readability** | Minimal boilerplate with direct widget integration |
| **Reactivity** | Efficient UI rebuilds through `Consumer` and `notifyListeners()` |

### Why Repository + SQLite?

```
Remote API Data ──▶ Repository ──▶ Local Cache / Favorites / Overrides
	▲                                    │
	└──────────── Offline Fallback ◀─────┘
```

**Benefits:**
- Supports offline fallback from cached data
- Preserves user favorites and edits across app sessions
- Keeps API and local data concerns separated

### Why Local Override Table?

The `overrides` table enables editable character fields without mutating base cached API records, making reset behavior predictable and safe.
