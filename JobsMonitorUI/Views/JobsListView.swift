import SwiftUI

public struct JobsListView: View {
    @StateObject private var viewModel = JobsListViewModel()
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Tab Navigation
            TabViewContainer(selectedTab: $selectedTab)
            
            Divider()
            
            // Content Area with Scroll
            GeometryReader { geometry in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredJobs, id: \.id) { job in
                            JobCardView(job: job)
                                .onTapGesture {
                                    viewModel.openJob(job)
                                }
                        }
                    }
                    .padding()
                }
            }
            .frame(minHeight: 400)
            
            // Status Bar
            statusBarView
        }
        .frame(width: 600, height: 600)
        .task {
            await viewModel.loadJobs()
        }
        .onChange(of: selectedTab) { newValue in
            viewModel.filterByCategory(category: viewModel.categories[newValue])
        }
    }
    
    @ViewBuilder
    private var statusBarView: some View {
        HStack {
            Text("\(viewModel.jobs.count) jobs found")
            Spacer()
            Button("Refresh", action: { Task { await viewModel.loadJobs() }})
                .buttonStyle(.borderless)
                .help("Refresh jobs")
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    JobsListView()
}
