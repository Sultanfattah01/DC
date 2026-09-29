import SwiftUI

struct PostDetailView: View {
    let post: Post

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var commentText = ""
    @FocusState private var isCommentFocused: Bool

    private var current: Post {
        store.posts.first { $0.id == post.id } ?? post
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 14) {
                    PostCardView(post: current)

                    if current.comments.isEmpty {
                        Text("No comments yet. Be the first to reply.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(current.comments.count) \(current.comments.count == 1 ? "comment" : "comments")")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(current.comments) { comment in
                                commentRow(comment)
                            }
                        }
                    }
                }
                .padding(16)
            }

            composer
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if current.author == .me {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        store.delete(current)
                        dismiss()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }

    private func commentRow(_ comment: Comment) -> some View {
        let author = store.info(for: comment.author)

        return HStack(alignment: .top, spacing: 12) {
            AvatarView(
                initials: author.initials,
                theme: author.theme,
                photoData: author.photoData,
                size: 34
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(author.name)
                        .font(.footnote.weight(.semibold))

                    Text(comment.date.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Text(comment.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var composer: some View {
        HStack(spacing: 12) {
            TextField("Add a comment", text: $commentText, axis: .vertical)
                .lineLimit(1...4)
                .focused($isCommentFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())

            Button {
                store.addComment(to: current, text: commentText)
                commentText = ""
                isCommentFocused = false
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
            }
            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.bar)
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: SampleData.posts[0])
            .environmentObject(AppStore())
    }
}
