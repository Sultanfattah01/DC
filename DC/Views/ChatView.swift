import SwiftUI

struct ChatView: View {
    let connection: Connection

    @EnvironmentObject private var store: AppStore
    @State private var draft = ""
    @FocusState private var isInputFocused: Bool

    private var messages: [Message] {
        store.conversation(with: connection.id)?.orderedMessages ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        contextHeader

                        ForEach(groupedMessages, id: \.day) { group in
                            Text(dayLabel(for: group.day))
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(Capsule())
                                .padding(.top, 6)

                            ForEach(group.messages) { message in
                                bubble(message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .onAppear {
                    store.markRead(connection.id)
                    scrollToLast(proxy, animated: false)
                }
                .onChange(of: messages.count) {
                    scrollToLast(proxy, animated: true)
                }
            }

            inputBar
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(connection.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ConnectionDetailView(connection: connection)
                } label: {
                    AvatarView(initials: connection.initials, theme: connection.theme, size: 30)
                }
            }
        }
    }

    // MARK: - Header

    private var contextHeader: some View {
        VStack(spacing: 8) {
            AvatarView(initials: connection.initials, theme: connection.theme, size: 64)

            Text(connection.name)
                .font(.headline)

            if !connection.jobLine.isEmpty {
                Text(connection.jobLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !connection.metAt.isEmpty {
                Label("Met at \(connection.metAt)", systemImage: "mappin.and.ellipse")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Messages

    private var groupedMessages: [(day: Date, messages: [Message])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: messages) { calendar.startOfDay(for: $0.date) }

        return groups.keys.sorted().map { day in
            (day: day, messages: groups[day]?.sorted { $0.date < $1.date } ?? [])
        }
    }

    private func dayLabel(for day: Date) -> String {
        if Calendar.current.isDateInToday(day) { return "Today" }
        if Calendar.current.isDateInYesterday(day) { return "Yesterday" }
        return day.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    private func bubble(_ message: Message) -> some View {
        HStack {
            if message.isFromMe { Spacer(minLength: 50) }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(message.isFromMe ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isFromMe
                            ? AnyShapeStyle(store.profile.theme.gradient)
                            : AnyShapeStyle(Color(.secondarySystemGroupedBackground))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Text(message.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if !message.isFromMe { Spacer(minLength: 50) }
        }
    }

    private func scrollToLast(_ proxy: ScrollViewProxy, animated: Bool) {
        guard let last = messages.last else { return }

        if animated {
            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
        } else {
            proxy.scrollTo(last.id, anchor: .bottom)
        }
    }

    // MARK: - Input

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Message \(connection.name.split(separator: " ").first.map(String.init) ?? connection.name)", text: $draft, axis: .vertical)
                .lineLimit(1...5)
                .focused($isInputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Button {
                store.send(draft, to: connection.id)
                draft = ""
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }
}

#Preview {
    NavigationStack {
        ChatView(connection: Connection.samples[0])
            .environmentObject(AppStore())
    }
}
