import SwiftUI

struct PostCardView: View {
    let post: Post
    var showsFooter = true
    var showsEventContext = true

    @EnvironmentObject private var store: AppStore

    private var author: AuthorInfo { store.info(for: post.author) }
    private var event: Event? { store.event(id: post.eventID) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AvatarView(
                    initials: author.initials,
                    theme: author.theme,
                    photoData: author.photoData,
                    size: 44
                )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(author.name)
                            .font(.subheadline.weight(.semibold))

                        if post.author == .me {
                            Text("You")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    if !author.subtitle.isEmpty {
                        Text(author.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Text(post.date.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                if post.kind != .update {
                    Label(post.kind.title, systemImage: post.kind.icon)
                        .font(.caption2.weight(.semibold))
                        .labelStyle(.titleAndIcon)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(post.kind.color.opacity(0.15))
                        .foregroundStyle(post.kind.color)
                        .clipShape(Capsule())
                }
            }

            if !author.metAt.isEmpty {
                Label("Met at \(author.metAt)", systemImage: "mappin.and.ellipse")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if showsEventContext, let event {
                Label(event.title, systemImage: "calendar")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(event.theme.accent.opacity(0.12))
                    .foregroundStyle(event.theme.accent)
                    .clipShape(Capsule())
            }

            Text(post.text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if showsFooter {
                Divider()

                HStack(spacing: 22) {
                    Button {
                        store.toggleLike(post)
                    } label: {
                        Label(
                            post.likeCount > 0 ? "\(post.likeCount)" : "Like",
                            systemImage: post.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"
                        )
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(post.isLiked ? Color.accentColor : .secondary)
                    }
                    .buttonStyle(.plain)

                    Label(
                        post.comments.isEmpty ? "Comment" : "\(post.comments.count)",
                        systemImage: "bubble.left"
                    )
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)

                    Spacer()
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    PostCardView(post: SampleData.posts[0])
        .environmentObject(AppStore())
        .padding()
}
