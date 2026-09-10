import XCTest
@testable import JobsMonitorUI
import JobsMonitorModels
@MainActor
final class JobsListViewModelTests: XCTestCase {
    
    var viewModel: JobsListViewModel!
    var mockRepository: MockJobRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockJobRepository(jobs: [.previewJob])
        viewModel = JobsListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testInitialJobsAreEmpty() {
        XCTAssertEqual(viewModel.jobs.count, 0)
    }
    
    func testFilterByCategory() async {
        await viewModel.loadJobs()
        
        let engineeringJobs = viewModel.jobs.filter { $0.category.lowercased().contains("software") }
        
        viewModel.filterByCategory(category: "Software Engineering")
        
        XCTAssertEqual(viewModel.filteredJobs.count, engineeringJobs.count)
    }
    
    func testAllCategoryShowsAllJobs() async {
        await viewModel.loadJobs()
        
        viewModel.filterByCategory(category: "All")
        
        XCTAssertEqual(viewModel.filteredJobs.count, viewModel.jobs.count)
    }
}

class MockJobRepository: JobRepositoryProtocol {
    private let jobsToReturn: [Job]
    
    init(jobs: [Job]) {
        self.jobsToReturn = jobs
    }
    
    func fetchJobs() async throws -> [Job] {
        return jobsToReturn
    }
}
