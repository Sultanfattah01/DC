import SwiftUI

enum EventCategory: String, CaseIterable, Codable, Identifiable {
    case conference
    case meetup
    case workshop
    case social
    case hiring

    var id: String { rawValue }

    var title: String {
        switch self {
        case .conference: "Conference"
        case .meetup: "Meetup"
        case .workshop: "Workshop"
        case .social: "Social"
        case .hiring: "Hiring"
        }
    }

    var icon: String {
        switch self {
        case .conference: "mic.fill"
        case .meetup: "person.3.fill"
        case .workshop: "hammer.fill"
        case .social: "sparkles"
        case .hiring: "briefcase.fill"
        }
    }

    var color: Color {
        switch self {
        case .conference: .indigo
        case .meetup: .blue
        case .workshop: .orange
        case .social: .pink
        case .hiring: .green
        }
    }
}

enum EventFormat: String, CaseIterable, Codable, Identifiable {
    case inPerson
    case virtual
    case hybrid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inPerson: "In person"
        case .virtual: "Virtual"
        case .hybrid: "Hybrid"
        }
    }

    var icon: String {
        switch self {
        case .inPerson: "figure.stand"
        case .virtual: "video.fill"
        case .hybrid: "antenna.radiowaves.left.and.right"
        }
    }
}

struct AgendaItem: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var time: String
    var title: String
    var speaker: String

    init(time: String, title: String, speaker: String = "") {
        self.time = time
        self.title = title
        self.speaker = speaker
    }
}

