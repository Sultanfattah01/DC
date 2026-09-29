import SwiftUI

struct ConnectionsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var query = ""
    @State private var tagFilter: ConnectionTag?
    @State private var favoritesOnly = false
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    dashboardCard
                    if !store.tagBreakdown.isEmpty {
                        tagBreakdown
                    }
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                Section {
                    filterChips
                }
                .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                Section("\(filtered.count) \(filtered.count == 1 ? "card" : "cards")") {
                    if filtered.isEmpty {
                        Text(emptyMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 12)
                    } else {
                        ForEach(filtered) { connection in
                            NavigationLink {
                                ConnectionDetailView(connection: connection)
                            } label: {
                                ConnectionRow(connection: connection)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    store.delete(connection)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    store.toggleFavorite(connection)
                                } label: {
                                    Label("Favorite", systemImage: connection.isFavorite ? "star.slash" : "star")
                                }
                                .tint(.yellow)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Network")
            .searchable(text: $query, prompt: "Search name, company, or where you met")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                ConnectionEditorView()
            }
        }
    }

    private var filtered: [Connection] {
        store.sortedConnections.filter { connection in
            let matchesTag = tagFilter == nil || connection.tag == tagFilter
            let matchesFavorite = !favoritesOnly || connection.isFavorite
            let matchesQuery = query.isEmpty
                || connection.name.localizedCaseInsensitiveContains(query)
                || connection.company.localizedCaseInsensitiveContains(query)
                || connection.role.localizedCaseInsensitiveContains(query)
                || connection.metAt.localizedCaseInsensitiveContains(query)

            return matchesTag && matchesFavorite && matchesQuery
        }
    }

    private var emptyMessage: String {
        store.connections.isEmpty
            ? "Tap + to save your first card."
            : "No connections match this filter."
    }

    // MARK: - Dashboard

    private var dashboardCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cards collected")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.85))

                Text("\(store.connectionCount)")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 0) {
                metric(value: store.newThisWeek, label: "This week")
                metricDivider
                metric(value: store.favoriteCount, label: "Favorites")
                metricDivider
                metric(value: store.companyCount, label: "Companies")
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(store.profile.theme.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func metric(value: Int, label: String) -> some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }

    private var metricDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.25))
            .frame(width: 1, height: 30)
    }

    private var tagBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Breakdown")
                .font(.headline)

            ForEach(store.tagBreakdown, id: \.tag) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.tag.icon)
                        .font(.caption)
                        .foregroundStyle(item.tag.color)
                        .frame(width: 20)

                    Text(item.tag.title)
                        .font(.subheadline)
                        .frame(width: 82, alignment: .leading)

                    GeometryReader { geometry in
                        let fraction = Double(item.count) / Double(max(store.connectionCount, 1))

                        ZStack(alignment: .leading) {
                            Capsule().fill(item.tag.color.opacity(0.15))
                            Capsule()
                                .fill(item.tag.color)
                                .frame(width: max(geometry.size.width * fraction, 6))
                        }
                    }
                    .frame(height: 8)

                    Text("\(item.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 22, alignment: .trailing)
                }
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", isOn: tagFilter == nil && !favoritesOnly, color: store.profile.theme.accent) {
                    tagFilter = nil
                    favoritesOnly = false
                }

                chip(title: "Favorites", isOn: favoritesOnly, color: .yellow) {
                    favoritesOnly.toggle()
                }

                ForEach(ConnectionTag.allCases) { tag in
                    chip(title: tag.title, isOn: tagFilter == tag, color: tag.color) {
                        tagFilter = tagFilter == tag ? nil : tag
                    }
                }
            }
        }
    }

    private func chip(title: String, isOn: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isOn ? color : Color(.secondarySystemGroupedBackground))
                .foregroundStyle(isOn ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct ConnectionRow: View {
    let connection: Connection

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(initials: connection.initials, theme: connection.theme, size: 44)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(connection.name)
                        .font(.subheadline.weight(.semibold))

                    if connection.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }

                if !connection.jobLine.isEmpty {
                    Text(connection.jobLine)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if !connection.metAt.isEmpty {
                    Text("Met at \(connection.metAt)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(connection.tag.title)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(connection.tag.color.opacity(0.15))
                .foregroundStyle(connection.tag.color)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ConnectionsView()
        .environmentObject(AppStore())
}
