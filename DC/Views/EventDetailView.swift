import SwiftUI

struct EventDetailView: View {
    let event: Event

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var showComposer = false
    @State private var showEditor = false
    @State private var showCancelAlert = false

    private var current: Event {
        store.event(id: event.id) ?? event
    }

    private var accent: Color { current.theme.accent }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                hero
                rsvpBar
                whenAndWhere

                if !current.summary.isEmpty {
                    SectionCard(title: "About this event") {
                        AboutText(text: current.summary)
                    }
                }

                if !current.agenda.isEmpty {
                    SectionCard(title: "Agenda") {
                        agendaList
                    }
                }

                if !current.topics.isEmpty {
                    SectionCard(title: "Topics") {
                        SkillChips(skills: current.topics, accent: accent)
                    }
                }

                peopleYouKnow
                organizerCard
                postsSection

                if current.isHostedByMe {
                    hostControls
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleSaved(current)
                } label: {
                    Image(systemName: current.isSaved ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .sheet(isPresented: $showComposer) {
            ComposePostView(eventID: current.id, eventTitle: current.title)
        }
        .sheet(isPresented: $showEditor) {
            EventEditorView(event: current)
        }
        .alert("Delete this event?", isPresented: $showCancelAlert) {
            Button("Delete", role: .destructive) {
                store.delete(current)
                dismiss()
            }
            Button("Keep", role: .cancel) {}
        } message: {
            Text("The event and its posts will be removed.")
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(current.category.title, systemImage: current.category.icon)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.22))
                    .clipShape(Capsule())

                Label(current.format.title, systemImage: current.format.icon)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.22))
                    .clipShape(Capsule())

                Spacer()

                Text(current.countdownText)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white)
                    .foregroundStyle(accent)
                    .clipShape(Capsule())
            }
            .foregroundStyle(.white)

            Text(current.title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            if !current.organizerName.isEmpty {
                Text("Hosted by \(current.organizerName)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(current.theme.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - RSVP

    private var rsvpBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Text("\(current.totalAttendees) going")
                    .font(.subheadline.weight(.semibold))

                Text(current.isFull ? "Event is full" : "\(current.spotsLeft) spots left")
                    .font(.caption)
                    .foregroundStyle(current.isFull ? .red : .secondary)

                Spacer()

                Text(current.priceText)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(current.isFree ? .green : .primary)
            }

            capacityBar

            HStack(spacing: 12) {
                Button {
                    store.toggleAttendance(current)
                } label: {
                    Label(
                        current.isAttending ? "You're going" : (current.isFull ? "Event full" : "Attend"),
                        systemImage: current.isAttending ? "checkmark.circle.fill" : "calendar.badge.plus"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                }
                .buttonStyle(.borderedProminent)
                .tint(current.isAttending ? .green : accent)
                .disabled(current.isFull && !current.isAttending)

                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                        .padding(.vertical, 13)
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var capacityBar: some View {
        GeometryReader { geometry in
            let fraction = min(Double(current.totalAttendees) / Double(max(current.capacity, 1)), 1)

            ZStack(alignment: .leading) {
                Capsule().fill(accent.opacity(0.15))
                Capsule()
                    .fill(accent)
                    .frame(width: max(geometry.size.width * fraction, 4))
            }
        }
        .frame(height: 7)
    }

    private var shareText: String {
        [
            current.title,
            "\(current.dateLine) · \(current.timeLine)",
            current.locationLine,
            current.organizerName.isEmpty ? "" : "Hosted by \(current.organizerName)",
            current.summary
        ]
        .filter { !$0.isEmpty }
        .joined(separator: "\n")
    }

    // MARK: - Logistics

    private var whenAndWhere: some View {
        SectionCard(title: "When & where") {
            VStack(alignment: .leading, spacing: 14) {
                infoRow(icon: "calendar", title: current.dateLine, subtitle: current.timeLine)

                if !current.locationLine.isEmpty {
                    infoRow(
                        icon: current.format.icon,
                        title: current.venue.isEmpty ? current.city : current.venue,
                        subtitle: current.venue.isEmpty ? current.format.title : "\(current.city) · \(current.format.title)"
                    )
                }
            }
        }
    }

    private func infoRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(accent)
                .frame(width: 34, height: 34)
                .background(accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }

    private var agendaList: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(current.agenda) { item in
                HStack(alignment: .top, spacing: 14) {
                    Text(item.time)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accent)
                        .frame(width: 84, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.subheadline)

                        if !item.speaker.isEmpty {
                            Text(item.speaker)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    // MARK: - Social

    private var peopleYouKnow: some View {
        let known = store.connectionsAttending(current)

        return SectionCard(title: "People you've met") {
            if known.isEmpty {
                Text("Nobody from your network has RSVP'd yet. Good chance to meet someone new.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(known) { connection in
                        NavigationLink {
                            ConnectionDetailView(connection: connection)
                        } label: {
                            HStack(spacing: 12) {
                                AvatarView(initials: connection.initials, theme: connection.theme, size: 38)

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

                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(12)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var organizerCard: some View {
        if let connection = store.connections.first(where: { $0.id == current.organizerConnectionID }) {
            SectionCard(title: "Organizer") {
                NavigationLink {
                    ConnectionDetailView(connection: connection)
                } label: {
                    HStack(spacing: 12) {
                        AvatarView(initials: connection.initials, theme: connection.theme, size: 44)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(connection.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)

                            if !connection.jobLine.isEmpty {
                                Text(connection.jobLine)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if !connection.metAt.isEmpty {
                                Text("Met at \(connection.metAt)")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var postsSection: some View {
        let eventPosts = store.posts(forEvent: current.id)

        return SectionCard(
            title: "Event updates",
            action: current.isAttending ? { showComposer = true } : nil,
            actionLabel: "Post"
        ) {
            VStack(spacing: 12) {
                if !current.isAttending {
                    Text("Attend this event to post an update to everyone going.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if eventPosts.isEmpty {
                    Text("No updates from the organizer yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(eventPosts) { post in
                        NavigationLink {
                            PostDetailView(post: post)
                        } label: {
                            PostCardView(post: post, showsEventContext: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var hostControls: some View {
        VStack(spacing: 12) {
            Button {
                showEditor = true
            } label: {
                Label("Edit Event", systemImage: "square.and.pencil")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive) {
                showCancelAlert = true
            } label: {
                Label("Delete Event", systemImage: "trash")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: Event.samples[0])
            .environmentObject(AppStore())
    }
}
