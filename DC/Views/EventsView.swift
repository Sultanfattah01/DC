import SwiftUI

struct EventsView: View {
    @EnvironmentObject private var store: AppStore

    @State private var query = ""
    @State private var filter: EventFilter = .all
    @State private var selectedEvent: Event?
    @State private var showHostSheet = false

    private enum EventFilter: Hashable {
        case all
        case attending
        case saved
        case free
        case past
        case category(EventCategory)

        static var allOptions: [EventFilter] {
            [.all, .attending, .saved, .free] + EventCategory.allCases.map(EventFilter.category) + [.past]
        }

        var title: String {
            switch self {
            case .all: "All"
            case .attending: "Going"
            case .saved: "Saved"
            case .free: "Free"
            case .past: "Past"
            case let .category(category): category.title
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if let next = store.nextEvent, filter == .all, query.isEmpty {
                        nextUpCard(next)
                    }

                    filterChips

                    if filtered.isEmpty {
                        ContentUnavailableView(
                            "No events found",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("Try a different filter, or host your own event with the + button.")
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(filtered) { event in
                            EventCardView(event: event)
                                .contentShape(RoundedRectangle(cornerRadius: 20))
                                .onTapGesture { selectedEvent = event }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Events")
            .searchable(text: $query, prompt: "Search events, organizers, or topics")
            .navigationDestination(item: $selectedEvent) { event in
                EventDetailView(event: event)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showHostSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showHostSheet) {
                EventEditorView()
            }
        }
    }

    private var filtered: [Event] {
        let base: [Event] = switch filter {
        case .all: store.upcomingEvents
        case .attending: store.attendingEvents
        case .saved: store.savedEvents
        case .free: store.upcomingEvents.filter(\.isFree)
        case .past: store.pastEvents
        case let .category(category): store.upcomingEvents.filter { $0.category == category }
        }

        guard !query.isEmpty else { return base }

        return base.filter { event in
            event.title.localizedCaseInsensitiveContains(query)
                || event.organizerName.localizedCaseInsensitiveContains(query)
                || event.city.localizedCaseInsensitiveContains(query)
                || event.venue.localizedCaseInsensitiveContains(query)
                || event.topics.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    private func nextUpCard(_ event: Event) -> some View {
        Button {
            selectedEvent = event
        } label: {
            HStack(spacing: 14) {
                VStack(spacing: 0) {
                    Text(event.monthShort)
                        .font(.caption2.weight(.bold))
                    Text(event.dayNumber)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Next up · \(event.countdownText)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.85))

                    Text(event.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text("\(event.timeLine) · \(event.locationLine)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(16)
            .background(event.theme.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EventFilter.allOptions, id: \.self) { option in
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

#Preview {
    EventsView()
        .environmentObject(AppStore())
}
