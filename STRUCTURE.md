# Project Structure Overview

```
jobsi/
│
├── JobsMonitor.xcodeproj/           # Xcode project
│   ├── project.pbxproj             # Main project file
│   └── project.pbxproj.backup      # Placeholder backup (generated via Xcode)
│
├── JobsMonitor/                     # Main App Bundle
│   ├── JobsMonitorApp.swift        # @main entry point (MenuBarExtra)
│   ├── AppDelegate.swift           # NSApplicationDelegate
│   ├── Info.plist                  # LSUIElement = true (dockless)
│   └── JobsMonitor-Bridging-Header.h
│
├── JobsMonitorUI/                   # UI Layer (MVVM)
│   ├── Views/
│   │   ├── JobsListView.swift      # Main scrollable list + status bar
│   │   ├── TabViewContainer.swift  # Category navigation tabs
│   │   └── JobCardView.swift       # Individual job card + apply button
│   └── ViewModels/
│       └── JobsListViewModel.swift # State management & filtering
│
├── JobsMonitorModels/               # Domain Layer
│   ├── Models/
│   │   └── Job.swift               # public Codable/Hashable struct
│   └── Repositories/
│       └── JobRepository.swift     # public JobRepositoryProtocol (domain contract)
│
├── JobsMonitorScrapers/             # Scraping / Data Logic
│   └── Modules/
│       ├── JobScraper.swift        # JobScraperProtocol + stub scrapers + ModuleManager
│       ├── FreshersNowScraper.swift # Active FreshersNow proxy scraper
│       └── JobRepository.swift     # public JobRepository (aggregates scrapers)
│
├── JobsMonitorUtils/                # Utilities
│   ├── AppSettings.swift           # UserDefaults-backed settings
│   └── Extensions/
│       └── View+Extensions.swift   # SwiftUI view extensions
│
├── JobsMonitorTests/                # Unit Tests
│   ├── Models/
│   │   └── JobTests.swift          # Model + descriptionPreview tests
│   ├── Scrapers/
│   │   ├── ScraperTests.swift      # Scraper registration tests
│   │   └── FreshersNowScraperTests.swift # Link validation + HTML parsing tests
│   └── ViewModels/
│       └── JobsListViewModelTests.swift
│
├── Package.swift                    # Swift Package Manager config (multi-module)
├── README.md                        # User documentation
├── ARCHITECTURE.md                  # Technical architecture
├── STRUCTURE.md                     # This file
├── FRESHERSNOW_MODULE.md            # FreshersNow scraper deep-dive
├── SETUP_GUIDE.md                   # Developer setup guide
├── test_proxy.sh                    # Proxy connectivity probe
└── .gitignore                       # Git ignore rules
```

## Key Dependencies

### Frameworks
- **SwiftUI**: UI framework
- **Combine**: Reactive programming
- **AppKit**: Menu bar / NSWorkspace / NSColor integration
- **Foundation**: Core data types, URLSession

### Design Patterns
- MVVM (Model-View-ViewModel)
- Repository Pattern
- Dependency Injection
- Protocol-Oriented Programming
- Observer Pattern (Combine)

## How It Works

1. **Launch**: App starts as dockless menu bar item (`LSUIElement = true`)
2. **Menu Click**: User clicks briefcase icon → `JobsListView` appears
3. **Load Data**: ViewModel calls `JobRepository.fetchJobs` → Repository iterates every scraper from `ModuleManager` (FreshersNow is active; GitHub/LinkedIn/Indeed/StackOverflow are stubs)
4. **Display**: Jobs shown in tabbed list with category filters
5. **Interact**: Tap job card → opens the company career link in the default browser
6. **Hide**: Window closes automatically when clicking elsewhere

## Memory Efficiency

- `LazyVStack`: Only renders visible items
- 60-second in-memory cache in `JobRepository` prevents duplicate fetches
- Settings persisted via `AppSettings` (UserDefaults)
- Scraper caps parse at the first 20 unique postings

## Cross-Module Access

Each top-level folder is an SPM target (its own module), so the data types that
cross boundaries are declared `public`:

- `Job`, `JobRepositoryProtocol` in **JobsMonitorModels**
- `JobRepository` in **JobsMonitorScrapers** (depends on Models)
- **JobsMonitorUI** depends on Models + Scrapers; its `JobsListViewModel` defaults
  to `JobRepository()`.

## Next Steps

1. Implement real scraping logic for GitHub/LinkedIn/Indeed/StackOverflow
2. Add SQLite/CoreData for persistence
3. Implement push notifications for new jobs
4. Add dark mode support
5. Create settings panel
