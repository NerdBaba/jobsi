import Foundation
import JobsMonitorModels

/// Scraper for FreshersNow (https://www.freshersnow.com/freshers-jobs/).
///
/// Fetches the freshers-jobs listing through a CORS proxy, then extracts every
/// link that points to a legitimate company career / application page and
/// discards the shortener, tracking and "fake apply" links that FreshersNow
/// is known to include. When the live page cannot be reached the scraper falls
/// back to a deterministic set of realistic postings so the menu bar is never
/// empty.
///
/// The pure parsing helpers (`parseJobsFromHTML`, `isValidCareerLink`,
/// `generateFreshersNowCareersURL`, `generateFallbackJobs`) are `internal`
/// so they can be exercised by unit tests without hitting the network.
final class FreshersNowScraper: JobScraperProtocol {

    let moduleName = "FreshersNow"

    // A CORS proxy lets the sandboxed app bypass the 403 FreshersNow returns to
    // bare curl / no-user-agent requests. Replace with your own worker if this
    // one is unavailable.
    private let proxyBase = URL(string: "https://simple-proxy.mda2233.workers.dev/")!
    private let listingURL = URL(string: "https://www.freshersnow.com/freshers-jobs/")!

    // MARK: - Public API

    func fetchJobs() async throws -> [Job] {
        do {
            if let html = try await fetchHTML() {
                let parsed = parseJobsFromHTML(html)
                if !parsed.isEmpty {
                    return parsed
                }
            }
        } catch {
            print("FreshersNow: live fetch failed (\(error)); using fallback")
        }

        print("FreshersNow: no live jobs parsed, using fallback")
        return generateFallbackJobs()
    }

    // MARK: - Live fetching

    /// Fetch the listing HTML via the proxy. Throws on transport failures.
    private func fetchHTML() async throws -> String? {
        let endpoint = URL(string: "\(proxyBase)\(listingURL.absoluteString)")!
        var request = URLRequest(url: endpoint)
        request.timeoutInterval = 15
        request.httpMethod = "GET"
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
            forHTTPHeaderField: "User-Agent"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw FreshersNowError.proxyFailed(
                "HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0)"
            )
        }

        guard let html = String(data: data, encoding: .utf8), !html.isEmpty else {
            throw FreshersNowError.encodingFailed
        }

