import Foundation
import JobsMonitorModels

/// Base protocol for all job scrapers
protocol JobScraperProtocol {
    var moduleName: String { get }
    func fetchJobs() async throws -> [Job]
}

/// Module configuration for each scraper source
struct ScraperModule {
    let name: String
    let baseUrl: URL
    let categories: [String]
    let isActive: Bool
    
    init(name: String, baseUrl: String, categories: [String] = [], isActive: Bool = true) {
        self.name = name
        self.baseUrl = URL(string: baseUrl)!
        self.categories = categories
        self.isActive = isActive
    }
}

// MARK: - GitHub Scraper (Placeholder)
final class GitHubScraper: JobScraperProtocol {
    let moduleName = "GitHub"
    
    func fetchJobs() async throws -> [Job] {
        // GitHub Jobs API was deprecated in 2024. 
        // To implement: Use GitHub GraphQL API or scrape github.com/jobs
        // Requires authentication and careful rate limiting.
        print("GitHubScraper: Not implemented - API deprecated")
        return []
    }
}

// MARK: - LinkedIn Scraper (Placeholder)
final class LinkedInScraper: JobScraperProtocol {
    let moduleName = "LinkedIn"
    
    func fetchJobs() async throws -> [Job] {
        // LinkedIn requires authentication and has strict anti-scraping measures.
        // To implement: Use official LinkedIn API or Selenium/Puppeteer with user agents.
        print("LinkedInScraper: Not implemented - requires authentication")
        return []
    }
}

// MARK: - Indeed Scraper (Placeholder)
final class IndeedScraper: JobScraperProtocol {
    let moduleName = "Indeed"
    
    func fetchJobs() async throws -> [Job] {
        // Indeed has a public API but requires API key registration.
        // To implement: Register at indeed.com/publisher and use their API.
        print("IndeedScraper: Not implemented - requires API key")
        return []
    }
}

// MARK: - Stack Overflow Scraper (Placeholder)
final class StackOverflowScraper: JobScraperProtocol {
    let moduleName = "StackOverflow"
    
    func fetchJobs() async throws -> [Job] {
        // Stack Overflow Jobs API requires authentication.
        // To implement: Use Stack Exchange API with OAuth.
        print("StackOverflowScraper: Not implemented - requires API key")
        return []
    }
}

// MARK: - Module Manager
final class ModuleManager {
    static let shared = ModuleManager()
    
    private var scrapers: [any JobScraperProtocol] = []
    
    init() {
        registerScrapers()
    }
    
    private func registerScrapers() {
        // Only register the FreshersNow scraper since it's the only fully implemented one.
        // Other scrapers are placeholders that return empty arrays.
        scrapers = [
            FreshersNowScraper()
        ]
    }
    
    func getActiveScrapers() -> [any JobScraperProtocol] {
        scrapers
    }
    
    func addScraper(_ scraper: any JobScraperProtocol) {
        // Check if scraper with same module name already exists
        if !scrapers.contains(where: { $0.moduleName == scraper.moduleName }) {
            scrapers.append(scraper)
        }
    }
}
