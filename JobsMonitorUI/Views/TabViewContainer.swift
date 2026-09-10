import SwiftUI
import AppKit

struct TabViewContainer: View {
    @EnvironmentObject private var viewModel: JobsListViewModel
    @Binding var selectedTab: Int

    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                ForEach(viewModel.categories.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    }) {
                        Label(viewModel.categories[index], systemImage: iconForCategory(index))
                            .font(.subheadline.weight(selectedTab == index ? .semibold : .regular))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .foregroundColor(selectedTab == index ? .primary : .secondary)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedTab == index ? Color.accentColor.opacity(0.12) : Color.clear)
                    )

                    if index < viewModel.categories.count - 1 {
                        Divider()
                            .frame(height: 30)
                    }
                }
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .shadow(color: Color(NSColor.separatorColor).opacity(0.45), radius: 1, x: 0, y: 1)
    }

    private func iconForCategory(_ index: Int) -> String {
        let icons = ["briefcase", "code", "chart.line.uptrend.xyaxis", "laptopcomputer", "building"]
        return index < icons.count ? icons[index] : "briefcase"
    }
}
