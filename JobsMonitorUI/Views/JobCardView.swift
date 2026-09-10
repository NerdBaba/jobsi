import SwiftUI
import AppKit
import JobsMonitorModels

struct JobCardView: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Job Title & Company
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(colorForCategory(job.category))
                    .frame(width: 4, height: 4)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(.headline)
                        .lineLimit(2)

                    Text(job.company)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Description Preview
            Text(job.descriptionPreview)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Metadata Row
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "location")
                    Text(job.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(job.postedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "currency-dollar")
                    if let salary = job.salary {
                        Text(salary)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Negotiable")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Action Button
            Button(action: openApplyLink) {
                HStack {
                    Text("Apply Now")
                    Image(systemName: "arrow.up.right")
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.accentColor)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Apply to \(job.title) at \(job.company)")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }

    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "software engineering": return .blue
        case "design": return .purple
        case "data science": return .green
        case "product management": return .orange
        default: return .gray
        }
    }

    private func openApplyLink() {
        guard let url = URL(string: job.applyLink) else {
            print("JobCardView: malformed apply link — \(job.applyLink)")
            return
        }
        NSWorkspace.shared.open(url)
    }
}

#Preview {
    JobCardView(job: Job.previewJob)
}
