import Combine
import Foundation

struct AuthorInfo {
    var name: String
    var subtitle: String
    var initials: String
    var theme: CardTheme
    var metAt: String
    var photoData: Data?
    var connectionID: UUID?
}

@MainActor
final class AppStore: ObservableObject {
    @Published var profile: UserProfile {
        didSet { persist(profile, key: Keys.profile) }
    }

    @Published var connections: [Connection] {
        didSet { persist(connections, key: Keys.connections) }
    }

    @Published var posts: [Post] {
        didSet { persist(posts, key: Keys.posts) }
    }

    @Published var events: [Event] {
        didSet { persist(events, key: Keys.events) }
    }

    @Published var conversations: [Conversation] {
        didSet { persist(conversations, key: Keys.conversations) }
    }

    private enum Keys {
        static let profile = "dc.profile"
        static let connections = "dc.connections"
        static let posts = "dc.posts"
        static let events = "dc.events"
        static let conversations = "dc.conversations"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        profile = Self.load(UserProfile.self, key: Keys.profile, from: defaults) ?? .sample

        let savedConnections = Self.load([Connection].self, key: Keys.connections, from: defaults)
        let savedPosts = Self.load([Post].self, key: Keys.posts, from: defaults)
        let savedEvents = Self.load([Event].self, key: Keys.events, from: defaults)

        connections = savedConnections ?? SampleData.connections
        events = savedEvents ?? SampleData.events
        conversations = Self.load([Conversation].self, key: Keys.conversations, from: defaults)
            ?? (savedConnections == nil ? Conversation.samples : [])

        if let savedPosts {
            // Existing installs keep their posts, but still get the seeded event chatter.
            posts = savedEvents == nil ? savedPosts + SampleData.eventPosts : savedPosts
        } else {
            posts = SampleData.posts
        }
    }

    // MARK: - Network metrics

    var connectionCount: Int {
        connections.count
    }

    var favoriteCount: Int {
        connections.filter(\.isFavorite).count
    }

