import SwiftUI

enum ConnectionTag: String, CaseIterable, Codable, Identifiable {
    case lead
    case client
    case colleague
    case mentor
    case friend

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .lead: "sparkles"
        case .client: "briefcase.fill"
        case .colleague: "person.2.fill"
        case .mentor: "star.fill"
        case .friend: "hand.wave.fill"
        }
    }

    var color: Color {
        switch self {
        case .lead: .orange
        case .client: .blue
        case .colleague: .purple
        case .mentor: .pink
        case .friend: .green
        }
    }
}

struct Connection: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var role: String
    var company: String
    var about: String
    var email: String
    var phone: String
    var website: String
    var location: String
    var experience: [Experience]
    var skills: [String]
    var metAt: String
    var note: String
    var tag: ConnectionTag
    var dateAdded: Date
    var isFavorite: Bool
    var theme: CardTheme

    init(
        name: String,
        role: String = "",
        company: String = "",
        about: String = "",
        email: String = "",
        phone: String = "",
        website: String = "",
        location: String = "",
        experience: [Experience] = [],
        skills: [String] = [],
        metAt: String = "",
        note: String = "",
        tag: ConnectionTag = .lead,
        dateAdded: Date = .now,
        isFavorite: Bool = false,
        theme: CardTheme = .ocean
    ) {
        self.name = name
        self.role = role
        self.company = company
        self.about = about
        self.email = email
        self.phone = phone
        self.website = website
        self.location = location
        self.experience = experience
        self.skills = skills
        self.metAt = metAt
        self.note = note
        self.tag = tag
        self.dateAdded = dateAdded
        self.isFavorite = isFavorite
        self.theme = theme
    }

    var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }

    var jobLine: String {
        [role, company].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    static let samples: [Connection] = [
        Connection(
            name: "Priya Shah",
            role: "Founder",
            company: "Loop Labs",
            about: "Building tools for operations teams who still live in spreadsheets. Second-time founder, first time doing it without a co-founder.",
            email: "priya@looplabs.co",
            phone: "+1 (415) 555-0188",
            website: "looplabs.co",
            location: "San Francisco, CA",
            experience: [
                Experience(
                    title: "Founder",
                    company: "Loop Labs",
                    location: "San Francisco, CA",
                    startYear: "2022",
                    summary: "Bootstrapped to 400 paying teams."
                ),
                Experience(
                    title: "Head of Operations",
                    company: "Cadence",
                    startYear: "2018",
                    endYear: "2022"
                )
            ],
            skills: ["Operations", "Fundraising", "Product Strategy"],
            metAt: "SF Design Week",
            note: "Wants a redesign of their onboarding flow next quarter. Follow up after their Series A closes.",
            tag: .client,
            dateAdded: Date().addingTimeInterval(-60 * 60 * 20),
            isFavorite: true,
            theme: .sunset
        ),
        Connection(
            name: "Daniel Okafor",
            role: "Engineering Lead",
            company: "Vertex",
            about: "iOS engineer turned team lead. I care a lot about the boring parts: build times, crash rates, and code review culture.",
            email: "daniel@vertex.io",
            phone: "+1 (206) 555-0143",
            location: "Seattle, WA",
            experience: [
                Experience(
                    title: "Engineering Lead",
                    company: "Vertex",
                    location: "Seattle, WA",
                    startYear: "2021",
                    summary: "Leads a team of six on the consumer iOS app."
                ),
                Experience(title: "Senior iOS Engineer", company: "Trailhead", startYear: "2017", endYear: "2021")
            ],
            skills: ["Swift", "SwiftUI", "Team Leadership", "Performance"],
            metAt: "Swift Meetup",
            note: "Offered to intro me to their design team. Sharp opinions on SwiftUI navigation.",
            tag: .colleague,
            dateAdded: Date().addingTimeInterval(-60 * 60 * 74),
            theme: .forest
        ),
        Connection(
            name: "Mei Tanaka",
            role: "Creative Director",
            company: "Studio Kaze",
            about: "Twenty years in brand and editorial design. Now splitting time between client work and teaching.",
            email: "mei@studiokaze.jp",
            website: "studiokaze.jp",
            location: "Tokyo, Japan",
            experience: [
                Experience(
                    title: "Creative Director",
                    company: "Studio Kaze",
                    location: "Tokyo",
                    startYear: "2015"
                ),
                Experience(title: "Art Director", company: "Meridian", startYear: "2008", endYear: "2015")
            ],
            skills: ["Brand", "Editorial Design", "Art Direction", "Teaching"],
            metAt: "Coffee at Ritual",
            note: "Great advice on pricing retainers. Said to email her before I raise my rates.",
            tag: .mentor,
            dateAdded: Date().addingTimeInterval(-60 * 60 * 24 * 9),
            isFavorite: true,
            theme: .midnight
        ),
        Connection(
            name: "Chris Bennett",
            role: "Product Manager",
            company: "Halcyon",
            about: "PM on the growth team. Ex-consultant, recovering spreadsheet addict.",
            email: "chris@halcyon.app",
            location: "New York, NY",
            experience: [
                Experience(title: "Product Manager", company: "Halcyon", startYear: "2023"),
                Experience(title: "Consultant", company: "Bain", startYear: "2019", endYear: "2023")
            ],
            skills: ["Growth", "Analytics", "Roadmapping"],
            metAt: "Startup mixer",
            note: "Mentioned they're evaluating design partners in the fall.",
            tag: .lead,
            dateAdded: Date().addingTimeInterval(-60 * 60 * 24 * 21),
            theme: .minimal
        )
    ]
}
