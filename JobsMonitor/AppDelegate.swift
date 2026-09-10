import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Handle first launch setup if needed
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep running as menu bar app
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        // Refresh jobs when app becomes active
        NotificationCenter.default.post(name: .refreshJobs, object: nil)
    }
}

extension Notification.Name {
    static let refreshJobs = Notification.Name("refreshJobs")
}
