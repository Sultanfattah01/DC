import SwiftUI

enum PostAuthor: Codable, Equatable, Hashable {
    case me
    case connection(UUID)
    case organizer(UUID)
}

enum PostKind: String, Codable, CaseIterable, Identifiable {
    case update
    case milestone
    case hiring
    case question

    var id: String { rawValue }

    var title: String {
        switch self {
        case .update: "Update"
        case .milestone: "Milestone"
        case .hiring: "Hiring"
        case .question: "Question"
        }
    }

    var icon: String {
        switch self {
        case .update: "text.bubble.fill"
        case .milestone: "party.popper.fill"
        case .hiring: "briefcase.fill"
        case .question: "questionmark.bubble.fill"
        }
    }

    var color: Color {
        switch self {
        case .update: .blue
        case .milestone: .pink
        case .hiring: .green
        case .question: .orange
        }
    }
}

struct Comment: Identifiable, Codable, Equatable {
    var id = UUID()
    var author: PostAuthor
    var text: String
    var date: Date

    init(author: PostAuthor, text: String, date: Date = .now) {
        self.author = author
        self.text = text
        self.date = date
    }
}

struct Post: Identifiable, Codable, Equatable {
    var id = UUID()
    var author: PostAuthor
    var text: String
    var kind: PostKind
    var date: Date
    var likeCount: Int
    var isLiked: Bool
    var comments: [Comment]
    var eventID: UUID?

    init(
        author: PostAuthor,
        text: String,
        kind: PostKind = .update,
        date: Date = .now,
        likeCount: Int = 0,
        isLiked: Bool = false,
        comments: [Comment] = [],
        eventID: UUID? = nil
    ) {
        self.author = author
        self.text = text
        self.kind = kind
        self.date = date
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.comments = comments
        self.eventID = eventID
    }
}

enum SampleData {
    static let connections = Connection.samples
    static let events = Event.samples

    static var posts: [Post] {
        networkPosts + eventPosts
    }

    static var eventPosts: [Post] {
        let swiftNight = events[0]
        let kickoff = events[1]
        let pricing = events[2]

        return [
            Post(
                author: .organizer(swiftNight.id),
                text: "Doors open at 6:30 and we're at 62 of 80 seats. If you RSVP'd and can't make it, please release your spot so someone on the waitlist can take it.",
                kind: .update,
                date: Date().addingTimeInterval(-60 * 60 * 8),
                likeCount: 9,
                eventID: swiftNight.id
            ),
            Post(
                author: .organizer(swiftNight.id),
                text: "Bring a project if you want it reviewed live. We'll pick three navigation stacks from the room and go through them together.",
                kind: .question,
                date: Date().addingTimeInterval(-60 * 60 * 40),
                likeCount: 14,
                comments: [
                    Comment(
                        author: .me,
                        text: "I'll bring mine. Deep links are where it falls apart for me.",
                        date: Date().addingTimeInterval(-60 * 60 * 38)
                    )
                ],
                eventID: swiftNight.id
            ),
            Post(
                author: .organizer(kickoff.id),
                text: "Tickets are past 200. Badge pickup is at the side entrance on Folsom, not the main door — saves you about twenty minutes.",
                kind: .update,
                date: Date().addingTimeInterval(-60 * 60 * 15),
                likeCount: 31,
                eventID: kickoff.id
            ),
            Post(
                author: .organizer(pricing.id),
                text: "Homework before we meet: write down your current day rate and the last three projects you discounted. We'll work from your real numbers.",
                kind: .update,
                date: Date().addingTimeInterval(-60 * 60 * 60),
                likeCount: 18,
                eventID: pricing.id
            )
        ]
    }

    static var networkPosts: [Post] {
        let priya = connections[0]
        let daniel = connections[1]
        let mei = connections[2]

        return [
            Post(
                author: .connection(priya.id),
                text: "We just shipped the new Loop Labs onboarding. Cut setup time from 11 minutes to under 3. Thanks to everyone who tested it with us.",
                kind: .milestone,
                date: Date().addingTimeInterval(-60 * 60 * 5),
                likeCount: 24,
                comments: [
                    Comment(
                        author: .connection(daniel.id),
                        text: "Huge. The old flow was rough — congrats to the team.",
                        date: Date().addingTimeInterval(-60 * 60 * 4)
                    )
                ]
            ),
            Post(
                author: .connection(daniel.id),
                text: "We're hiring two iOS engineers at Vertex. Remote-friendly, heavy SwiftUI work. Happy to refer anyone I've met in person.",
                kind: .hiring,
                date: Date().addingTimeInterval(-60 * 60 * 26),
                likeCount: 41
            ),
            Post(
                author: .me,
                text: "Spent the weekend rebuilding my portfolio around case studies instead of screenshots. Turns out people want the reasoning, not the pixels.",
                kind: .update,
                date: Date().addingTimeInterval(-60 * 60 * 30),
                likeCount: 12,
                isLiked: true
            ),
            Post(
                author: .connection(mei.id),
                text: "Question for the designers here: how are you handling pricing for open-ended retainer work? Curious what's actually sustainable.",
                kind: .question,
                date: Date().addingTimeInterval(-60 * 60 * 52),
                likeCount: 8,
                comments: [
                    Comment(
                        author: .me,
                        text: "I moved to a monthly cap with a clear scope doc. Fewer surprises for both sides.",
                        date: Date().addingTimeInterval(-60 * 60 * 50)
                    )
                ]
            )
        ]
    }
}
