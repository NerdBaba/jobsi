# JobsMonitor Architecture Documentation

## Overview

JobsMonitor is a modular macOS menu bar application built with SwiftUI following Apple's best practices. The app uses an MVVM architecture with protocol-oriented design patterns.

## 📦 Modular Structure

### 1. **JobsMonitor** - Application Bundle
The main entry point that ties everything together.

- `JobsMonitorApp.swift`: App lifecycle and Scene configuration
- `AppDelegate.swift`: Handles menu bar behavior and app state
- `Info.plist`: Configuration for dockless behavior (`LSUIElement = true`)

### 2. **JobsMonitorUI** - Presentation Layer
Contains all UI components and ViewModels using MVVM pattern.

#### Views (`.swift` files in `/Views/`)
- **JobsListView.swift**: Main container view showing all jobs
  - Uses `@StateObject` for viewModel
  - Implements ScrollView with LazyVStack for performance
  - Displays category tabs and job cards
  
- **TabViewContainer.swift**: Custom tab navigation
  - Horizontal layout with icons
  - Smooth animations for tab switching
  - Filter-based navigation
  
- **JobCardView.swift**: Individual job display
  - Shows job details in card format
  - Action buttons with styling
  - Tap gesture for opening links

#### ViewModels (`/ViewModels/`)
- **JobsListViewModel.swift**: 
  - `ObservableObject` with `@Published` properties
  - Manages job data filtering by category
  - Coordinates with repository layer
  - Provides `openJob()` action handler

### 3. **JobsMonitorModels** - Domain Layer
Pure Swift models and data repository protocols.

#### Models (`/Models/`)
- **Job.swift**: 
  - Codable struct conforming to Identifiable and Hashable
  - Computed property `descriptionPreview` for truncated text
  - Static preview instance for testing/UI

#### Repositories (`/Repositories/`)
- **JobRepository.swift** (Models): `public protocol JobRepositoryProtocol` — the
  domain contract only (dependency-free, so Models never depends on Scrapers).
- **JobRepository.swift** (Scrapers/Modules): the concrete `public final class
  JobRepository` that conforms to the protocol by iterating
  `ModuleManager.shared.getActiveScrapers()`, caching results for 60s, and
  sorting newest-first. This lives in the Scrapers module so it can reference
  the scrapers without a circular dependency.

### 4. **JobsMonitorScrapers** - Business Logic
Protocol-oriented scraper implementations.

#### Modules (`/Modules/`)
Each job board source gets its own implementation:

```swift
protocol JobScraperProtocol {
    var moduleName: String { get }
    func fetchJobs() async throws -> [Job]
}
```

Available scrapers:
- `GitHubScraper` - GitHub Jobs API (stub)
- `LinkedInScraper` - LinkedIn job boards (stub)
- `IndeedScraper` - Indeed aggregation (stub)
- `StackOverflowScraper` - Stack Overflow Jobs (stub)
- `FreshersNowScraper` - Active. Scrapes freshersnow.com via a CORS proxy and
  filters to legitimate career links (with a deterministic fallback).

**ModuleManager**: Central coordinator
- Registers all scrapers
- Provides access to active scrapers only
- Allows dynamic addition of custom scrapers

### 5. **JobsMonitorUtils** - Infrastructure
Utility functions and extensions.

#### Extensions (`/Extensions/`)
- **View+Extensions.swift**: Custom SwiftUI extensions
- Helper types like `LazyLoader`

#### Core Utilities
- **AppSettings.swift**: User preferences management
  - `@Published` properties backed by UserDefaults
  - Reactive updates via Combine
  - Supports settings: check interval, notifications, enabled modules

## 🏗️ Design Patterns Applied

### 1. **MVVM (Model-View-ViewModel)**
Separation of concerns:
- **Model**: Pure data structures (Job)
- **View**: SwiftUI views with minimal logic
- **ViewModel**: State management and business logic

### 2. **Dependency Injection**
```swift
init(repository: JobRepositoryProtocol = JobRepository())
```
- Easy to test with mocks
- Flexible for different data sources

### 3. **Repository Pattern**
Abstraction over data sources:
- Hides complexity of multiple scrapers
- Provides unified interface (`fetchJobs()`)
- Enables caching and offline support later

### 4. **Protocol-Oriented Programming**
Instead of class inheritance:
- `JobScraperProtocol` defines common interface
- Each scraper implements independently
- Open-ended extensibility

### 5. **Observer Pattern**
Combine framework for reactive updates:
- `@Published` properties notify subscribers
- Cancellable subscriptions prevent memory leaks
- Settings updates persist automatically

## 🔄 Data Flow

```mermaid
graph TD
    A[User opens menu bar] --> B[JobsListView loads]
    B --> C[JobsListViewModel.init]
    C --> D[JobRepository.fetchJobs]
    D --> E[ModuleManager.getActiveScrapers]
    E --> F[Each Scraper.fetchJobs]
    F --> G[Return [Job]]
    G --> H[Aggregate & Sort]
    H --> I[Cached in Repository]
    I --> J[Published to ViewModel]
    J --> K[View updates UI]
```

## 💾 Memory Management

### Best Practices Implemented
1. **LazyVStack**: Renders items on-demand
2. **@StateObject**: One instance per hierarchy
3. **AnyCancellable cleanup**: Prevents retain cycles
4. **Weak references**: Where needed in closures

### Performance Optimizations
- Lazy loading of job cards
- Cached repository responses
- Debounced setting updates (1 second)
- Async/await for network operations

## 🧩 Extensibility

### Adding New Job Boards

1. Create scraper in `JobsMonitorScrapers/Modules/`
2. Conform to `JobScraperProtocol`
3. Implement `fetchJobs()` with your logic
4. Register in `ModuleManager.registerScrapers()`

### Adding New Categories

1. Update `JobsListViewModel.categories` array
2. Extend tab rendering logic if needed
3. Add filter conditions in `filterByCategory()`

### Alternative Data Sources

1. Implement new `JobRepositoryProtocol`
2. Inject into ViewModel during initialization
3. Swap out default repository

## 🎯 Best Practices Checklist

- ✅ SwiftUI declarative syntax
- ✅ Swift concurrency with async/await
- ✅ Combine for reactive programming
- ✅ Protocol-first design
- ✅ Minimal boilerplate code
- ✅ Strong type safety
- ✅ Comprehensive error handling
- ✅ Unit test coverage
- ✅ Clear separation of layers

## 📝 File Organization Rationale

Each module has a clear responsibility:
- **Models**: Data definitions only (no logic)
- **Repositories**: Data fetching only (no UI)
- **Views**: Display only (minimal state)
- **ViewModels**: State + logic coordination
- **Utils**: Cross-cutting concerns

This organization makes it easy to:
- Find where to make changes
- Understand dependencies at a glance
- Test each component independently
- Scale the codebase as features grow

## 🔮 Future Architectural Decisions

Consider these improvements:
- Add GraphQL for centralized data
- Integrate CoreData for persistence
- Use swift-package-manager for internal deps
- Implement proper error types instead of throwing errors
- Add dependency injection framework (e.g., SwiftyDI)