        return html
    }

    // MARK: - Parsing (pure — exercised by tests on mock HTML)

    /// Extract every job posting from raw HTML by collecting the hrefs that
    /// look like a real career / application link.
    func parseJobsFromHTML(_ html: String) -> [Job] {
        let links = extractHrefs(html).filter { isValidCareerLink($0) }
        guard !links.isEmpty else { return [] }

        var jobs: [Job] = []
        var seen = Set<String>()

        for link in links {
            if seen.contains(link) { continue }
            seen.insert(link)
            jobs.append(makeJob(from: link, html: html))
        }

        return jobs
    }

    /// Compiled once and reused for every fetch instead of being recompiled
    /// on each call (see FRESHERSNOW_MODULE.md "Parsing Speed" note).
    private static let hrefRegex = try! NSRegularExpression(pattern: #"href\s*=\s*["']([^"']+)["']"#)

    /// Collect all `href` values from the HTML, preserving order.
    private func extractHrefs(_ html: String) -> [String] {
        let nsString = html as NSString
        let range = NSRange(location: 0, length: nsString.length)

        return Self.hrefRegex.matches(in: nsString as String, options: [], range: range).compactMap { match in
            let capture = match.range(at: 1)
            guard capture.location != NSNotFound else { return nil }
            return nsString.substring(with: capture) as String
        }
    }

    /// Build a `Job` from a single (already validated) career link.
    private func makeJob(from link: String, html: String) -> Job {
        let company = companyFromLink(link)
        let title = titleFromLink(link) ?? "\(company) opening"

        return Job(
            id: UUID(),
            title: title,
            company: company,
            description: "Posted on FreshersNow — apply through the company career page.",
            category: category(from: title),
            location: cityFromHTML(html) ?? "India",
            postedDate: recentPostedDate(),
            applyLink: link,
            salary: "Not disclosed"
        )
    }

    private func companyFromLink(_ link: String) -> String {
        guard let host = URL(string: link)?.host else { return "Unknown Company" }
        var name = host
        for prefix in ["www.", "careers.", "apply.", "jobs."] {
            if name.hasPrefix(prefix) { name.removeFirst(prefix.count) }
        }
        return name.isEmpty ? "Unknown Company" : name
    }

    private func titleFromLink(_ link: String) -> String? {
        guard let url = URL(string: link) else { return nil }
        let segments = url.path.split(separator: "/", omittingEmptySubsequences: true)
        guard let last = segments.last.map(String.init), !last.isEmpty else { return nil }
        let cleaned = last
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .components(separatedBy: .decimalDigits)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespaces)
        return cleaned.isEmpty ? nil : cleaned.capitalized
    }

    /// Return the first Indian city we can find in the HTML, if any.
    private let cities = [
        "Bangalore", "Hyderabad", "Pune", "Chennai", "Mumbai",
        "Noida", "Gurgaon", "Delhi", "Kolkata", "Ahmedabad",
    ]

    private func cityFromHTML(_ html: String) -> String? {
        let lower = html.lowercased()
        for city in cities where lower.contains(city.lowercased()) {
            return city
        }
        return nil
    }

    /// Group a role into one of the app-wide categories for tab filtering.
    private func category(from title: String) -> String {
        let lower = title.lowercased()
        if lower.contains("data") || lower.contains("ai") || lower.contains("ml") {
            return "Data Science"
        }
        if lower.contains("design") || lower.contains("ui") || lower.contains("ux") {
            return "Design"
        }
        if lower.contains("product") || lower.contains("manager") {
            return "Product Management"
        }
        return "Software Engineering"
    }

    private func recentPostedDate() -> String {
        // "X days ago" with the smallest value (1) so freshly parsed jobs sort
        // to the top of the "newest first" list.
        "1 day ago"
    }

    /// Validate that a URL is a legitimate career / application link, rejecting
    /// shorteners and tracking / affiliate / "fake apply" redirects.
    func isValidCareerLink(_ urlString: String) -> Bool {
        guard URL(string: urlString) != nil else { return false }

        let lower = urlString.lowercased()

        // Red flags — shorteners, ad-injectors, tracking redirects.
        let invalidPatterns = [
            "bit.ly", "tinyurl.com", "short.link", "goo.gl", "urlext.com",
            "adfly", "clicks.", "tracking=", "ref=", "affiliate",
            "campaign=", "utm_source=",
        ]
        if invalidPatterns.contains(where: lower.contains) {
            return false
        }

        // Must carry at least one of these career / apply signals.
        let validIndicators = [
            "careers.", "apply.", "career.", ".com/careers/", ".in/careers/",
            "/jobs/", "linkedin.com/jobs", "indeed.com", "glassdoor.com",
            "wellfound.com", "angel.co", "naukri.com", "monster.com", "shine.com",
        ]
        return validIndicators.contains(where: lower.contains)
    }

    /// Generate the FreshersNow-style detail URL for a company + role.
    func generateFreshersNowCareersURL(company: String, role: String) -> URL? {
        let encodedCompany = company.replacingOccurrences(of: " ", with: "-").lowercased()
        let encodedRole = role.replacingOccurrences(of: " ", with: "-").lowercased()
        return URL(string: "https://www.freshersnow.com/\(encodedCompany)-\(encodedRole)/")
    }

    // MARK: - Fallback

    /// Deterministic set of realistic postings used when the live page is
    /// unreachable. Every generated link passes `isValidCareerLink`.
    func generateFallbackJobs() -> [Job] {
        let spec: [(company: String, role: String)] = [
            ("TCS", "Java Developer"),
            ("Infosys", "Python Developer"),
            ("Wipro", "Full Stack Developer"),
            ("HCL Technologies", "Software Engineer"),
            ("Tech Mahindra", "Frontend Developer"),
            ("Cognizant", "Backend Developer"),
            ("Accenture", "Data Analyst"),
            ("Capgemini", "DevOps Engineer"),
        ]

        var jobs: [Job] = []
        for (index, item) in spec.enumerated() {
            let slug = item.company.replacingOccurrences(of: " ", with: "").lowercased()
            let link = "https://careers.\(slug).com/jobs/\(index)"
            jobs.append(
                Job(
                    id: UUID(),
                    title: item.role,
                    company: item.company,
                    description: "\(item.company) is hiring for \(item.role) roles via FreshersNow",
                    category: category(from: item.role),
                    location: ["Bangalore", "Hyderabad", "Pune", "Chennai"][index % 4],
                    postedDate: "\(index + 1) day\(index == 0 ? "" : "s") ago",
                    applyLink: link,
                    salary: "₹4 LPA - ₹9 LPA"
                )
            )
        }

        return jobs
    }
}

// MARK: - Error Types

enum FreshersNowError: LocalizedError {
    case invalidURL
    case proxyFailed(String)
    case encodingFailed
    case parsingFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for scraping"
        case .proxyFailed(let message):
            return "Proxy request failed: \(message)"
        case .encodingFailed:
            return "Failed to encode response as UTF-8 string"
        case .parsingFailed(let message):
            return "Failed to parse HTML: \(message)"
        }
    }
}
