import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // First-launch setup (e.g. registering a login item) can go here.
    }

    /// With no `WindowGroup` (menu-bar-only app), there are no windows to keep
    /// the process alive on; return false so the app stays resident.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
