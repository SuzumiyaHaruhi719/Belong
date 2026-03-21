import Foundation

// MARK: - Messages & Conversations
extension SampleData {

    // Stable conversation IDs
    static let conversationIdMaiYuki   = "conv-00000001-mai-yuki"
    static let conversationIdPhoGroup  = "conv-00000002-pho-group"
    static let conversationIdMaiCarlos = "conv-00000003-mai-carlos"

    // MARK: - Conversations

    static let conversations: [Conversation] = [
        // 1. DM: Mai <-> Yuki (mutual follow)
        Conversation(
            id: conversationIdMaiYuki,
            type: .dm,
            gatheringId: nil,
            title: "Yuki Tanaka",
            lastMessageText: "See you there! I will bring the wagashi",
            lastMessageAt: cal(.hour, -2),
            unreadCount: 1,
            members: [
                ConversationMemberInfo(userId: userIdMai, displayName: "Mai Nguyen", avatarEmoji: "🌿", avatarURL: nil),
                ConversationMemberInfo(userId: userIdYuki, displayName: "Yuki Tanaka", avatarEmoji: "🌺", avatarURL: nil),
            ],
            createdAt: cal(.day, -5),
            isMutualFollow: true
        ),
        // 2. Gathering group: Vietnamese Pho Cooking Class
        Conversation(
            id: conversationIdPhoGroup,
            type: .gatheringGroup,
            gatheringId: gatheringIdPho,
            title: "Vietnamese Pho Cooking Class",
            lastMessageText: "See everyone Saturday at 11am! Kitchen is Level 2.",
            lastMessageAt: cal(.hour, -4),
            unreadCount: 3,
            members: [
                ConversationMemberInfo(userId: hostLinhTran.id, displayName: "Linh Tran", avatarEmoji: "🌸", avatarURL: nil),
                ConversationMemberInfo(userId: userIdMai, displayName: "Mai Nguyen", avatarEmoji: "🌿", avatarURL: nil),
                ConversationMemberInfo(userId: userIdJin, displayName: "Jin Park", avatarEmoji: "⭐", avatarURL: nil),
                ConversationMemberInfo(userId: userIdPriya, displayName: "Priya Sharma", avatarEmoji: "🔥", avatarURL: nil),
                ConversationMemberInfo(userId: userIdAmira, displayName: "Amira Hassan", avatarEmoji: "🌙", avatarURL: nil),
                ConversationMemberInfo(userId: userIdCarlos, displayName: "Carlos Mendez", avatarEmoji: "🍊", avatarURL: nil),
                ConversationMemberInfo(userId: userIdYuki, displayName: "Yuki Tanaka", avatarEmoji: "🌺", avatarURL: nil),
            ],
            createdAt: cal(.day, -5),
            isMutualFollow: true
        ),
        // 3. DM: Mai -> Carlos (NOT mutual follow, one message)
        Conversation(
            id: conversationIdMaiCarlos,
            type: .dm,
            gatheringId: nil,
            title: "Carlos Mendez",
            lastMessageText: "Hey! Your salsa class looked amazing, I'd love to join next time",
            lastMessageAt: cal(.day, -1),
            unreadCount: 0,
            members: [
                ConversationMemberInfo(userId: userIdMai, displayName: "Mai Nguyen", avatarEmoji: "🌿", avatarURL: nil),
                ConversationMemberInfo(userId: userIdCarlos, displayName: "Carlos Mendez", avatarEmoji: "🍊", avatarURL: nil),
            ],
            createdAt: cal(.day, -1),
            isMutualFollow: false
        ),
    ]

    // MARK: - Messages by Conversation

    static let allMessages: [String: [Message]] = [
        conversationIdMaiYuki: maiYukiMessages,
        conversationIdPhoGroup: phoGroupMessages,
        conversationIdMaiCarlos: maiCarlosMessages,
    ]

    // MARK: - Conversation 1: Mai <-> Yuki (10 messages)

