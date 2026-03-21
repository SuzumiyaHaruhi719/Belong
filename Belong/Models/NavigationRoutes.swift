import Foundation

// Type-safe navigation destinations for each tab's NavigationStack

enum GatheringsRoute: Hashable {
    case detail(Gathering)
    case attendees(String)  // gatheringId
    case search
}

enum PostsRoute: Hashable {
    case detail(Post)
    case comments(String)  // postId
    case likes(String)  // postId
    case userPosts(String)  // userId
    case hashtagFeed(String)  // tag
}

enum CreateRoute: Hashable {
    case templatePicker
    case customizeGathering(HostingTemplate)
    case previewGathering
    case publishedGathering(String)  // gatheringId
    case createPost
}

enum ChatRoute: Hashable {
    case conversation(Conversation)
    case conversationInfo(String)  // conversationId
    case newConversation
    case groupChat(String)  // gatheringId
    case notificationsComments
    case notificationsLikes
    case notificationsMentions
}

enum ProfileRoute: Hashable {
    case editProfile
    case editTags
    case savedGatherings
    case savedPosts
    case followers
    case following
    case mutuals
    case userProfile(String)  // userId
    case myEvents
    case myGatherings
    case settings
    case notificationSettings
    case blockedUsers
    case about
    case browsingHistory
}
