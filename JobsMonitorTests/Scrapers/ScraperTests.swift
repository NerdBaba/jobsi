import XCTest
@testable import JobsMonitorScrapers
import JobsMonitorModels

final class ScraperTests: XCTestCase {
    
    func testGitHubScraperModuleName() {
        let scraper = GitHubScraper()
        XCTAssertEqual(scraper.moduleName, "GitHub")
    }
    
    func testLinkedInScraperModuleName() {
        let scraper = LinkedInScraper()
        XCTAssertEqual(scraper.moduleName, "LinkedIn")
    }
    
    func testModuleManagerRegistration() {
        let manager = ModuleManager.shared
        let scrapers = manager.getActiveScrapers()
        
        // Verify FreshersNow scraper is registered (the only active scraper)
        XCTAssertTrue(scrapers.count >= 1)
        XCTAssertTrue(scrapers.contains { $0.moduleName == "FreshersNow" })
    }
    
    func testAddCustomScraper() {
        let manager = ModuleManager.shared
        
        class TestScraper: JobScraperProtocol {
            let moduleName = "Test"
            func fetchJobs() async throws -> [Job] { [] }
        }
        
        let beforeCount = manager.getActiveScrapers().count
        manager.addScraper(TestScraper())
        let afterCount = manager.getActiveScrapers().count
        
        // Should add the scraper since it's a new module name
        XCTAssertEqual(afterCount, beforeCount + 1)
        
        // Try adding the same scraper again - should not duplicate
        manager.addScraper(TestScraper())
        let finalCount = manager.getActiveScrapers().count
        XCTAssertEqual(finalCount, afterCount)
    }
}