    static let maiYukiMessages: [Message] = [
        Message(
            id: "msg-my-001",
            conversationId: conversationIdMaiYuki,
            senderId: userIdYuki,
            content: "Hey! I saw you at the garden walk last week",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -4, hour: -6),
            senderName: "Yuki Tanaka",
            senderAvatarEmoji: "🌺",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        Message(
            id: "msg-my-002",
            conversationId: conversationIdMaiYuki,
            senderId: userIdMai,
            content: "Yes! It was so beautiful. The tea ceremony was my favourite part",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [MessageReaction(emoji: "💚", count: 1, hasReacted: false)],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -4, hour: -5),
            senderName: "Mai Nguyen",
            senderAvatarEmoji: "🌿",
            isCurrentUser: true,
            sharedPostPreview: nil
        ),
        Message(
            id: "msg-my-003",
            conversationId: conversationIdMaiYuki,
            senderId: userIdYuki,
            content: "I'm hosting another one next month, would love to have you",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -4, hour: -4),
            senderName: "Yuki Tanaka",
            senderAvatarEmoji: "🌺",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        Message(
            id: "msg-my-004",
            conversationId: conversationIdMaiYuki,
            senderId: userIdMai,
            content: "Definitely count me in! Do you need help setting up?",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -4, hour: -3),
            senderName: "Mai Nguyen",
            senderAvatarEmoji: "🌿",
            isCurrentUser: true,
            sharedPostPreview: nil
        ),
        Message(
            id: "msg-my-005",
            conversationId: conversationIdMaiYuki,
            senderId: userIdYuki,
            content: "That would be amazing! I could use help carrying the tea sets to the gardens",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -3, hour: -8),
            senderName: "Yuki Tanaka",
            senderAvatarEmoji: "🌺",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        Message(
            id: "msg-my-006",
            conversationId: conversationIdMaiYuki,
            senderId: userIdMai,
            content: "No problem! I have a little trolley we can use. Also, I made pho last night and thought of you",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [MessageReaction(emoji: "😍", count: 1, hasReacted: false)],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -3, hour: -6),
            senderName: "Mai Nguyen",
            senderAvatarEmoji: "🌿",
            isCurrentUser: true,
            sharedPostPreview: nil
        ),
        Message(
            id: "msg-my-007",
            conversationId: conversationIdMaiYuki,
            senderId: userIdYuki,
            content: "Pho and matcha — we should collab on a Vietnamese-Japanese broth event!",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [MessageReaction(emoji: "🔥", count: 1, hasReacted: true)],
            replyTo: ReplyReference(messageId: "msg-my-006", senderName: "Mai Nguyen", previewText: "No problem! I have a little trolley..."),
            status: .read,
            createdAt: cal(.day, -2, hour: -10),
            senderName: "Yuki Tanaka",
            senderAvatarEmoji: "🌺",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        Message(
            id: "msg-my-008",
            conversationId: conversationIdMaiYuki,
            senderId: userIdMai,
            content: "Yes!! Pho vs ramen night. People would lose their minds. Let's plan it after exams?",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -2, hour: -8),
            senderName: "Mai Nguyen",
            senderAvatarEmoji: "🌿",
            isCurrentUser: true,
            sharedPostPreview: nil
        ),
        Message(
            id: "msg-my-009",
            conversationId: conversationIdMaiYuki,
            senderId: userIdYuki,
            content: "Perfect timing. I will book the kitchen at Union House. Also, are you going to the pho cooking class this Saturday?",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.hour, -4),
            senderName: "Yuki Tanaka",
            senderAvatarEmoji: "🌺",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        Message(
            id: "msg-my-010",
            conversationId: conversationIdMaiYuki,
            senderId: userIdYuki,
            content: "See you there! I will bring the wagashi",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .delivered,
            createdAt: cal(.hour, -2),
            senderName: "Yuki Tanaka",
            senderAvatarEmoji: "🌺",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
    ]

    // MARK: - Conversation 2: Pho Cooking Class Group (15 messages)

    static let phoGroupMessages: [Message] = [
        // System: group created
        Message(
            id: "msg-pg-001",
            conversationId: conversationIdPhoGroup,
            senderId: hostLinhTran.id,
            content: "Linh Tran created this group",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .system,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -5, hour: -10),
            senderName: "Linh Tran",
            senderAvatarEmoji: "🌸",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // Linh welcome (pinned feel)
        Message(
            id: "msg-pg-002",
            conversationId: conversationIdPhoGroup,
            senderId: hostLinhTran.id,
            content: "Welcome everyone! Bring an apron if you have one. We will have all ingredients ready but feel free to bring your own chopsticks!",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [MessageReaction(emoji: "👍", count: 5, hasReacted: true)],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -5, hour: -9),
            senderName: "Linh Tran",
            senderAvatarEmoji: "🌸",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // Jin asks
        Message(
            id: "msg-pg-003",
            conversationId: conversationIdPhoGroup,
            senderId: userIdJin,
            content: "Can't wait! Should I bring anything?",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -5, hour: -8),
            senderName: "Jin Park",
            senderAvatarEmoji: "⭐",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // Linh replies to Jin
        Message(
            id: "msg-pg-004",
            conversationId: conversationIdPhoGroup,
            senderId: hostLinhTran.id,
            content: "Just bring yourself!",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: ReplyReference(messageId: "msg-pg-003", senderName: "Jin Park", previewText: "Can't wait! Should I bring anything?"),
            status: .read,
            createdAt: cal(.day, -5, hour: -7),
            senderName: "Linh Tran",
            senderAvatarEmoji: "🌸",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // System: Mai joined
        Message(
            id: "msg-pg-005",
            conversationId: conversationIdPhoGroup,
            senderId: userIdMai,
            content: "Mai Nguyen joined",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .system,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -4, hour: -10),
            senderName: "Mai Nguyen",
            senderAvatarEmoji: "🌿",
            isCurrentUser: true,
            sharedPostPreview: nil
        ),
        // Mai
        Message(
            id: "msg-pg-006",
            conversationId: conversationIdPhoGroup,
            senderId: userIdMai,
            content: "My mum makes the best pho, I have high standards 😄",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [MessageReaction(emoji: "😂", count: 4, hasReacted: false)],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -4, hour: -9),
            senderName: "Mai Nguyen",
            senderAvatarEmoji: "🌿",
            isCurrentUser: true,
            sharedPostPreview: nil
        ),
        // Priya
        Message(
            id: "msg-pg-007",
            conversationId: conversationIdPhoGroup,
            senderId: userIdPriya,
            content: "Is it beginner-friendly? I have never made soup from scratch before",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -4, hour: -6),
            senderName: "Priya Sharma",
            senderAvatarEmoji: "🔥",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // Amira
        Message(
            id: "msg-pg-008",
            conversationId: conversationIdPhoGroup,
            senderId: userIdAmira,
            content: "Is the broth halal? Just want to check before I come",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -3, hour: -10),
            senderName: "Amira Hassan",
            senderAvatarEmoji: "🌙",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // Linh replies to Amira
        Message(
            id: "msg-pg-009",
            conversationId: conversationIdPhoGroup,
            senderId: hostLinhTran.id,
            content: "Yes! Both chicken and beef options, halal-certified. I sourced the meat from the halal butcher on Sydney Road.",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [MessageReaction(emoji: "🎉", count: 3, hasReacted: true)],
            replyTo: ReplyReference(messageId: "msg-pg-008", senderName: "Amira Hassan", previewText: "Is the broth halal?"),
            status: .read,
            createdAt: cal(.day, -3, hour: -9),
            senderName: "Linh Tran",
            senderAvatarEmoji: "🌸",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // Carlos
        Message(
            id: "msg-pg-010",
            conversationId: conversationIdPhoGroup,
            senderId: userIdCarlos,
            content: "Count me in for seconds. And thirds.",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [MessageReaction(emoji: "😂", count: 2, hasReacted: false)],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -3, hour: -5),
            senderName: "Carlos Mendez",
            senderAvatarEmoji: "🍊",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // Mai tip
        Message(
            id: "msg-pg-011",
            conversationId: conversationIdPhoGroup,
            senderId: userIdMai,
            content: "Pro tip: star anise and cinnamon sticks are the secret. Toast them in a dry pan first!",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [MessageReaction(emoji: "👍", count: 3, hasReacted: false)],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -2, hour: -8),
            senderName: "Mai Nguyen",
            senderAvatarEmoji: "🌿",
            isCurrentUser: true,
            sharedPostPreview: nil
        ),
        // System: event reminder
        Message(
            id: "msg-pg-012",
            conversationId: conversationIdPhoGroup,
            senderId: hostLinhTran.id,
            content: "Event starts in 2 days",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .system,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -2, hour: -4),
            senderName: "System",
            senderAvatarEmoji: "🔔",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // Yuki
        Message(
            id: "msg-pg-013",
            conversationId: conversationIdPhoGroup,
            senderId: userIdYuki,
            content: "Different from ramen but same love for broth. Cannot wait to compare techniques!",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .read,
            createdAt: cal(.day, -1, hour: -6),
            senderName: "Yuki Tanaka",
            senderAvatarEmoji: "🌺",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // Linh final
        Message(
            id: "msg-pg-014",
            conversationId: conversationIdPhoGroup,
            senderId: hostLinhTran.id,
            content: "See everyone Saturday at 11am! Kitchen is Level 2, Union House. Look for the sign that says Pho Party.",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [MessageReaction(emoji: "🎉", count: 5, hasReacted: true), MessageReaction(emoji: "🍜", count: 3, hasReacted: true)],
            replyTo: nil,
            status: .read,
            createdAt: cal(.hour, -4),
            senderName: "Linh Tran",
            senderAvatarEmoji: "🌸",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
        // Priya excited
        Message(
            id: "msg-pg-015",
            conversationId: conversationIdPhoGroup,
            senderId: userIdPriya,
            content: "So excited! See you all there",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .delivered,
            createdAt: cal(.hour, -3),
            senderName: "Priya Sharma",
            senderAvatarEmoji: "🔥",
            isCurrentUser: false,
            sharedPostPreview: nil
        ),
    ]

    // MARK: - Conversation 3: Mai -> Carlos (1 message, not mutual)

    static let maiCarlosMessages: [Message] = [
        Message(
            id: "msg-mc-001",
            conversationId: conversationIdMaiCarlos,
            senderId: userIdMai,
            content: "Hey! Your salsa class looked amazing, I'd love to join next time",
            imageURL: nil,
            sharedPostId: nil,
            messageType: .text,
            reactions: [],
            replyTo: nil,
            status: .sent,
            createdAt: cal(.day, -1),
            senderName: "Mai Nguyen",
            senderAvatarEmoji: "🌿",
            isCurrentUser: true,
            sharedPostPreview: nil
        ),
    ]

    // MARK: - Private Helpers

    private static func cal(_ component: Calendar.Component, _ value: Int, hour extra: Int = 0) -> Date {
        let base = Calendar.current.date(byAdding: component, value: value, to: Date())!
        if extra == 0 { return base }
        return Calendar.current.date(byAdding: .hour, value: extra, to: base)!
    }
}
