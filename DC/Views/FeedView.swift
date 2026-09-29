import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showComposer = false
    @State private var filter: FeedFilter = .all

    private enum FeedFilter: Hashable, CaseIterable {
        case all
        case mine
        case events
        case kind(PostKind)

        static var allCases: [FeedFilter] {
            [.all, .mine, .events] + PostKind.allCases.map(FeedFilter.kind)
        }

        var title: String {
            switch self {
            case .all: "All"
            case .mine: "Mine"
            case .events: "Events"
            case let .kind(kind): kind.title
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    composer
                    filterChips

                    if filtered.isEmpty {
                        ContentUnavailableView(
                            "Nothing here yet",
                            systemImage: "bubble.left.and.bubble.right",
                            description: Text("Updates from people you've met will appear in this feed.")
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(filtered) { post in
                            NavigationLink {
                                PostDetailView(post: post)
                            } label: {
                                PostCardView(post: post)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Feed")
            .sheet(isPresented: $showComposer) {
                ComposePostView()
            }
        }
    }

    private var filtered: [Post] {
        switch filter {
        case .all: store.feed
        case .mine: store.myPosts
        case .events: store.feed.filter { $0.eventID != nil }
        case let .kind(kind): store.feed.filter { $0.kind == kind }
        }
    }

    private var composer: some View {
        Button {
            showComposer = true
        } label: {
            HStack(spacing: 12) {
                AvatarView(
                    initials: store.profile.initials,
                    theme: store.profile.theme,
                    photoData: store.profile.photoData,
                    size: 40
                )

                Text("Share an update with your network")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "square.and.pencil")
                    .foregroundStyle(store.profile.theme.accent)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FeedFilter.allCases, id: \.self) { option in
                    Button {
                        filter = option
                    } label: {
                        Text(option.title)
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                filter == option
                                    ? store.profile.theme.accent
                                    : Color(.secondarySystemGroupedBackground)
                            )
                            .foregroundStyle(filter == option ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

struct ComposePostView: View {
    var eventID: UUID?
    var eventTitle: String?

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var kind: PostKind = .update

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    AvatarView(
                        initials: store.profile.initials,
                        theme: store.profile.theme,
                        photoData: store.profile.photoData,
                        size: 44
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.profile.name)
                            .font(.subheadline.weight(.semibold))

                        if let eventTitle {
                            Label(eventTitle, systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Visible to your \(store.connectionCount) connections")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Picker("Type", selection: $kind) {
                    ForEach(PostKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                TextEditor(text: $text)
                    .font(.body)
                    .frame(minHeight: 200)
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text("What are you working on?")
                                .font(.body)
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }

                Spacer()
            }
            .padding()
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        store.addPost(text: text, kind: kind, eventID: eventID)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(AppStore())
}
