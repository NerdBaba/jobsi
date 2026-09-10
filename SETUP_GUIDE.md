# JobsMonitor Setup Guide

## Quick Start

### 1. Open in Xcode

```bash
open JobsMonitor.xcodeproj
```

If you don't have an Xcode project file yet, create one:

```bash
xcodebuild -create-from-packageinfo Info.plist output-file JobsMonitor.xcodeproj/project.pbxproj
```

Or manually create the project in Xcode IDE:
1. File → New → Project → macOS App
2. Configure as "App" (not Document)
3. Enable "Use Storyboards" = No
4. Enable "Interface Builder" = No  
5. Select SwiftUI as UI Framework

### 2. Add Files to Project

Drag all files from this repository into Xcode:
- **JobsMonitor/** folder → Create new group
- **JobsMonitorUI/** folder → Create new group
- **JobsMonitorModels/** folder → Create new group
- **JobsMonitorScrapers/** folder → Create new group
- **JobsMonitorUtils/** folder → Create new group
- **JobsMonitorTests/** folder → Create new test group

### 3. Configure Info.plist

Ensure `LSUIElement` is set to `true`:

```xml
<key>LSUIElement</key>
<true/>
```

This makes it a dockless menu bar app.

### 4. Build & Run

- Command + B (Build)
- Command + R (Run)

The app will appear as a briefcase icon in your menu bar.

## Development Workflow

### 1. Implement a Scraper

Example: Adding a new job board

```swift
final class MyJobBoardScraper: JobScraperProtocol {
    let moduleName = "MyJobBoard"
    
    func fetchJobs() async throws -> [Job] {
        // Fetch jobs from API or scrape HTML
        let jobs = await parseJobsFromWeb(...)
        
        return jobs
    }
}
```

Register it:

```swift
// In ModuleManager.registerScrapers()
scrapers.append(MyJobBoardScraper())
```

### 2. Test Your Scraper

Create unit tests:

```swift
func testMyScraperFetchesJobs() async throws {
    let scraper = MyJobBoardScraper()
    let jobs = try await scraper.fetchJobs()
    
    XCTAssertEqual(jobs.count > 0, true)
}
```

### 3. Customize UI

Edit views in `JobsMonitorUI/Views/`:

- Modify colors, fonts, spacing
- Add custom icons
- Change tab layout
- Adjust card layout

### 4. Configure Settings

Use `AppSettings.shared` for user preferences:

```swift
// Example in settings panel
.toggle(isOn: $appSettings.notifyOnNewJob) {
    Text("Notify on new job")
}
```

Settings persist via UserDefaults automatically.

## Common Tasks

### How to Add New Tab Category

1. Edit `JobsListViewModel.categories`:
   ```swift
   var categories: [String] = ["All", "Software Engineering", "Design", "Data Science", "Product Management", "YourNewCategory"]
   ```

2. Update filtering logic if needed

### How to Customize Job Card Appearance

Edit `JobCardView.swift`:
```swift
// Change font size
Text(job.title).font(.title) // Larger
Text(job.company).font(.caption) // Smaller

// Add more metadata
Button(action: { ... }) {
    Text("Save Job")
    Image(systemName: "bookmark")
}
```

### How to Handle Notifications

Since its a dockless app, use NSUserNotificationCenter:

```swift
import UserNotifications

func showNotification(title: String, body: String) {
    UNUserNotificationCenter.current().delegate = self
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request)
}
```

### How to Make Changes Persistent

Use `UserDefaults`:

```swift
let defaults = UserDefaults.standard
defaults.set(myValue, forKey: "myKey")
defaults.synchronize()
```

Settings already implemented in `AppSettings.swift`.

## Debugging Tips

### 1. Check Menu Bar Icon

If the app isn't showing up:
- Launch from Finder/Applications folder
- Go to System Preferences → General → Show item in menu bar

### 2. View Logs

In Xcode Console:
- Window → Devices and Simulators → Console
- Or run: `log stream --info`

### 3. Test Scraper in Playground

Create a Swift Playgrounds project:
```swift
let scraper = IndeedScraper()
let jobs = try await scraper.fetchJobs()
print(jobs.count)
```

### 4. Memory Issues

Check for memory leaks:
- Use Address Sanitizer
- Enable StoreKit Trace
- Monitor RAM usage in Activity Monitor

### 5. UI Updates Not Appearing

Common issues:
- Missing `@MainActor` annotation
- Incorrect `@Published` property wrappers
- Not calling `.main` scheduler in Combine pipelines

## Performance Optimization

### Lazy Loading

Already implemented with `LazyVStack`. For even better performance:

```swift
ForEach(visibleJobs, id: \.id) { job in
    LoadMoreButton(afterJobId: job.id) {
        Task { await loadMoreJobs() }
    }
}
```

### Debouncing Network Requests

In ViewModel:
```swift
$refreshTrigger
    .debounce(for: .seconds(2), scheduler: RunLoop.main)
    .sink { _ in loadJobs() }
    .store(in: &cancellables)
```

### Caching Strategy

Enhance repository caching:
```swift
private var cacheTimestamp: Date?
private let cacheDuration: TimeInterval = 300 // 5 minutes

func shouldRefreshCache() -> Bool {
    guard let timestamp = cacheTimestamp else { return true }
    return Date().timeIntervalSince(timestamp) > cacheDuration
}
```

## Testing Checklist

### Unit Tests
- [ ] Job model initialization
- [ ] Scraper returns expected data format
- [ ] Repository aggregates correctly
- [ ] ViewModel filters properly
- [ ] Settings update persists

### Integration Tests
- [ ] Full flow: App launch → Load jobs → Display
- [ ] Menu bar click shows window
- [ ] Job link opens correctly
- [ ] Refresh works

### UI Tests
- [ ] Tabs switch correctly
- [ ] Job cards render without errors
- [ ] Apply button opens URL
- [ ] Status bar updates

## Troubleshooting

### Error: "No main interface found"
Solution: Ensure `JobsMonitorApp.swift` exists and uses `@main`

### Error: "Module not found"
Solution: Check target membership for each file

### Error: "Cannot find type 'Job'"
Solution: Verify JobsMonitorModels module is added to targets

### Menu bar icon not appearing
Solution: Check Info.plist has `LSUIElement = true`

### App crashes immediately
Check console logs for crash report, likely unmet dependencies or nil unwrapping

## Next Steps

1. **Implement Real Scrapers**: Replace placeholder scrapers with actual web scraping/API calls
2. **Add Persistence**: Integrate SQLite or CoreData
3. **Notifications**: Set up push notifications for new jobs
4. **Preferences Panel**: Add settings view within menu bar
5. **Login Items**: Add to startup items automatically
6. **Analytics**: Track which jobs get clicked most
7. **Export Feature**: Export jobs to CSV or JSON

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Menu Bar Apps](https://developer.apple.com/design/human-interface-guidelines/macos/menus/menu-bar-apps)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [Swift Concurrency](https://developer.apple.com/videos/play/wwdc2021/10140/)

---

Happy coding! 🚀
