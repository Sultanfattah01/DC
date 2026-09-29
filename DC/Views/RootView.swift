import SwiftUI

enum AppTab: Hashable {
    case feed
    case events
    case messages
    case network
    case profile
}

struct RootView: View {
    @StateObject private var store = AppStore()
    @State private var selectedTab: AppTab = .feed

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem { Label("Feed", systemImage: "house.fill") }
                .tag(AppTab.feed)

            EventsView()
                .tabItem { Label("Events", systemImage: "calendar") }
                .tag(AppTab.events)

            MessagesView()
                .tabItem { Label("Messages", systemImage: "bubble.left.and.bubble.right.fill") }
                .badge(store.totalUnread)
                .tag(AppTab.messages)

            ConnectionsView()
                .tabItem { Label("Network", systemImage: "person.2.fill") }
                .tag(AppTab.network)

            ProfileView(selectedTab: $selectedTab)
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(AppTab.profile)
        }
        .environmentObject(store)
        .tint(store.profile.theme.accent)
    }
}

#Preview {
    RootView()
}
