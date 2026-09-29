import SwiftUI

private struct ChatRow: Identifiable {
    let conversation: Conversation
    let connection: Connection

    var id: UUID { conversation.id }
}

struct MessagesView: View {
    @EnvironmentObject private var store: AppStore

    @State private var path: [Connection] = []
    @State private var query = ""
    @State private var showPicker = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if filtered.isEmpty {
                    Section {
                        emptyState
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                } else {
                    ForEach(filtered) { item in
                        NavigationLink(value: item.connection) {
                            row(conversation: item.conversation, connection: item.connection)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.deleteConversation(with: item.connection.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Messages")
            .searchable(text: $query, prompt: "Search people or messages")
            .navigationDestination(for: Connection.self) { connection in
                ChatView(connection: connection)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPicker = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showPicker) {
                NewMessageView { connection in
                    path.append(connection)
                }
            }
        }
    }

    private var filtered: [ChatRow] {
        let rows = store.sortedConversations.compactMap { conversation -> ChatRow? in
            guard let connection = store.connection(for: conversation) else { return nil }
            return ChatRow(conversation: conversation, connection: connection)
        }

        guard !query.isEmpty else { return rows }

        return rows.filter { row in
            row.connection.name.localizedCaseInsensitiveContains(query)
                || row.connection.company.localizedCaseInsensitiveContains(query)
                || row.conversation.messages.contains { $0.text.localizedCaseInsensitiveContains(query) }
        }
    }

    private func row(conversation: Conversation, connection: Connection) -> some View {
        HStack(alignment: .top, spacing: 14) {
            AvatarView(initials: connection.initials, theme: connection.theme, size: 48)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(connection.name)
                        .font(.subheadline.weight(conversation.unreadCount > 0 ? .bold : .semibold))

                    Spacer()

                    if let last = conversation.lastMessage {
                        Text(shortTime(for: last.date))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Text(conversation.preview)
                    .font(.footnote)
                    .foregroundStyle(conversation.unreadCount > 0 ? .primary : .secondary)
                    .lineLimit(2)

                if !connection.metAt.isEmpty {
                    Text("Met at \(connection.metAt)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(minWidth: 20, minHeight: 20)
                    .background(store.profile.theme.accent)
                    .clipShape(Circle())
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 6)
    }

    private func shortTime(for date: Date) -> String {
        Calendar.current.isDateInToday(date)
            ? date.formatted(date: .omitted, time: .shortened)
            : date.formatted(.dateTime.month(.abbreviated).day())
    }

    private var emptyState: some View {
        ContentUnavailableView(
            store.connections.isEmpty ? "No connections yet" : "No conversations",
            systemImage: "bubble.left.and.bubble.right",
            description: Text(
                store.connections.isEmpty
                    ? "Add people to your network first, then you can message them here."
                    : "Tap the compose button to message someone you've met."
            )
        )
        .padding(.top, 60)
    }
}

struct NewMessageView: View {
    let onSelect: (Connection) -> Void

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { connection in
                    Button {
                        dismiss()
                        onSelect(connection)
                    } label: {
                        HStack(spacing: 14) {
                            AvatarView(initials: connection.initials, theme: connection.theme, size: 42)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(connection.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)

                                if !connection.jobLine.isEmpty {
                                    Text(connection.jobLine)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Search your network")
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "Nobody found",
                        systemImage: "person.crop.circle.badge.questionmark",
                        description: Text("You can only message people saved in your network.")
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var filtered: [Connection] {
        let people = store.connections.sorted { $0.name < $1.name }
        guard !query.isEmpty else { return people }

        return people.filter {
            $0.name.localizedCaseInsensitiveContains(query)
                || $0.company.localizedCaseInsensitiveContains(query)
        }
    }
}

#Preview {
    MessagesView()
        .environmentObject(AppStore())
}
