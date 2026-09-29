import Foundation

struct Message: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var text: String
    var isFromMe: Bool
    var date: Date
    var isRead: Bool

    init(text: String, isFromMe: Bool, date: Date = .now, isRead: Bool = true) {
        self.text = text
        self.isFromMe = isFromMe
        self.date = date
        self.isRead = isRead
    }
}

struct Conversation: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var connectionID: UUID
    var messages: [Message]

    init(connectionID: UUID, messages: [Message] = []) {
        self.connectionID = connectionID
        self.messages = messages
    }

    var orderedMessages: [Message] {
        messages.sorted { $0.date < $1.date }
    }

    var lastMessage: Message? {
        orderedMessages.last
    }

    var lastActivity: Date {
        lastMessage?.date ?? .distantPast
    }

    var unreadCount: Int {
        messages.filter { !$0.isFromMe && !$0.isRead }.count
    }

    var preview: String {
        guard let last = lastMessage else { return "No messages yet" }
        return last.isFromMe ? "You: \(last.text)" : last.text
    }

    static let samples: [Conversation] = {
        let priya = Connection.samples[0]
        let daniel = Connection.samples[1]
        let mei = Connection.samples[2]

        return [
            Conversation(
                connectionID: priya.id,
                messages: [
                    Message(
                        text: "Great meeting you at Design Week! Sending over the onboarding flow we talked about.",
                        isFromMe: false,
                        date: Date().addingTimeInterval(-60 * 60 * 26)
                    ),
                    Message(
                        text: "Likewise. Send it whenever, I'll take a look this week.",
                        isFromMe: true,
                        date: Date().addingTimeInterval(-60 * 60 * 25)
                    ),
                    Message(
                        text: "Just emailed it. The step where people drop off is screen 3 — curious if you see it too.",
                        isFromMe: false,
                        date: Date().addingTimeInterval(-60 * 60 * 3),
                        isRead: false
                    ),
                    Message(
                        text: "Also, are you coming to the coffee thing on Saturday?",
                        isFromMe: false,
                        date: Date().addingTimeInterval(-60 * 60 * 2),
                        isRead: false
                    )
                ]
            ),
            Conversation(
                connectionID: daniel.id,
                messages: [
                    Message(
                        text: "You still up for bringing a project to the meetup Thursday?",
                        isFromMe: false,
                        date: Date().addingTimeInterval(-60 * 60 * 30)
                    ),
                    Message(
                        text: "Yes — my navigation code is a mess, perfect timing.",
                        isFromMe: true,
                        date: Date().addingTimeInterval(-60 * 60 * 29)
                    ),
                    Message(
                        text: "Perfect. I'll put you first so we have time to actually dig in.",
                        isFromMe: false,
                        date: Date().addingTimeInterval(-60 * 60 * 28)
                    )
                ]
            ),
            Conversation(
                connectionID: mei.id,
                messages: [
                    Message(
                        text: "Thank you again for the pricing advice. I raised my rate 20% and nobody blinked.",
                        isFromMe: true,
                        date: Date().addingTimeInterval(-60 * 60 * 24 * 4)
                    ),
                    Message(
                        text: "They never do. Come to the workshop in two weeks, you'll hear the rest of it.",
                        isFromMe: false,
                        date: Date().addingTimeInterval(-60 * 60 * 24 * 4 + 3600)
                    )
                ]
            )
        ]
    }()
}
