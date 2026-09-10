import Foundation

/// Abstraction over the job data source, kept dependency-free so the domain
/// layer never depends on a concrete scraper implementation.
public protocol JobRepositoryProtocol {
    func fetchJobs() async throws -> [Job]
}
