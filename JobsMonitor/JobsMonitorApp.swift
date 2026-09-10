import SwiftUI
import JobsMonitorUI

@main
struct JobsMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Jobs Monitor", systemImage: "briefcase") {
            JobsListView()
        }
        .menuBarExtraStyle(.window)
    }
}
