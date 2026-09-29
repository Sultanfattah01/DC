import SwiftUI

struct MyCardView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showEditor = false

    private var profile: UserProfile { store.profile }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                BusinessCardView(profile: profile)
                linkSection
                editButton
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("My Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: store.shareText) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            ProfileEditorView(profile: $store.profile)
        }
    }

    private var linkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Connect")
                    .font(.headline)
                Spacer()
                Text("\(profile.links.count) links")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if profile.links.isEmpty {
                ContentUnavailableView(
                    "No links yet",
                    systemImage: "link.badge.plus",
                    description: Text("Edit your card to add a portfolio, social profile, or any URL.")
                )
                .frame(minHeight: 180)
            } else {
                ForEach(profile.links) { link in
                    if let url = normalizedURL(from: link.url) {
                        Link(destination: url) { linkRow(link) }
                    } else {
                        linkRow(link)
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func linkRow(_ link: BusinessLink) -> some View {
        HStack(spacing: 14) {
            Image(systemName: link.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(profile.theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(link.title.isEmpty ? "Untitled link" : link.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(link.url)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var editButton: some View {
        Button {
            showEditor = true
        } label: {
            Label("Customize My Card", systemImage: "slider.horizontal.3")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        MyCardView()
            .environmentObject(AppStore())
    }
}
