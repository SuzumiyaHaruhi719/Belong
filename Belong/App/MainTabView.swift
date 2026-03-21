import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        TabView(selection: $state.selectedTab) {
            Tab("Gatherings", systemImage: "person.3", value: .gatherings) {
                GatheringsTabRoot()
            }
            Tab("Posts", systemImage: "square.grid.2x2", value: .posts) {
                PostsTabRoot()
            }
            Tab("Create", systemImage: "plus.circle.fill", value: .create) {
                Color.clear
            }
            Tab("Chat", systemImage: "bubble.left.and.bubble.right", value: .chat) {
                ChatTabRoot()
            }
            .badge(appState.totalBadgeCount)
            Tab("Profile", systemImage: "person.crop.circle", value: .profile) {
                ProfileTabRoot()
            }
        }
        .tint(BelongColor.primary)
        .onChange(of: appState.selectedTab) { oldTab, newTab in
            if newTab == .create {
                appState.selectedTab = oldTab
                appState.showCreateSheet = true
            } else {
                appState.previousTab = newTab
            }
        }
        .sheet(isPresented: $state.showCreateSheet) {
            CreateSelectorSheet()
                .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $state.showCreateGatheringFlow) {
            CreateGatheringFlow()
        }
        .fullScreenCover(isPresented: $state.showCreatePostScreen) {
            CreatePostScreen()
        }
    }
}

// MARK: - Tab Root Placeholders (replaced in later phases)

struct GatheringsTabRoot: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        NavigationStack {
            GatheringsFeedScreen(container: container)
                .navigationDestination(for: GatheringsRoute.self) { route in
                    switch route {
                    case .detail(let gathering):
                        GatheringDetailScreen(gathering: gathering, container: container)
                            .navigationDestination(for: GatheringsRoute.self) { innerRoute in
                                switch innerRoute {
                                case .attendees(let gatheringId):
                                    GatheringAttendeesScreen(gatheringId: gatheringId, container: container)
                                case .search:
                                    GatheringSearchScreen(container: container)
                                default:
                                    EmptyView()
                                }
                            }
                    case .attendees(let gatheringId):
                        GatheringAttendeesScreen(gatheringId: gatheringId, container: container)
                    case .search:
                        GatheringSearchScreen(container: container)
                    }
                }
        }
    }
}

struct PostsTabRoot: View {
    var body: some View {
        NavigationStack {
            PostsFeedScreen()
                .navigationDestination(for: PostsRoute.self) { route in
                    switch route {
                    case .detail(let post):
                        PostDetailScreen(post: post)
                    case .comments(let postId):
                        PostCommentsScreen(postId: postId)
                    case .likes(let postId):
                        PostLikesScreen(postId: postId)
                    case .userPosts(let userId):
                        UserPostsScreen(mode: .user(userId))
                    case .hashtagFeed(let tag):
                        UserPostsScreen(mode: .hashtag(tag))
                    }
                }
        }
    }
}

struct ChatTabRoot: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        NavigationStack {
            ChatListScreen()
                .navigationDestination(for: ChatRoute.self) { route in
                    switch route {
                    case .conversation(let conversation):
                        ChatDetailScreen(conversation: conversation)
                    case .conversationInfo(let conversationId):
                        ChatInfoScreen(conversationId: conversationId)
                    case .newConversation:
                        NewConversationScreen()
                    case .groupChat(let gatheringId):
                        GroupChatScreen(gatheringId: gatheringId)
                    }
                }
        }
    }
}

struct ProfileTabRoot: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        NavigationStack {
            ProfileScreen()
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .editProfile:
                        EditProfileScreen()
                    case .editTags:
                        EditCulturalTagsScreen()
                    case .savedGatherings:
                        SavedGatheringsScreen()
                    case .savedPosts:
                        SavedPostsScreen()
                    case .followers:
                        ConnectionsScreen(initialTab: .followers)
                    case .following:
                        ConnectionsScreen(initialTab: .following)
                    case .mutuals:
                        ConnectionsScreen(initialTab: .mutuals)
                    case .userProfile(let userId):
                        UserProfileScreen(userId: userId)
                    case .myEvents:
                        MyEventsScreen()
                    case .myGatherings:
                        MyGatheringsScreen()
                    case .settings:
                        SettingsScreen()
                    case .notificationSettings:
                        NotificationSettingsScreen()
                    case .blockedUsers:
                        BlockedUsersScreen()
                    case .about:
                        AboutScreen()
                    case .browsingHistory:
                        BrowsingHistoryScreen()
                    }
                }
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
        .environment(DependencyContainer())
}

struct CreateSelectorPlaceholder: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Text("What would you like to create?")
                .font(BelongFont.h2())
            Text("Host a Gathering")
                .font(BelongFont.bodyMedium())
                .foregroundStyle(BelongColor.primary)
            Text("Share a Post")
                .font(BelongFont.bodyMedium())
                .foregroundStyle(BelongColor.primary)
        }
        .padding()
    }
}
