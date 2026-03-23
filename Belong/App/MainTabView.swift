import SwiftUI
import Supabase
import Realtime

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @Environment(InAppBannerManager.self) private var bannerManager

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
        .task {
            await loadUnreadBadge()
        }
        .task(id: "globalChatListener") {
            await listenForNewMessages()
        }
    }

    private func loadUnreadBadge() async {
        do {
            let conversations = try await container.chatService.fetchConversations()
            appState.unreadChatCount = conversations.reduce(0) { $0 + $1.unreadCount }
        } catch {
            // Badge loading is best-effort
        }
    }

    /// Global realtime listener: increments badge and shows in-app banner
    /// when a new message arrives from another user.
    private func listenForNewMessages() async {
        let myId = SupabaseManager.shared.currentUserId ?? ""
        guard !myId.isEmpty else { return }

        let channel = SupabaseManager.shared.client.realtimeV2.channel("global-messages")
        let insertions = channel.postgresChange(InsertAction.self, table: "messages")
        await channel.subscribe()

        for await insert in insertions {
            let senderId = (try? insert.record["sender_id"]?.value as? String) ?? ""
            let content = (try? insert.record["content"]?.value as? String) ?? ""
            let conversationId = (try? insert.record["conversation_id"]?.value as? String) ?? ""

            if senderId != myId {
                // Bump badge
                appState.unreadChatCount += 1

                // Fetch sender info for banner
                let senderInfo = await fetchSenderInfo(senderId: senderId)
                let conv = await fetchConversationForBanner(conversationId: conversationId)

                let banner = InAppBanner(
                    senderName: senderInfo.name,
                    senderAvatarURL: senderInfo.avatarURL,
                    senderAvatarEmoji: senderInfo.emoji,
                    messagePreview: content.isEmpty ? "Sent a message" : content,
                    conversationId: conversationId,
                    senderId: senderId,
                    conversation: conv,
                    timestamp: Date()
                )
                bannerManager.show(banner)
            }
        }
    }

    private func fetchSenderInfo(senderId: String) async -> (name: String, emoji: String, avatarURL: URL?) {
        do {
            let rows: [DBUser] = try await SupabaseManager.shared.client
                .from("users")
                .select("id, display_name, username, avatar_url")
                .eq("id", value: senderId)
                .limit(1)
                .execute()
                .value
            if let row = rows.first {
                let name = row.displayName ?? row.username ?? "Someone"
                let url = row.avatarUrl.flatMap { URL(string: $0) }
                return (name, "👤", url)
            }
        } catch { }
        return ("Someone", "👤", nil)
    }

    private func fetchConversationForBanner(conversationId: String) async -> Conversation? {
        do {
            return try await container.chatService.fetchConversations()
                .first { $0.id == conversationId }
        } catch { }
        return nil
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
                .navigationDestination(for: ChatRoute.self) { route in
                    switch route {
                    case .notificationsComments:
                        NotificationListScreen(filter: .comments)
                    case .notificationsLikes:
                        NotificationListScreen(filter: .likes)
                    case .notificationsMentions:
                        NotificationListScreen(filter: .mentions)
                    default:
                        EmptyView()
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
    @State private var chatNavPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $chatNavPath) {
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
                    case .notificationsComments:
                        NotificationListScreen(filter: .comments)
                    case .notificationsLikes:
                        NotificationListScreen(filter: .likes)
                    case .notificationsMentions:
                        NotificationListScreen(filter: .mentions)
                    }
                }
                .navigationDestination(for: ProfileRoute.self) { route in
                    switch route {
                    case .userProfile(let userId):
                        UserProfileScreen(userId: userId)
                    default:
                        EmptyView()
                    }
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openConversation)) { notif in
            if let conv = notif.userInfo?["conversation"] as? Conversation {
                chatNavPath = NavigationPath()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    chatNavPath.append(ChatRoute.conversation(conv))
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
