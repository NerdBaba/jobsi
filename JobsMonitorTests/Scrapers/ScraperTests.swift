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
        
        // Verify all default scrapers are registered
        XCTAssertTrue(scrapers.count >= 4)
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
        
        XCTAssertEqual(afterCount, beforeCount + 1)
    }
}
