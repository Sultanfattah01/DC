import Foundation

struct Experience: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var title: String
    var company: String
    var location: String
    var startYear: String
    var endYear: String
    var summary: String

    init(
        title: String,
        company: String,
        location: String = "",
        startYear: String = "",
        endYear: String = "",
        summary: String = ""
    ) {
        self.title = title
        self.company = company
        self.location = location
        self.startYear = startYear
        self.endYear = endYear
        self.summary = summary
    }

    var isCurrent: Bool {
        endYear.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var dateRange: String {
        let start = startYear.trimmingCharacters(in: .whitespaces)
        let end = isCurrent ? "Present" : endYear.trimmingCharacters(in: .whitespaces)

        if start.isEmpty { return end }
        return "\(start) – \(end)"
    }
}

struct Education: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var school: String
    var degree: String
    var years: String

    init(school: String, degree: String = "", years: String = "") {
        self.school = school
        self.degree = degree
        self.years = years
    }
}
