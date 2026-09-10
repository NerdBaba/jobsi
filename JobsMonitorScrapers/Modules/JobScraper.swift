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

// MARK: - GitHub Scraper Example
final class GitHubScraper: JobScraperProtocol {
    let moduleName = "GitHub"
    
    func fetchJobs() async throws -> [Job] {
        // TODO: Implement GitHub API or scraping logic
        await Task.yield()
        
        return []
    }
}

// MARK: - LinkedIn Scraper Example
final class LinkedInScraper: JobScraperProtocol {
    let moduleName = "LinkedIn"
    
    func fetchJobs() async throws -> [Job] {
        // TODO: Implement LinkedIn scraping logic
        await Task.yield()
        
        return []
    }
}

// MARK: - Indeed Scraper Example
final class IndeedScraper: JobScraperProtocol {
    let moduleName = "Indeed"
    
    func fetchJobs() async throws -> [Job] {
        // TODO: Implement Indeed scraping logic
        await Task.yield()
        
        return []
    }
}

// MARK: - Stack Overflow Scraper Example
final class StackOverflowScraper: JobScraperProtocol {
    let moduleName = "StackOverflow"
    
    func fetchJobs() async throws -> [Job] {
        // TODO: Implement Stack Overflow Jobs scraping logic
        await Task.yield()
        
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
        scrapers = [
            GitHubScraper(),
            LinkedInScraper(),
            IndeedScraper(),
            StackOverflowScraper(),
            FreshersNowScraper()
        ]
    }
    
    func getActiveScrapers() -> [any JobScraperProtocol] {
        scrapers
    }
    
    func addScraper(_ scraper: any JobScraperProtocol) {
        scrapers.append(scraper)
    }
}
