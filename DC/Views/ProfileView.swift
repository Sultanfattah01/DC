import SwiftUI

struct ProfileView: View {
    @Binding var selectedTab: AppTab
    @EnvironmentObject private var store: AppStore
    @State private var showEditor = false

    private var profile: UserProfile { store.profile }
    private var accent: Color { profile.theme.accent }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    statsGrid
                    actionButtons

                    if !profile.about.isEmpty {
                        SectionCard(title: "About", action: { showEditor = true }) {
                            AboutText(text: profile.about)
                        }
                    }

                    if !profile.experience.isEmpty {
                        SectionCard(title: "Experience", action: { showEditor = true }) {
                            ExperienceList(items: profile.experience, accent: accent)
                        }
                    }

                    if !profile.education.isEmpty {
                        SectionCard(title: "Education", action: { showEditor = true }) {
                            EducationList(items: profile.education, accent: accent)
                        }
                    }

                    if !profile.skills.isEmpty {
                        SectionCard(title: "Skills", action: { showEditor = true }) {
                            SkillChips(skills: profile.skills, accent: accent)
                        }
                    }

                    eventsSection
                    activitySection
                    networkSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showEditor) {
                ProfileEditorView(profile: $store.profile)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 0) {
            banner
                .overlay(alignment: .bottomLeading) {
                    profilePhoto
                        .offset(x: 18, y: 46)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                if !profile.jobLine.isEmpty {
                    Text(profile.jobLine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if !profile.bio.isEmpty {
                    Text(profile.bio)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }

                HStack(spacing: 14) {
                    if !profile.location.isEmpty {
                        Label(profile.location, systemImage: "location.fill")
                    }
                    Label("\(store.connectionCount) connections", systemImage: "person.2.fill")
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 56)
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var banner: some View {
        ZStack {
            if let image = profile.bannerData.flatMap(UIImage.init(data:)) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                profile.theme.gradient
            }
        }
        .frame(height: 130)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private var profilePhoto: some View {
        AvatarView(
            initials: profile.initials,
            theme: profile.theme,
            photoData: profile.photoData,
            size: 88
        )
        .overlay(Circle().stroke(Color(.secondarySystemGroupedBackground), lineWidth: 4))
    }

    // MARK: - Stats

    private var statsGrid: some View {
        HStack(spacing: 12) {
            statCard(value: "\(store.connectionCount)", label: "Connections", icon: "person.2.fill")
            statCard(value: "\(store.myPosts.count)", label: "Posts", icon: "text.bubble.fill")
            statCard(value: "\(store.newThisWeek)", label: "This week", icon: "sparkles")
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(accent)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showEditor = true
            } label: {
                Label("Edit Profile", systemImage: "square.and.pencil")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            HStack(spacing: 12) {
                NavigationLink {
                    MyCardView()
                } label: {
                    Label("My Card", systemImage: "person.text.rectangle")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)

                ShareLink(item: store.shareText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Events

    private var eventsSection: some View {
        SectionCard(
            title: "Events you're attending",
            action: { selectedTab = .events },
            actionLabel: "Browse"
        ) {
            if store.attendingEvents.isEmpty {
                Text("You haven't signed up for anything yet. Browse events to find people worth meeting.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(store.attendingEvents.prefix(3)) { event in
                        NavigationLink {
                            EventDetailView(event: event)
                        } label: {
                            HStack(spacing: 12) {
                                VStack(spacing: 0) {
                                    Text(event.monthShort)
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(event.theme.accent)
                                    Text(event.dayNumber)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                }
                                .frame(width: 44, height: 44)
                                .background(event.theme.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)

                                    Text("\(event.countdownText) · \(event.timeLine)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
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

    // MARK: - Activity

    private var activitySection: some View {
        SectionCard(title: "Your activity", action: { selectedTab = .feed }, actionLabel: "Feed") {
            if store.myPosts.isEmpty {
                Text("You haven't posted yet. Share an update from the Feed tab.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(store.myPosts.prefix(2)) { post in
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

                                HStack(spacing: 16) {
                                    Label("\(post.likeCount)", systemImage: "hand.thumbsup")
                                    Label("\(post.comments.count)", systemImage: "bubble.left")
                                }
                                .font(.caption2)
                                .foregroundStyle(.secondary)
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

    // MARK: - Network

    private var networkSection: some View {
        SectionCard(
            title: "People you've met",
            action: { selectedTab = .network },
            actionLabel: "See all"
        ) {
            if store.recentConnections.isEmpty {
                Text("Cards you collect will show up here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.recentConnections) { connection in
                            NavigationLink {
                                ConnectionDetailView(connection: connection)
                            } label: {
                                connectionTile(connection)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func connectionTile(_ connection: Connection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AvatarView(initials: connection.initials, theme: connection.theme, size: 42)

            Text(connection.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            Text(connection.company.isEmpty ? connection.tag.title : connection.company)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            if !connection.metAt.isEmpty {
                Text(connection.metAt)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .frame(width: 148, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ProfileView(selectedTab: .constant(.profile))
        .environmentObject(AppStore())
}
