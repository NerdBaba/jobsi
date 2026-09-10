import Foundation
import JobsMonitorModels

/// Concrete repository that aggregates jobs from every scraper registered with
/// `ModuleManager`. Lives in the Scrapers module (which depends on Models), so
/// it can reference the scrapers without creating a circular dependency.
///
/// `public` so the UI layer (a separate SPM target) can use it as the default
/// repository.
public final class JobRepository: JobRepositoryProtocol {

    private var cachedJobs: [Job] = []
    private var cacheDate: Date?
    private let cacheLifetime: TimeInterval = 60 // seconds

    public init() {}

    public func fetchJobs() async throws -> [Job] {
        if !cachedJobs.isEmpty, let date = cacheDate,
           Date().timeIntervalSince(date) < cacheLifetime {
            return cachedJobs
        }

        let jobs = await collectJobs()
        cachedJobs = jobs
        cacheDate = Date()
        return jobs
    }

    private func collectJobs() async -> [Job] {
        var allJobs: [Job] = []

        for scraper in ModuleManager.shared.getActiveScrapers() {
            do {
                let jobs = try await scraper.fetchJobs()
                allJobs.append(contentsOf: jobs)
            } catch {
                print("Failed to scrape \(scraper.moduleName): \(error)")
            }
        }

        // Newest first: smaller "X days ago" value sorts to the top.
        return allJobs.sorted { sortKey($0) < sortKey($1) }
    }

    /// Sort key derived from the leading number of the "posted date" string.
    private func sortKey(_ job: Job) -> Int {
        let digits = job.postedDate.prefix(4).prefix { $0.isNumber }
        return Int(String(digits)) ?? 0
    }
}
