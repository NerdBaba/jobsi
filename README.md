# JobsMonitor - macOS Menu Bar Job Tracker

A modern, modular macOS application that monitors multiple job boards and displays them in your menu bar. Built with SwiftUI following Apple's best practices.

## 🏗️ Architecture

### Modular Structure

```
JobsMonitor/
├── JobsMonitor/              # Main App Bundle
│   ├── JobsMonitorApp.swift  # Entry point
│   ├── AppDelegate.swift     # App lifecycle
│   └── Info.plist           # Configuration
│
├── JobsMonitorUI/            # UI Layer
│   ├── Views/
│   │   ├── JobsListView.swift         # Main list view
│   │   ├── TabViewContainer.swift     # Category tabs
│   │   └── JobCardView.swift          # Individual job card
│   └── ViewModels/
│       └── JobsListViewModel.swift    # State management
│
├── JobsMonitorModels/        # Domain Models
│   ├── Models/
│   │   └── Job.swift                   # Job data model
│   └── Repositories/
│       └── JobRepository.swift         # Data layer
│
├── JobsMonitorScrapers/      # Scraping Modules
│   └── Modules/
│       └── JobScraper.swift         # Scraper protocols & implementations
│
└── JobsMonitorUtils/         # Utilities
    └── Extensions/
        └── View+Extensions.swift    # Custom extensions
```

### Design Patterns

1. **MVVM (Model-View-ViewModel)**: Clear separation of concerns
2. **Repository Pattern**: Abstracts data source
3. **Protocol-Oriented Programming**: Flexible scraper implementations
4. **Dependency Injection**: Easy testing and maintenance
5. **Observable Objects**: Reactive state management

## ✨ Features

- **Menu Bar Integration**: Dock-less utility app behavior
- **Modular Scrapers**: Plug-and-play for different job boards
- **Tabbed Interface**: Filter jobs by category
- **Lazy Loading**: Efficient memory management
- **Configurable**: User settings via `AppSettings`

## 🔧 Getting Started

### Prerequisites

- macOS 13.0+ (Ventura or later)
- Xcode 15.0+
- Swift 5.9+

### Build & Run

```bash
open JobsMonitor.xcodeproj
# Or from command line:
xcodebuild build -scheme JobsMonitor
```

## 🧩 Adding New Scrapers

Each job board gets its own module:

```swift
final class MyJobBoardScraper: JobScraperProtocol {
    let moduleName = "MyJobBoard"
    
    func fetchJobs() async throws -> [Job] {
        // Your scraping logic here
    }
}
```

Register in `ModuleManager`:

```swift
scrapers.append(MyJobBoardScraper())
```

## 📱 Menu Bar Usage

1. Install the app: Drag `JobsMonitor.app` to Applications
2. Launch it once from Finder to register as a login item
3. Find the briefcase icon in your menu bar
4. Click to see all jobs
5. Tap any job to open the application link

## 🎨 UI Components

### Tab Navigation
Custom tab bar with icons for each category.

### Job Cards
Clean, readable cards showing:
- Job title & company
- Description preview
- Location, date, salary
- Apply button

### Responsive Layout
Adapts to content without scroll jarring.

## 🔍 Best Practices Applied

1. **Swift Concurrency**: `async/await` throughout
2. **Combine Framework**: Reactive data binding
3. **Memory Management**: `@StateObject` and `AnyCancellable` cleanup
4. **Type Safety**: Strong typing with enums where appropriate
5. **Accessibility**: Native iOS accessibility labels
6. **Performance**: Lazy rendering with `LazyVStack`

## 🛠️ Roadmap

- [ ] Implement actual web scrapers
- [ ] Add SQLite persistence
- [ ] Push notifications for new jobs
- [ ] Dark mode support
- [ ] Export to CSV
- [ ] Multiple job search queries

## 📝 License

MIT License - See LICENSE file for details

## 👥 Contributing

Feel free to submit issues and enhancement requests!
