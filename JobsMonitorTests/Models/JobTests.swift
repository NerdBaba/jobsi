import XCTest
@testable import JobsMonitorModels

final class JobTests: XCTestCase {
    func testJobInitialization() {
        let job = Job(
            id: UUID(),
            title: "Test Job",
            company: "Test Co.",
            description: "Test Description",
            category: "Engineering",
            location: "Remote",
            postedDate: "1 day ago",
            applyLink: "https://example.com"
        )
        
        XCTAssertEqual(job.title, "Test Job")
        XCTAssertEqual(job.company, "Test Co.")
    }
    
    func testDescriptionPreview() {
        let longDescription = String(repeating: "A", count: 200)
        let job = Job(
            id: UUID(),
            title: "Test Job",
            company: "Test Co.",
            description: longDescription,
            category: "Engineering",
            location: "Remote",
            postedDate: "1 day ago",
            applyLink: "https://example.com"
        )
        
        XCTAssertTrue(job.descriptionPreview.count <= 123) // 120 chars + "..."
    }
}
