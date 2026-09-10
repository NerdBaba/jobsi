import Foundation
import Combine
import AppKit
import JobsMonitorModels
import JobsMonitorScrapers

class JobsListViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var categories: [String] = ["All", "Software Engineering", "Design", "Data Science", "Product Management"]
    @Published var filteredJobs: [Job] = []
    @Published var isLoading = false
    
    private let repository: JobRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: JobRepositoryProtocol = JobRepository()) {
        self.repository = repository
        filteredJobs = jobs
    }
    
    func loadJobs() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedJobs = try await repository.fetchJobs()
            await MainActor.run {
                self.jobs = fetchedJobs
                self.filteredJobs = fetchedJobs
            }
            
            // Update categories based on available data
            updateCategories(from: fetchedJobs)
            
        } catch {
            print("Failed to load jobs: \(error)")
        }
    }
    
    func filterByCategory(category: String) {
        if category == "All" {
            filteredJobs = jobs
        } else {
            filteredJobs = jobs.filter { $0.category.lowercased().contains(category.lowercased()) }
        }
    }
    
    func openJob(_ job: Job) {
        NSWorkspace.shared.open(URL(string: job.applyLink)!)
    }
    
    private func updateCategories(from jobs: [Job]) {
        guard let firstCategory = jobs.first?.category else { return }
        
        if !categories.contains(where: { $0.lowercased() == firstCategory.lowercased() }) {
            categories.append(firstCategory)
        }
    }
}
