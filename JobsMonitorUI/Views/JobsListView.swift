import SwiftUI
import JobsMonitorUtils

public struct JobsListView: View {
    @EnvironmentObject private var viewModel: JobsListViewModel
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Tab Navigation
            TabViewContainer(selectedTab: $selectedTab)

            Divider()
                .padding(.horizontal)

            // Content Area with Scroll
            ScrollView {
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading jobs...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else if viewModel.filteredJobs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "briefcase")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No jobs found")
                            .font(.headline)
                        Text("Try refreshing or check your connection")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredJobs, id: \.id) { job in
                            JobCardView(job: job)
                        }
                    }
                    .padding()
                }
            }
            .frame(maxHeight: 480)

            // Status Bar
            statusBarView
        }
        .frame(width: 540, height: 560)
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
            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.jobs.count) jobs found")
                if let lastRefresh = viewModel.lastRefreshDate {
                    Text("Last updated: \(relativeTimeFormatter.localizedString(for: lastRefresh, relativeTo: Date()))")
                        .font(.caption2)
                }
            }
            Spacer()
            Button(action: { Task { await viewModel.loadJobs() } }) {
                HStack(spacing: 4) {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Refresh")
                }
            }
            .buttonStyle(.borderless)
            .help("Refresh jobs")
            .disabled(viewModel.isLoading)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private let relativeTimeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
    
    private func formatRelativeTime(_ date: Date) -> String {
        return relativeTimeFormatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    JobsListView()
        .environmentObject(JobsListViewModel())
}
