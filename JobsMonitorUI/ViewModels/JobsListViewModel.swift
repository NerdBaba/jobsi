import Foundation
import AppKit
import JobsMonitorModels
import JobsMonitorScrapers
import JobsMonitorUtils

/// Single source of truth for the displayed job list. Owned by `JobsMonitorApp`
/// via `@StateObject` and injected with `.environmentObject`, so its
/// `JobRepository` cache survives menu open/close cycles and there is never
/// more than one view model.
@MainActor
public final class JobsListViewModel: ObservableObject {
    @Published public var jobs: [Job] = []
    @Published public var categories: [String] = [
        "All", "Software Engineering", "Design", "Data Science", "Product Management"
    ]
    @Published public var filteredJobs: [Job] = []
    @Published public var isLoading = false
    @Published public var lastRefreshDate: Date?

    private let repository: JobRepositoryProtocol
    private let appSettings: AppSettings

    public init(repository: JobRepositoryProtocol = JobRepository(), appSettings: AppSettings? = nil) {
        self.repository = repository
        self.appSettings = appSettings ?? AppSettings.shared
        self.lastRefreshDate = self.appSettings.lastRefreshDate
        filteredJobs = jobs
        
        // Subscribe to settings changes
        setupSettingsBindings()
    }
    
    private func setupSettingsBindings() {
        appSettings.$lastRefreshDate
            .receive(on: RunLoop.main)
            .assign(to: &$lastRefreshDate)
    }

    public func loadJobs() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedJobs = try await repository.fetchJobs()
            self.jobs = fetchedJobs
            self.filteredJobs = fetchedJobs
            updateCategories(from: fetchedJobs)
            
            // Update app settings
            appSettings.lastRefreshDate = Date()
        } catch {
            print("Failed to load jobs: \(error)")
        }
    }
    
    /// Check if it's time to refresh based on the configured interval
    public func shouldRefresh() -> Bool {
        guard let lastRefresh = appSettings.lastRefreshDate else { return true }
        let interval = TimeInterval(appSettings.checkInterval * 60) // Convert minutes to seconds
        return Date().timeIntervalSince(lastRefresh) > interval
    }

    public func filterByCategory(category: String) {
        if category == "All" {
            filteredJobs = jobs
        } else {
            filteredJobs = jobs.filter { $0.category.localizedCaseInsensitiveContains(category) }
        }
    }

    /// Opens the job's apply link, safely no-oping on malformed URLs instead of
    /// crashing the menu-bar process.
    public func openJob(_ job: Job) {
        guard let url = URL(string: job.applyLink) else {
            print("Cannot open malformed apply link: \(job.applyLink)")
            return
        }
        NSWorkspace.shared.open(url)
    }

    /// Adds any categories present in the data that aren't already in the seed
    /// list, without duplicates.
    private func updateCategories(from jobs: [Job]) {
        var known = Set(categories.map { $0.lowercased() })
        for job in jobs where !job.category.isEmpty {
            let lowered = job.category.lowercased()
            if !known.contains(lowered) {
                categories.append(job.category)
                known.insert(lowered)
            }
        }
    }
}
