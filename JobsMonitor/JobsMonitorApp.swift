import SwiftUI
import JobsMonitorUI
import JobsMonitorUtils

@main
struct JobsMonitorApp: App {
    /// Shared, app-lifetime view model. The menu-bar popover is destroyed and
    /// recreated on every click, so this `@StateObject` is what keeps the
    /// `JobRepository` cache (and its jobs) alive across opens.
    @StateObject private var viewModel = JobsListViewModel()
    
    /// Initialize app settings on launch
    init() {
        _ = AppSettings.shared
    }

    var body: some Scene {
        MenuBarExtra("Jobs Monitor", systemImage: "briefcase") {
            JobsListView()
                .environmentObject(viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}
