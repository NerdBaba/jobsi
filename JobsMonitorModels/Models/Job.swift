import Foundation

/// The domain model for a single job posting.
///
/// `public` so the model can be shared across the package's SPM targets
/// (Models / Scrapers / UI / tests) — each target is its own module, and
/// `internal` types are invisible to a regular `import`.
public struct Job: Identifiable, Codable, Hashable {
    public let id: UUID
    public let title: String
    public let company: String
    public let description: String
    public let category: String
    public let location: String
    public let postedDate: String
    public let applyLink: String
    public var salary: String?

    public init(
        id: UUID = UUID(),
        title: String,
        company: String,
        description: String,
        category: String,
        location: String,
        postedDate: String,
        applyLink: String,
        salary: String? = nil
    ) {
        self.id = id
        self.title = title
        self.company = company
        self.description = description
        self.category = category
        self.location = location
        self.postedDate = postedDate
        self.applyLink = applyLink
        self.salary = salary
    }

    /// Limited preview of the description for the compact menu-bar card.
    public var descriptionPreview: String {
        let maxLength = 120
        if description.count <= maxLength {
            return description
        }
        return String(description.prefix(maxLength)) + "..."
    }
}

extension Job {
    public static var previewJob: Job {
        Job(
            id: UUID(),
            title: "Senior Software Engineer",
            company: "TechCorp Inc.",
            description: "We are looking for a Senior Software Engineer to join our team. You will be responsible for designing and implementing scalable solutions...",
            category: "Software Engineering",
            location: "San Francisco, CA",
            postedDate: "2 days ago",
            applyLink: "https://example.com/apply",
            salary: "$150k - $200k"
        )
    }
}
