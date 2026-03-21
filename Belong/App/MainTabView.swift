import SwiftUI

// MARK: - MainTabView
// Spec: Bottom tab bar with 4 tabs — Home, My Events, Host, Profile.
// Tab bar: 49pt + safe area, terracotta active color, warm gray inactive.

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        TabView(selection: $state.selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {
                HomeNavigationStack()
            }
            Tab("My Events", systemImage: "calendar", value: .events) {
                EventsNavigationStack()
            }
            Tab("Host", systemImage: "plus.circle", value: .host) {
                HostNavigationStack()
            }
            Tab("Profile", systemImage: "person", value: .profile) {
                ProfileNavigationStack()
            }
        }
        .tint(BelongColor.primary)
    }
}

// MARK: - Navigation Stacks per tab

struct HomeNavigationStack: View {
    var body: some View {
        NavigationStack {
            HomeFeedScreen()
        }
    }
}

struct EventsNavigationStack: View {
    var body: some View {
        NavigationStack {
            MyEventsScreen()
        }
    }
}

struct HostNavigationStack: View {
    var body: some View {
        NavigationStack {
            TemplatePickerScreen()
        }
    }
}

struct ProfileNavigationStack: View {
    var body: some View {
        NavigationStack {
            ProfileScreen()
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
