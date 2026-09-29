import SwiftUI

struct ConnectionDetailView: View {
    let connection: Connection

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var showEditor = false
    @State private var showDeleteAlert = false

    private var current: Connection {
        store.connections.first { $0.id == connection.id } ?? connection
    }

    private var accent: Color { current.theme.accent }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                messageButton
                howYouMet
                contactCard

                if !current.about.isEmpty {
                    SectionCard(title: "About") {
                        AboutText(text: current.about)
                    }
                }

                if !current.experience.isEmpty {
                    SectionCard(title: "Experience") {
                        ExperienceList(items: current.experience, accent: accent)
                    }
                }

                if !current.skills.isEmpty {
                    SectionCard(title: "Skills") {
                        SkillChips(skills: current.skills, accent: accent)
                    }
                }

                activitySection
                deleteButton
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(current.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleFavorite(current)
                } label: {
                    Image(systemName: current.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(current.isFavorite ? .yellow : .accentColor)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditor = true }
            }
        }
        .sheet(isPresented: $showEditor) {
            ConnectionEditorView(connection: current)
        }
        .alert("Remove connection?", isPresented: $showDeleteAlert) {
            Button("Remove", role: .destructive) {
                store.delete(current)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(current.name) and their posts will be removed from your network.")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 0) {
            current.theme.gradient
                .frame(height: 110)
                .overlay(alignment: .bottomLeading) {
                    AvatarView(initials: current.initials, theme: current.theme, size: 84)
                        .overlay(Circle().stroke(Color(.secondarySystemGroupedBackground), lineWidth: 4))
                        .offset(x: 18, y: 42)
                }

            VStack(alignment: .leading, spacing: 5) {
                Text(current.name)
                    .font(.system(size: 23, weight: .bold, design: .rounded))

                if !current.jobLine.isEmpty {
                    Text(current.jobLine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    Label(current.tag.title, systemImage: current.tag.icon)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(current.tag.color.opacity(0.15))
                        .foregroundStyle(current.tag.color)
                        .clipShape(Capsule())

                    if !current.location.isEmpty {
                        Label(current.location, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 52)
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var messageButton: some View {
        NavigationLink {
            ChatView(connection: current)
        } label: {
            Label(unreadLabel, systemImage: "bubble.left.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
        }
        .buttonStyle(.borderedProminent)
        .tint(accent)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var unreadLabel: String {
        let unread = store.conversation(with: current.id)?.unreadCount ?? 0
        return unread > 0 ? "Message · \(unread) new" : "Message"
    }

    // MARK: - Personal context

    private var howYouMet: some View {
        SectionCard(title: "How you met", action: { showEditor = true }) {
            VStack(alignment: .leading, spacing: 10) {
                Label(
                    current.metAt.isEmpty ? "No place recorded" : current.metAt,
                    systemImage: "mappin.and.ellipse"
                )
                .font(.subheadline.weight(.medium))
                .foregroundStyle(current.metAt.isEmpty ? .secondary : .primary)

                Label(
                    "Saved \(current.dateAdded.formatted(date: .abbreviated, time: .omitted))",
                    systemImage: "calendar"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                if current.note.isEmpty {
                    Text("Add a note so you remember what you talked about.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                } else {
                    Text(current.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)
                }
            }
        }
    }

    // MARK: - Contact

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            actionRow(icon: "envelope.fill", color: .blue, text: current.email, url: mailURL)
            actionRow(icon: "phone.fill", color: .green, text: current.phone, url: phoneURL)
            actionRow(icon: "globe", color: .purple, text: current.website, url: normalizedURL(from: current.website))

            if current.email.isEmpty, current.phone.isEmpty, current.website.isEmpty {
                Text("No contact details saved.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(16)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var mailURL: URL? {
        current.email.isEmpty ? nil : URL(string: "mailto:\(current.email)")
    }

    private var phoneURL: URL? {
        let digits = current.phone.filter { $0.isNumber || $0 == "+" }
        return digits.isEmpty ? nil : URL(string: "tel:\(digits)")
    }

    @ViewBuilder
    private func actionRow(icon: String, color: Color, text: String, url: URL?) -> some View {
        if !text.isEmpty {
            if let url {
                Link(destination: url) { rowContent(icon: icon, color: color, text: text) }
            } else {
                rowContent(icon: icon, color: color, text: text)
            }
        }
    }

    private func rowContent(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 26)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
    }

    // MARK: - Activity

    private var activitySection: some View {
        let theirPosts = store.posts(by: current.id)

        return SectionCard(title: "Their activity") {
            if theirPosts.isEmpty {
                Text("\(current.name.split(separator: " ").first.map(String.init) ?? current.name) hasn't posted yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(theirPosts) { post in
                        NavigationLink {
                            PostDetailView(post: post)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(post.date.formatted(.relative(presentation: .named)))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)

                                Text(post.text)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(14)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteAlert = true
        } label: {
            Label("Remove Connection", systemImage: "trash")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    NavigationStack {
        ConnectionDetailView(connection: Connection.samples[0])
            .environmentObject(AppStore())
    }
}