    var newThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        return connections.filter { $0.dateAdded >= weekAgo }.count
    }

    var companyCount: Int {
        Set(connections.map(\.company).filter { !$0.isEmpty }).count
    }

    var sortedConnections: [Connection] {
        connections.sorted { $0.dateAdded > $1.dateAdded }
    }

    var recentConnections: [Connection] {
        Array(sortedConnections.prefix(5))
    }

    var tagBreakdown: [(tag: ConnectionTag, count: Int)] {
        ConnectionTag.allCases
            .map { tag in (tag, connections.filter { $0.tag == tag }.count) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    // MARK: - Feed

    var feed: [Post] {
        posts.sorted { $0.date > $1.date }
    }

    var myPosts: [Post] {
        feed.filter { $0.author == .me }
    }

    func posts(by connectionID: UUID) -> [Post] {
        feed.filter { $0.author == .connection(connectionID) }
    }

    func posts(forEvent eventID: UUID) -> [Post] {
        feed.filter { $0.eventID == eventID }
    }

    // MARK: - Events

    func event(id: UUID?) -> Event? {
        guard let id else { return nil }
        return events.first { $0.id == id }
    }

    var upcomingEvents: [Event] {
        events.filter(\.isUpcoming).sorted { $0.startDate < $1.startDate }
    }

    var pastEvents: [Event] {
        events.filter { !$0.isUpcoming }.sorted { $0.startDate > $1.startDate }
    }

    var attendingEvents: [Event] {
        upcomingEvents.filter(\.isAttending)
    }

    var savedEvents: [Event] {
        upcomingEvents.filter(\.isSaved)
    }

    var nextEvent: Event? {
        attendingEvents.first
    }

    func connectionsAttending(_ event: Event) -> [Connection] {
        event.attendingConnectionIDs.compactMap { id in
            connections.first { $0.id == id }
        }
    }

    func toggleAttendance(_ event: Event) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        guard events[index].isAttending || !events[index].isFull else { return }
        events[index].isAttending.toggle()
    }

    func toggleSaved(_ event: Event) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index].isSaved.toggle()
    }

    func add(_ event: Event) {
        events.append(event)
    }

    func update(_ event: Event) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index] = event
    }

    func delete(_ event: Event) {
        events.removeAll { $0.id == event.id }
        posts.removeAll { $0.eventID == event.id }
    }

    func info(for author: PostAuthor) -> AuthorInfo {
        switch author {
        case .me:
            AuthorInfo(
                name: profile.name,
                subtitle: profile.jobLine,
                initials: profile.initials,
                theme: profile.theme,
                metAt: "",
                photoData: profile.photoData,
                connectionID: nil
            )

        case let .connection(id):
            if let connection = connections.first(where: { $0.id == id }) {
                AuthorInfo(
                    name: connection.name,
                    subtitle: connection.jobLine,
                    initials: connection.initials,
                    theme: connection.theme,
                    metAt: connection.metAt,
                    photoData: nil,
                    connectionID: connection.id
                )
            } else {
                AuthorInfo(
                    name: "Former connection",
                    subtitle: "",
                    initials: "?",
                    theme: .minimal,
                    metAt: "",
                    photoData: nil,
                    connectionID: nil
                )
            }

        case let .organizer(eventID):
            if let event = event(id: eventID) {
                AuthorInfo(
                    name: event.organizerName.isEmpty ? event.title : event.organizerName,
                    subtitle: "Organizer · \(event.title)",
                    initials: Self.initials(from: event.organizerName.isEmpty ? event.title : event.organizerName),
                    theme: event.theme,
                    metAt: "",
                    photoData: nil,
                    connectionID: event.organizerConnectionID
                )
            } else {
                AuthorInfo(
                    name: "Event organizer",
                    subtitle: "",
                    initials: "?",
                    theme: .minimal,
                    metAt: "",
                    photoData: nil,
                    connectionID: nil
                )
            }
        }
    }

    private static func initials(from name: String) -> String {
        let letters = name.split(separator: " ").prefix(2).compactMap { $0.first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }

    func addPost(text: String, kind: PostKind, eventID: UUID? = nil) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        posts.insert(Post(author: .me, text: trimmed, kind: kind, eventID: eventID), at: 0)
    }

    func toggleLike(_ post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].isLiked.toggle()
        posts[index].likeCount += posts[index].isLiked ? 1 : -1
    }

    func addComment(to post: Post, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let index = posts.firstIndex(where: { $0.id == post.id }) else { return }

        posts[index].comments.append(Comment(author: .me, text: trimmed))
    }

    func delete(_ post: Post) {
        posts.removeAll { $0.id == post.id }
    }

    // MARK: - Messages

    var sortedConversations: [Conversation] {
        conversations
            .filter { conversation in connections.contains { $0.id == conversation.connectionID } }
            .sorted { $0.lastActivity > $1.lastActivity }
    }

    var totalUnread: Int {
        sortedConversations.reduce(0) { $0 + $1.unreadCount }
    }

    func conversation(with connectionID: UUID) -> Conversation? {
        conversations.first { $0.connectionID == connectionID }
    }

    func connection(for conversation: Conversation) -> Connection? {
        connections.first { $0.id == conversation.connectionID }
    }

    func send(_ text: String, to connectionID: UUID) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let message = Message(text: trimmed, isFromMe: true)

        if let index = conversations.firstIndex(where: { $0.connectionID == connectionID }) {
            conversations[index].messages.append(message)
        } else {
            conversations.append(Conversation(connectionID: connectionID, messages: [message]))
        }
    }

    func markRead(_ connectionID: UUID) {
        guard let index = conversations.firstIndex(where: { $0.connectionID == connectionID }),
              conversations[index].unreadCount > 0 else { return }

        for messageIndex in conversations[index].messages.indices where !conversations[index].messages[messageIndex].isFromMe {
            conversations[index].messages[messageIndex].isRead = true
        }
    }

    func deleteConversation(with connectionID: UUID) {
        conversations.removeAll { $0.connectionID == connectionID }
    }

    // MARK: - Sharing

    var shareText: String {
        var lines = [
            profile.name,
            profile.jobLine,
            profile.bio,
            profile.email,
            profile.phone,
            profile.website
        ].filter { !$0.isEmpty }

        lines.append(contentsOf: profile.links.map { "\($0.title): \($0.url)" })
        return lines.joined(separator: "\n")
    }

    // MARK: - Connection mutations

    func add(_ connection: Connection) {
        connections.insert(connection, at: 0)
    }

    func update(_ connection: Connection) {
        guard let index = connections.firstIndex(where: { $0.id == connection.id }) else { return }
        connections[index] = connection
    }

    func delete(_ connection: Connection) {
        connections.removeAll { $0.id == connection.id }
        posts.removeAll { $0.author == .connection(connection.id) }
        conversations.removeAll { $0.connectionID == connection.id }
    }

    func toggleFavorite(_ connection: Connection) {
        guard let index = connections.firstIndex(where: { $0.id == connection.id }) else { return }
        connections[index].isFavorite.toggle()
    }

    // MARK: - Persistence

    private func persist<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
