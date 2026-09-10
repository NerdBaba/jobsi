import Foundation
import Combine

/// Manages user preferences and app settings.
/// Public so it can be accessed across package targets.
public final class AppSettings {
    public static let shared = AppSettings()
    
    private let userDefaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var lastRefreshDate: Date?
    @Published public var enabledModules: [String] = []
    @Published public var checkInterval: Int = 30 // minutes
    @Published public var notifyOnNewJob: Bool = true
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        loadSettings()
        setupBindings()
    }
    
    private func loadSettings() {
        lastRefreshDate = userDefaults.object(forKey: "lastRefreshDate") as? Date
        enabledModules = userDefaults.array(forKey: "enabledModules") as? [String] ?? []
        checkInterval = userDefaults.integer(forKey: "checkInterval")
        notifyOnNewJob = userDefaults.bool(forKey: "notifyOnNewJob")
    }
    
    private func setupBindings() {
        $lastRefreshDate
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] date in
                self?.userDefaults.set(date, forKey: "lastRefreshDate")
            }
            .store(in: &cancellables)
        
        $enabledModules
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] modules in
                self?.userDefaults.set(modules, forKey: "enabledModules")
            }
            .store(in: &cancellables)
        
        $checkInterval
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] interval in
                self?.userDefaults.set(interval, forKey: "checkInterval")
            }
            .store(in: &cancellables)
        
        $notifyOnNewJob
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] enabled in
                self?.userDefaults.set(enabled, forKey: "notifyOnNewJob")
            }
            .store(in: &cancellables)
    }
    
    public func resetToDefaults() {
        userDefaults.removeObject(forKey: "lastRefreshDate")
        userDefaults.removeObject(forKey: "enabledModules")
        userDefaults.removeObject(forKey: "checkInterval")
        userDefaults.removeObject(forKey: "notifyOnNewJob")
        loadSettings()
    }
}