struct Event: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var title: String
    var summary: String
    var category: EventCategory
    var format: EventFormat
    var organizerName: String
    var organizerConnectionID: UUID?
    var venue: String
    var city: String
    var startDate: Date
    var endDate: Date?
    var priceText: String
    var capacity: Int
    var attendeeCount: Int
    var isAttending: Bool
    var isSaved: Bool
    var isHostedByMe: Bool
    var topics: [String]
    var agenda: [AgendaItem]
    var attendingConnectionIDs: [UUID]
    var theme: CardTheme

    init(
        title: String,
        summary: String = "",
        category: EventCategory = .meetup,
        format: EventFormat = .inPerson,
        organizerName: String = "",
        organizerConnectionID: UUID? = nil,
        venue: String = "",
        city: String = "",
        startDate: Date = .now,
        endDate: Date? = nil,
        priceText: String = "Free",
        capacity: Int = 100,
        attendeeCount: Int = 0,
        isAttending: Bool = false,
        isSaved: Bool = false,
        isHostedByMe: Bool = false,
        topics: [String] = [],
        agenda: [AgendaItem] = [],
        attendingConnectionIDs: [UUID] = [],
        theme: CardTheme = .ocean
    ) {
        self.title = title
        self.summary = summary
        self.category = category
        self.format = format
        self.organizerName = organizerName
        self.organizerConnectionID = organizerConnectionID
        self.venue = venue
        self.city = city
        self.startDate = startDate
        self.endDate = endDate
        self.priceText = priceText
        self.capacity = capacity
        self.attendeeCount = attendeeCount
        self.isAttending = isAttending
        self.isSaved = isSaved
        self.isHostedByMe = isHostedByMe
        self.topics = topics
        self.agenda = agenda
        self.attendingConnectionIDs = attendingConnectionIDs
        self.theme = theme
    }

    var totalAttendees: Int {
        attendeeCount + (isAttending ? 1 : 0)
    }

    var spotsLeft: Int {
        max(capacity - totalAttendees, 0)
    }

    var isFull: Bool {
        spotsLeft == 0
    }

    var isFree: Bool {
        priceText.localizedCaseInsensitiveContains("free")
    }

    var isUpcoming: Bool {
        startDate >= Date()
    }

    var dayNumber: String {
        startDate.formatted(.dateTime.day())
    }

    var monthShort: String {
        startDate.formatted(.dateTime.month(.abbreviated)).uppercased()
    }

    var dateLine: String {
        startDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    var timeLine: String {
        let start = startDate.formatted(date: .omitted, time: .shortened)
        guard let endDate else { return start }
        return "\(start) – \(endDate.formatted(date: .omitted, time: .shortened))"
    }

    var locationLine: String {
        [venue, city].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    var countdownText: String {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now), to: Calendar.current.startOfDay(for: startDate)).day ?? 0

        return switch days {
        case ..<0: "Past event"
        case 0: "Today"
        case 1: "Tomorrow"
        default: "In \(days) days"
        }
    }

    static let samples: [Event] = {
        let priya = Connection.samples[0]
        let daniel = Connection.samples[1]
        let mei = Connection.samples[2]
        let chris = Connection.samples[3]

        return [
            Event(
                title: "SwiftUI Night: Navigation Deep Dive",
                summary: "A hands-on evening on SwiftUI navigation patterns. We'll walk through NavigationStack, deep linking, and state restoration, then open the floor for code review of real projects. Bring a laptop if you want your navigation stack picked apart.",
                category: .meetup,
                format: .inPerson,
                organizerName: "Seattle iOS Collective",
                organizerConnectionID: daniel.id,
                venue: "Vertex HQ, 4th Floor",
                city: "Seattle, WA",
                startDate: eventDate(daysFromNow: 3, hour: 18, minute: 30),
                endDate: eventDate(daysFromNow: 3, hour: 21),
                priceText: "Free",
                capacity: 80,
                attendeeCount: 62,
                isAttending: true,
                topics: ["SwiftUI", "iOS", "Architecture"],
                agenda: [
                    AgendaItem(time: "6:30 PM", title: "Doors open, food and intros"),
                    AgendaItem(time: "7:00 PM", title: "Navigation patterns that survive refactors", speaker: "Daniel Okafor"),
                    AgendaItem(time: "7:45 PM", title: "Live code review", speaker: "Open floor"),
                    AgendaItem(time: "8:30 PM", title: "Open networking")
                ],
                attendingConnectionIDs: [daniel.id, chris.id],
                theme: .forest
            ),
            Event(
                title: "Design Week Kickoff Party",
                summary: "The opening night for SF Design Week. Low-key, loud, and the best room in the city for meeting people who actually ship. Drinks are on the sponsors.",
                category: .social,
                format: .inPerson,
                organizerName: "SF Design Week",
                venue: "The Pearl",
                city: "San Francisco, CA",
                startDate: eventDate(daysFromNow: 9, hour: 19),
                endDate: eventDate(daysFromNow: 9, hour: 23),
                priceText: "$25",
                capacity: 300,
                attendeeCount: 214,
                isSaved: true,
                topics: ["Design", "Networking"],
                agenda: [
                    AgendaItem(time: "7:00 PM", title: "Doors and welcome drinks"),
                    AgendaItem(time: "8:15 PM", title: "Opening remarks", speaker: "Festival organizers"),
                    AgendaItem(time: "9:00 PM", title: "Open floor")
                ],
                attendingConnectionIDs: [priya.id, mei.id],
                theme: .sunset
            ),
            Event(
                title: "Pricing Your Design Work",
                summary: "A working session on pricing: retainers versus project fees, when to raise rates, and how to write a scope document that protects both sides. Small group, lots of questions, no slides after the first ten minutes.",
                category: .workshop,
                format: .virtual,
                organizerName: "Studio Kaze",
                organizerConnectionID: mei.id,
                venue: "Zoom",
                city: "Online",
                startDate: eventDate(daysFromNow: 14, hour: 12),
                endDate: eventDate(daysFromNow: 14, hour: 14),
                priceText: "$60",
                capacity: 30,
                attendeeCount: 27,
                isAttending: true,
                topics: ["Freelance", "Pricing", "Business"],
                agenda: [
                    AgendaItem(time: "12:00 PM", title: "Where pricing goes wrong", speaker: "Mei Tanaka"),
                    AgendaItem(time: "12:30 PM", title: "Rewriting your rate sheet together"),
                    AgendaItem(time: "1:30 PM", title: "Q&A")
                ],
                attendingConnectionIDs: [mei.id],
                theme: .midnight
            ),
            Event(
                title: "Product Builders Summit 2026",
                summary: "Two days of talks from teams who launched something real this year. Tracks on product, design, and growth, plus a hiring floor with 40 companies.",
                category: .conference,
                format: .hybrid,
                organizerName: "Halcyon Events",
                organizerConnectionID: chris.id,
                venue: "Moscone West",
                city: "San Francisco, CA",
                startDate: eventDate(daysFromNow: 34, hour: 9),
                endDate: eventDate(daysFromNow: 35, hour: 17),
                priceText: "$349",
                capacity: 1200,
                attendeeCount: 890,
                topics: ["Product", "Growth", "Design", "Hiring"],
                agenda: [
                    AgendaItem(time: "Day 1 · 9:00 AM", title: "Opening keynote"),
                    AgendaItem(time: "Day 1 · 11:00 AM", title: "Product track begins"),
                    AgendaItem(time: "Day 2 · 10:00 AM", title: "Hiring floor opens"),
                    AgendaItem(time: "Day 2 · 4:00 PM", title: "Closing panel")
                ],
                attendingConnectionIDs: [chris.id, priya.id],
                theme: .ocean
            ),
            Event(
                title: "Founders & Designers Coffee",
                summary: "An informal Saturday morning coffee for founders looking for design help and designers looking for interesting problems. No pitches, just conversation.",
                category: .social,
                format: .inPerson,
                organizerName: "Loop Labs",
                organizerConnectionID: priya.id,
                venue: "Ritual Coffee, Valencia St",
                city: "San Francisco, CA",
                startDate: eventDate(daysFromNow: 6, hour: 10),
                endDate: eventDate(daysFromNow: 6, hour: 12),
                priceText: "Free",
                capacity: 24,
                attendeeCount: 24,
                topics: ["Founders", "Design", "Coffee"],
                attendingConnectionIDs: [priya.id],
                theme: .minimal
            ),
            Event(
                title: "iOS Hiring Mixer",
                summary: "Eight companies hiring iOS engineers, one room, two hours. Bring your card. Recruiters are asked to stay in the back until the second hour.",
                category: .hiring,
                format: .inPerson,
                organizerName: "Vertex",
                organizerConnectionID: daniel.id,
                venue: "The Assembly",
                city: "Seattle, WA",
                startDate: eventDate(daysFromNow: 20, hour: 17, minute: 30),
                endDate: eventDate(daysFromNow: 20, hour: 20),
                priceText: "Free",
                capacity: 150,
                attendeeCount: 71,
                topics: ["Hiring", "iOS", "Careers"],
                attendingConnectionIDs: [daniel.id],
                theme: .forest
            ),
            Event(
                title: "Design Systems Roundtable",
                summary: "A closed-door conversation between people maintaining design systems at small companies. Held last month; notes were shared with everyone who attended.",
                category: .workshop,
                format: .virtual,
                organizerName: "Northstar Studio",
                venue: "Zoom",
                city: "Online",
                startDate: eventDate(daysFromNow: -12, hour: 11),
                endDate: eventDate(daysFromNow: -12, hour: 12, minute: 30),
                priceText: "Free",
                capacity: 40,
                attendeeCount: 38,
                isAttending: true,
                topics: ["Design Systems"],
                theme: .ocean
            )
        ]
    }()
}

private func eventDate(daysFromNow: Int, hour: Int, minute: Int = 0) -> Date {
    let calendar = Calendar.current
    let base = calendar.date(byAdding: .day, value: daysFromNow, to: .now) ?? .now
    return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
}
