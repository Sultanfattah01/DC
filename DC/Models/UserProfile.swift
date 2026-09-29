import SwiftUI

struct BusinessLink: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var url: String
    var icon: String

    static let availableIcons = [
        "link", "globe", "briefcase.fill", "camera.fill",
        "play.rectangle.fill", "music.note", "bubble.left.fill", "doc.text.fill"
    ]
}

enum CardTheme: String, CaseIterable, Codable, Identifiable {
    case ocean
    case sunset
    case forest
    case midnight
    case minimal

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var hexColors: [String] {
        switch self {
        case .ocean: ["2563EB", "7C3AED"]
        case .sunset: ["F97316", "DB2777"]
        case .forest: ["059669", "0F766E"]
        case .midnight: ["111827", "334155"]
        case .minimal: ["52525B", "18181B"]
        }
    }

    var colors: [Color] {
        hexColors.map(Color.init(hex:))
    }

    var accent: Color {
        colors.first ?? .blue
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct UserProfile: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var username: String
    var role: String
    var company: String
    var bio: String
    var about: String
    var email: String
    var phone: String
    var location: String
    var website: String
    var experience: [Experience]
    var education: [Education]
    var skills: [String]
    var links: [BusinessLink]
    var theme: CardTheme
    var showContactDetails: Bool
    var photoData: Data?
    var bannerData: Data?

    var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }

    var jobLine: String {
        [role, company].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    static let sample = UserProfile(
        name: "Alex Morgan",
        username: "alexm",
        role: "Product Designer",
        company: "Northstar Studio",
        bio: "I design thoughtful digital products and help ambitious teams turn ideas into experiences people love.",
        about: """
        I'm a product designer who cares most about the messy middle: the part after the idea is approved and before anyone knows if it works.

        Most of my work is with small teams shipping their first real version of something. I like being in the room for the hard scoping conversations, and I write as much as I design.
        """,
        email: "alex@example.com",
        phone: "+1 (415) 555-0142",
        location: "San Francisco, CA",
        website: "alexmorgan.dev",
        experience: [
            Experience(
                title: "Product Designer",
                company: "Northstar Studio",
                location: "San Francisco, CA",
                startYear: "2023",
                summary: "Lead design on two client products a year, from discovery through launch."
            ),
            Experience(
                title: "Product Designer",
                company: "Fieldwork",
                location: "Remote",
                startYear: "2020",
                endYear: "2023",
                summary: "Owned the mobile app end to end and grew the design system to 40+ components."
            ),
            Experience(
                title: "UI Designer",
                company: "Bright Lane",
                location: "Austin, TX",
                startYear: "2018",
                endYear: "2020",
                summary: "First design hire. Built the marketing site and early product screens."
            )
        ],
        education: [
            Education(school: "University of Texas at Austin", degree: "BFA, Design", years: "2014 – 2018")
        ],
        skills: ["Product Design", "Design Systems", "SwiftUI", "User Research", "Prototyping", "Workshops"],
        links: [
            BusinessLink(title: "My Portfolio", url: "https://alexmorgan.dev", icon: "briefcase.fill"),
            BusinessLink(title: "LinkedIn", url: "https://linkedin.com", icon: "link"),
            BusinessLink(title: "Instagram", url: "https://instagram.com", icon: "camera.fill")
        ],
        theme: .ocean,
        showContactDetails: true
    )
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
