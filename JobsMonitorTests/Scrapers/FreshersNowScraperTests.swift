import XCTest
@testable import JobsMonitorScrapers
import JobsMonitorModels

final class FreshersNowScraperTests: XCTestCase {

    var scraper: FreshersNowScraper!

    override func setUp() {
        super.setUp()
        scraper = FreshersNowScraper()
    }

    override func tearDown() {
        scraper = nil
        super.tearDown()
    }

    // MARK: - Identity

    func testModuleName() {
        XCTAssertEqual(scraper.moduleName, "FreshersNow")
    }

    // MARK: - Link validation

    func testValidCareerLinkDetection() {
        XCTAssertTrue(scraper.isValidCareerLink("https://careers.google.com/jobs/results/12345"))
        XCTAssertTrue(scraper.isValidCareerLink("https://www.linkedin.com/jobs/view/67890"))
        XCTAssertTrue(scraper.isValidCareerLink("https://company.com/careers/software-engineer"))
        XCTAssertTrue(scraper.isValidCareerLink("https://apply.amazon.com/job/abc123"))
    }

    func testInvalidCareerLinkDetection() {
        XCTAssertFalse(scraper.isValidCareerLink("https://bit.ly/xyz123"))
        XCTAssertFalse(scraper.isValidCareerLink("https://tinyurl.com/shortlink"))
        XCTAssertFalse(scraper.isValidCareerLink("https://example.com/?ref=fake&campaign=true"))
        XCTAssertFalse(scraper.isValidCareerLink("https://adfly.com/link"))
    }

    // MARK: - HTML parsing (pure, no network)

    func testParseJobsFromHTMLExtractsValidLinksOnly() {
        let html = """
        <html><body>
          <article>
            <h3>Senior Java Developer</h3>
            <a href="https://careers.tcs.com/jobs/java-developer-2026">Apply Now</a>
            <a href="https://bit.ly/fake-apply-link">Fake Apply</a>
          </article>
        </body></html>
        """

        let jobs = scraper.parseJobsFromHTML(html)

        XCTAssertEqual(jobs.count, 1, "Only the legitimate career link should yield a job")
        XCTAssertEqual(jobs.first?.applyLink, "https://careers.tcs.com/jobs/java-developer-2026")
        XCTAssertFalse(jobs.contains { $0.applyLink.contains("bit.ly") })
    }

    func testParseJobsFromHTMLReturnsEmptyForNoCareerLinks() {
        let html = """
        <html><body>
          <article><a href="/internal/posting">Read more</a></article>
        </body></html>
        """
        XCTAssertTrue(scraper.parseJobsFromHTML(html).isEmpty)
    }

    func testParseJobsFromHTMLDeduplicatesLinks() {
        let html = """
        <html><body>
          <a href="https://careers.google.com/jobs/1">Apply</a>
          <a href="https://careers.google.com/jobs/1">Duplicate</a>
        </body></html>
        """
        XCTAssertEqual(scraper.parseJobsFromHTML(html).count, 1)
    }

    // MARK: - Fallback generation

    func testGenerateCareersURL() {
        guard let url = scraper.generateFreshersNowCareersURL(company: "TCS", role: "Java Developer") else {
            XCTFail("URL should be generated")
            return
        }

        XCTAssertTrue(url.absoluteString.contains("tcs-java-developer"))
        XCTAssertEqual(url.host, "www.freshersnow.com")
    }

    func testFallbackJobsAreValidAndNonEmpty() {
        let jobs = scraper.generateFallbackJobs()

        XCTAssertEqual(jobs.count, 8)
        XCTAssertTrue(jobs.allSatisfy { scraper.isValidCareerLink($0.applyLink) })
        XCTAssertEqual(Set(jobs.map(\.id)).count, jobs.count, "Each job should be unique")
    }

    func testDateFormatting() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let formatted = formatter.string(from: date)

        // Should match the expected human format, e.g. "Sep 10, 2026"
        XCTAssertTrue(formatted.contains(","))
        XCTAssertTrue(formatted.contains("2026"))
    }
}
