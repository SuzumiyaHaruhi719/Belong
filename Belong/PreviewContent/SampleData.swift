import Foundation

// MARK: - Sample Data for Previews & Development
// All mock data lives here so preview providers and debug builds have realistic content.

enum SampleData {

    // MARK: Current user

    static let currentUser = User(
        id: "user-001",
        email: "mai.nguyen@unimelb.edu.au",
        username: "mai.nguyen",
        displayName: "Mai Nguyen",
        avatarURL: nil,
        avatarEmoji: "🌿",
        city: "Melbourne",
        school: "University of Melbourne",
        language: "English",
        culturalTags: CulturalTags(
            background: ["Vietnamese", "Australian"],
            languages: ["English", "Vietnamese", "Mandarin"],
            interests: ["Cooking", "Music", "Hiking"]
        ),
        stats: UserStats(attended: 8, hosted: 2, connections: 15)
    )

    // MARK: Gatherings

    static let gatherings: [Gathering] = [
        Gathering(
            id: "g-001",
            title: "Vietnamese Pho Cooking Class",
            description: "Learn to make authentic phở from scratch. We'll cover bone broth, fresh herbs, and assembly. All skill levels welcome — bring an appetite and curiosity!",
            imageURL: URL(string: "https://picsum.photos/seed/pho/400/250"),
            hostName: "Linh Tran",
            hostAvatarEmoji: "🌸",
            hostRating: 4.8,
            date: Date().addingTimeInterval(86400 * 2),
            location: "UniMelb Community Kitchen",
            attendeeCount: 8,
            maxAttendees: 12,
            attendeeAvatars: ["🌿", "🔥", "⭐", "🦋", "🌊"],
            culturalTags: ["Vietnamese", "Cooking"],
            isBookmarked: false,
            status: .upcoming
        ),
        Gathering(
            id: "g-002",
            title: "Korean Movie Night: Parasite",
            description: "Watch and discuss Korean cinema. Snacks provided! We'll explore themes of class and culture in modern Korean film.",
            imageURL: URL(string: "https://picsum.photos/seed/korean/400/250"),
            hostName: "Jin Park",
            hostAvatarEmoji: "⭐",
            hostRating: 4.6,
            date: Date().addingTimeInterval(86400 * 3),
            location: "Student Union Theatre",
            attendeeCount: 15,
            maxAttendees: 25,
            attendeeAvatars: ["🌸", "🍊", "💜", "🌺", "🌙"],
            culturalTags: ["Korean", "Film"],
            isBookmarked: true,
            status: .upcoming
        ),
        Gathering(
            id: "g-003",
            title: "Holi Festival Celebration",
            description: "Celebrate the festival of colors together! Wear white clothes you don't mind getting colorful. Colors, music, and Indian sweets provided.",
            imageURL: URL(string: "https://picsum.photos/seed/holi/400/250"),
            hostName: "Priya Sharma",
            hostAvatarEmoji: "🔥",
            hostRating: 4.9,
            date: Date().addingTimeInterval(86400 * 5),
            location: "Royal Park",
            attendeeCount: 30,
            maxAttendees: 50,
            attendeeAvatars: ["🌿", "🌸", "⭐", "🦋", "🌊"],
            culturalTags: ["Indian", "Festivals"],
            isBookmarked: false,
            status: .upcoming
        ),
        Gathering(
            id: "g-004",
            title: "Arabic Coffee & Conversation",
            description: "Enjoy traditional Arabic coffee while practicing language exchange. Beginner Arabic speakers especially welcome!",
            imageURL: URL(string: "https://picsum.photos/seed/coffee/400/250"),
            hostName: "Amira Hassan",
            hostAvatarEmoji: "🌙",
            hostRating: 4.7,
            date: Date().addingTimeInterval(86400 * 4),
            location: "Lygon St Café",
            attendeeCount: 5,
            maxAttendees: 8,
            attendeeAvatars: ["🌿", "🌸", "🔥"],
            culturalTags: ["Middle Eastern", "Language Exchange"],
            isBookmarked: false,
            status: .upcoming
        ),
        Gathering(
            id: "g-005",
            title: "Latin Dance Social",
            description: "Salsa, bachata, and merengue! No partner or experience needed. We start with a beginner lesson.",
            imageURL: URL(string: "https://picsum.photos/seed/dance/400/250"),
            hostName: "Carlos Mendez",
            hostAvatarEmoji: "🍊",
            hostRating: 4.5,
            date: Date().addingTimeInterval(86400 * 6),
            location: "Southbank Promenade",
            attendeeCount: 18,
            maxAttendees: 30,
            attendeeAvatars: ["⭐", "🦋", "🌺", "🌙", "💜"],
            culturalTags: ["Latin American", "Dance"],
            isBookmarked: true,
            status: .upcoming
        ),
        Gathering(
            id: "g-006",
            title: "Japanese Garden Walk & Tea",
            description: "A peaceful walk through the Japanese garden followed by a matcha tea ceremony introduction.",
            imageURL: URL(string: "https://picsum.photos/seed/garden/400/250"),
            hostName: "Yuki Tanaka",
            hostAvatarEmoji: "🌺",
            hostRating: 5.0,
            date: Date().addingTimeInterval(-86400 * 3),
            location: "Royal Botanic Gardens",
            attendeeCount: 10,
            maxAttendees: 10,
            attendeeAvatars: ["🌿", "🌸", "🔥", "⭐", "🦋"],
            culturalTags: ["Japanese", "Meditation"],
            isBookmarked: false,
            status: .past
        ),
        Gathering(
            id: "g-007",
            title: "Ethiopian Dinner & Stories",
            description: "Share injera and stories from the Ethiopian tradition. Communal dining — we eat from the same plate!",
            imageURL: URL(string: "https://picsum.photos/seed/ethiopian/400/250"),
            hostName: "Abel Tesfaye",
            hostAvatarEmoji: "💜",
            hostRating: 4.4,
            date: Date().addingTimeInterval(-86400 * 7),
            location: "Footscray Community Hall",
            attendeeCount: 12,
            maxAttendees: 15,
            attendeeAvatars: ["🌿", "🍊", "🌙", "🌺", "⭐"],
            culturalTags: ["African", "Food Tours"],
            isBookmarked: false,
            status: .past
        ),
        Gathering(
            id: "g-008",
            title: "Mixed Culture Potluck",
            description: "Bring a dish from your culture and share its story. The best way to connect is through food!",
            imageURL: URL(string: "https://picsum.photos/seed/potluck/400/250"),
            hostName: "Mai Nguyen",
            hostAvatarEmoji: "🌿",
            hostRating: 4.8,
            date: Date().addingTimeInterval(86400 * 10),
            location: "Carlton Gardens",
            attendeeCount: 7,
            maxAttendees: 20,
            attendeeAvatars: ["🌸", "🔥", "⭐", "🦋", "🍊"],
            culturalTags: ["Cooking", "Festivals"],
            isBookmarked: false,
            status: .upcoming
        ),
    ]

    static var upcomingGatherings: [Gathering] {
        gatherings.filter { $0.status == .upcoming }
    }

    static var pastGatherings: [Gathering] {
        gatherings.filter { $0.status == .past }
    }

    static var savedGatherings: [Gathering] {
        gatherings.filter { $0.isBookmarked }
    }

    static var topPick: Gathering { gatherings[0] }

    // MARK: - Messages (Group Chat)

    static let messages: [Message] = [
        Message(id: "m-01", senderName: "Linh Tran", senderAvatarEmoji: "🌸",
                text: "Welcome to the Pho Cooking Class group! I'm so excited to cook with everyone. Please bring an apron if you have one.",
                timestamp: Date().addingTimeInterval(-86400), isCurrentUser: false, isPinned: true),
        Message(id: "m-02", senderName: "Jin Park", senderAvatarEmoji: "⭐",
                text: "Can't wait! Should I bring anything else?",
                timestamp: Date().addingTimeInterval(-80000), isCurrentUser: false, isPinned: false,
                reactions: [MessageReaction(emoji: "👍", count: 2, hasReacted: false)]),
        Message(id: "m-03", senderName: "Linh Tran", senderAvatarEmoji: "🌸",
                text: "Nope, all ingredients are covered. Just bring yourself!",
                timestamp: Date().addingTimeInterval(-78000), isCurrentUser: false, isPinned: false,
                replyTo: ReplyReference(messageId: "m-02", senderName: "Jin Park", previewText: "Can't wait! Should I bring anything else?")),
        Message(id: "m-sys-01", senderName: "System", senderAvatarEmoji: "",
                text: "Mai Nguyen joined the group",
                timestamp: Date().addingTimeInterval(-75000), isCurrentUser: false, isPinned: false,
                messageType: .system),
        Message(id: "m-04", senderName: "Mai Nguyen", senderAvatarEmoji: "🌿",
                text: "This is going to be amazing! My mum makes the best pho so I have high standards",
                timestamp: Date().addingTimeInterval(-72000), isCurrentUser: true, isPinned: false,
                reactions: [MessageReaction(emoji: "😂", count: 3, hasReacted: false), MessageReaction(emoji: "❤️", count: 1, hasReacted: true)],
                status: .read),
        Message(id: "m-05", senderName: "Priya Sharma", senderAvatarEmoji: "🔥",
                text: "I've never made pho before. Is it beginner-friendly?",
                timestamp: Date().addingTimeInterval(-60000), isCurrentUser: false, isPinned: false),
        Message(id: "m-06", senderName: "Linh Tran", senderAvatarEmoji: "🌸",
                text: "Absolutely! We'll go step by step. The broth takes the longest but it's simple.",
                timestamp: Date().addingTimeInterval(-55000), isCurrentUser: false, isPinned: false,
                replyTo: ReplyReference(messageId: "m-05", senderName: "Priya Sharma", previewText: "I've never made pho before. Is it beginner-friendly?")),
        Message(id: "m-07", senderName: "Amira Hassan", senderAvatarEmoji: "🌙",
                text: "Is the broth halal? Just checking!",
                timestamp: Date().addingTimeInterval(-40000), isCurrentUser: false, isPinned: false),
        Message(id: "m-08", senderName: "Linh Tran", senderAvatarEmoji: "🌸",
                text: "Great question! We'll have both chicken and beef options, both halal-certified.",
                timestamp: Date().addingTimeInterval(-35000), isCurrentUser: false, isPinned: false,
                reactions: [MessageReaction(emoji: "🎉", count: 2, hasReacted: false), MessageReaction(emoji: "👏", count: 1, hasReacted: true)]),
        Message(id: "m-09", senderName: "Carlos Mendez", senderAvatarEmoji: "🍊",
                text: "Count me in for seconds already",
                timestamp: Date().addingTimeInterval(-20000), isCurrentUser: false, isPinned: false),
        Message(id: "m-10", senderName: "Mai Nguyen", senderAvatarEmoji: "🌿",
                text: "Pro tip: the secret is in the star anise and cinnamon sticks",
                timestamp: Date().addingTimeInterval(-10000), isCurrentUser: true, isPinned: false,
                status: .read),
        Message(id: "m-sys-02", senderName: "System", senderAvatarEmoji: "",
                text: "Event starts in 2 days",
                timestamp: Date().addingTimeInterval(-8000), isCurrentUser: false, isPinned: false,
                messageType: .system),
        Message(id: "m-11", senderName: "Yuki Tanaka", senderAvatarEmoji: "🌺",
                text: "Reminds me of ramen! Different but the same love for broth.",
                timestamp: Date().addingTimeInterval(-5000), isCurrentUser: false, isPinned: false),
        Message(id: "m-12", senderName: "Linh Tran", senderAvatarEmoji: "🌸",
                text: "See everyone Saturday at 11am! The kitchen is on Level 2.",
                timestamp: Date().addingTimeInterval(-1000), isCurrentUser: false, isPinned: false,
                reactions: [MessageReaction(emoji: "👍", count: 5, hasReacted: true)]),
    ]

    // MARK: Connections

    static let connections: [Connection] = [
        Connection(id: "c-01", name: "Linh Tran", avatarEmoji: "🌸", mutualEvents: 3),
        Connection(id: "c-02", name: "Jin Park", avatarEmoji: "⭐", mutualEvents: 2),
        Connection(id: "c-03", name: "Priya Sharma", avatarEmoji: "🔥", mutualEvents: 1),
        Connection(id: "c-04", name: "Amira Hassan", avatarEmoji: "🌙", mutualEvents: 2),
        Connection(id: "c-05", name: "Carlos Mendez", avatarEmoji: "🍊", mutualEvents: 1),
        Connection(id: "c-06", name: "Yuki Tanaka", avatarEmoji: "🌺", mutualEvents: 4),
    ]

    // MARK: Hosting Templates

    static let hostingTemplates: [HostingTemplate] = [
        HostingTemplate(id: "t-01", title: "Cooking Class", systemImage: "frying.pan",
                        description: "Share a recipe from your culture", defaultTags: ["Cooking"]),
        HostingTemplate(id: "t-02", title: "Movie Night", systemImage: "film",
                        description: "Screen a film and discuss", defaultTags: ["Film"]),
        HostingTemplate(id: "t-03", title: "Cultural Festival", systemImage: "party.popper",
                        description: "Celebrate a cultural event together", defaultTags: ["Festivals"]),
        HostingTemplate(id: "t-04", title: "Coffee Meetup", systemImage: "cup.and.saucer",
                        description: "Casual conversation over coffee", defaultTags: ["Language Exchange"]),
        HostingTemplate(id: "t-05", title: "Language Exchange", systemImage: "bubble.left.and.bubble.right",
                        description: "Practice a new language", defaultTags: ["Language Exchange"]),
        HostingTemplate(id: "t-06", title: "Nature Walk", systemImage: "leaf",
                        description: "Explore nature, share stories", defaultTags: ["Hiking"]),
    ]

    // MARK: - Browsing History

    static let browsingHistory: [BrowsingHistoryItem] = [
        BrowsingHistoryItem(id: "bh-01", gatheringId: "g-001", gatheringTitle: "Vietnamese Pho Cooking Class",
                            gatheringImageURL: URL(string: "https://picsum.photos/seed/pho/400/250"),
                            culturalTags: ["Vietnamese", "Cooking"],
                            viewedAt: Date().addingTimeInterval(-3600), hostName: "Linh Tran"),
        BrowsingHistoryItem(id: "bh-02", gatheringId: "g-003", gatheringTitle: "Holi Festival Celebration",
                            gatheringImageURL: URL(string: "https://picsum.photos/seed/holi/400/250"),
                            culturalTags: ["Indian", "Festivals"],
                            viewedAt: Date().addingTimeInterval(-7200), hostName: "Priya Sharma"),
        BrowsingHistoryItem(id: "bh-03", gatheringId: "g-005", gatheringTitle: "Latin Dance Social",
                            gatheringImageURL: URL(string: "https://picsum.photos/seed/dance/400/250"),
                            culturalTags: ["Latin American", "Dance"],
                            viewedAt: Date().addingTimeInterval(-14400), hostName: "Carlos Mendez"),
        BrowsingHistoryItem(id: "bh-04", gatheringId: "g-004", gatheringTitle: "Arabic Coffee & Conversation",
                            gatheringImageURL: URL(string: "https://picsum.photos/seed/coffee/400/250"),
                            culturalTags: ["Middle Eastern", "Language Exchange"],
                            viewedAt: Date().addingTimeInterval(-86400), hostName: "Amira Hassan"),
        BrowsingHistoryItem(id: "bh-05", gatheringId: "g-002", gatheringTitle: "Korean Movie Night: Parasite",
                            gatheringImageURL: URL(string: "https://picsum.photos/seed/korean/400/250"),
                            culturalTags: ["Korean", "Film"],
                            viewedAt: Date().addingTimeInterval(-86400 * 2), hostName: "Jin Park"),
    ]

    // MARK: - Join History

    static let joinHistory: [EventJoinHistoryItem] = [
        // Upcoming / confirmed
        EventJoinHistoryItem(id: "jh-01", gatheringId: "g-001", gatheringTitle: "Vietnamese Pho Cooking Class",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/pho/400/250"),
                             hostName: "Linh Tran", hostAvatarEmoji: "🌸",
                             date: Date().addingTimeInterval(86400 * 2), location: "UniMelb Community Kitchen",
                             attendeeCount: 8, culturalTags: ["Vietnamese", "Cooking"],
                             ratingGiven: nil, feedbackEmoji: nil, status: .confirmed),
        EventJoinHistoryItem(id: "jh-02", gatheringId: "g-002", gatheringTitle: "Korean Movie Night: Parasite",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/korean/400/250"),
                             hostName: "Jin Park", hostAvatarEmoji: "⭐",
                             date: Date().addingTimeInterval(86400 * 3), location: "Student Union Theatre",
                             attendeeCount: 15, culturalTags: ["Korean", "Film"],
                             ratingGiven: nil, feedbackEmoji: nil, status: .confirmed),
        // Past / attended
        EventJoinHistoryItem(id: "jh-03", gatheringId: "g-006", gatheringTitle: "Japanese Garden Walk & Tea",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/garden/400/250"),
                             hostName: "Yuki Tanaka", hostAvatarEmoji: "🌺",
                             date: Date().addingTimeInterval(-86400 * 3), location: "Royal Botanic Gardens",
                             attendeeCount: 10, culturalTags: ["Japanese", "Meditation"],
                             ratingGiven: 5, feedbackEmoji: "🎉", status: .attended),
        EventJoinHistoryItem(id: "jh-04", gatheringId: "g-007", gatheringTitle: "Ethiopian Dinner & Stories",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/ethiopian/400/250"),
                             hostName: "Abel Tesfaye", hostAvatarEmoji: "💜",
                             date: Date().addingTimeInterval(-86400 * 7), location: "Footscray Community Hall",
                             attendeeCount: 12, culturalTags: ["African", "Food Tours"],
                             ratingGiven: 4, feedbackEmoji: "😊", status: .attended),
        EventJoinHistoryItem(id: "jh-05", gatheringId: "g-past-01", gatheringTitle: "Mandarin Conversation Circle",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/mandarin/400/250"),
                             hostName: "Wei Chen", hostAvatarEmoji: "🌊",
                             date: Date().addingTimeInterval(-86400 * 14), location: "State Library of Victoria",
                             attendeeCount: 6, culturalTags: ["Chinese", "Language Exchange"],
                             ratingGiven: nil, feedbackEmoji: nil, status: .attended),
        EventJoinHistoryItem(id: "jh-06", gatheringId: "g-past-02", gatheringTitle: "Diwali Lantern Making",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/diwali/400/250"),
                             hostName: "Priya Sharma", hostAvatarEmoji: "🔥",
                             date: Date().addingTimeInterval(-86400 * 21), location: "Federation Square",
                             attendeeCount: 25, culturalTags: ["Indian", "Art"],
                             ratingGiven: 5, feedbackEmoji: "🤝", status: .attended),
        EventJoinHistoryItem(id: "jh-07", gatheringId: "g-past-03", gatheringTitle: "Vietnamese Tet Celebration",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/tet/400/250"),
                             hostName: "Thanh Le", hostAvatarEmoji: "🌸",
                             date: Date().addingTimeInterval(-86400 * 35), location: "Footscray Market",
                             attendeeCount: 40, culturalTags: ["Vietnamese", "Festivals"],
                             ratingGiven: 5, feedbackEmoji: "🎉", status: .attended),
        // Cancelled
        EventJoinHistoryItem(id: "jh-08", gatheringId: "g-past-04", gatheringTitle: "Filipino Karaoke Night",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/karaoke/400/250"),
                             hostName: "Maria Santos", hostAvatarEmoji: "🦋",
                             date: Date().addingTimeInterval(-86400 * 10), location: "Box Hill RSL",
                             attendeeCount: 0, culturalTags: ["Filipino", "Music"],
                             ratingGiven: nil, feedbackEmoji: nil, status: .cancelled),
    ]

    // MARK: - Host History

    static let hostHistory: [EventHostHistoryItem] = [
        EventHostHistoryItem(id: "hh-01", gatheringId: "g-008", gatheringTitle: "Mixed Culture Potluck",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/potluck/400/250"),
                             date: Date().addingTimeInterval(86400 * 10), location: "Carlton Gardens",
                             attendeeCount: 7, maxAttendees: 20, culturalTags: ["Cooking", "Festivals"],
                             averageRating: nil, status: .published),
        EventHostHistoryItem(id: "hh-02", gatheringId: "g-past-hosted-01", gatheringTitle: "Vietnamese Spring Roll Workshop",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/springroll/400/250"),
                             date: Date().addingTimeInterval(-86400 * 14), location: "UniMelb Community Kitchen",
                             attendeeCount: 10, maxAttendees: 12, culturalTags: ["Vietnamese", "Cooking"],
                             averageRating: 4.7, status: .completed),
        EventHostHistoryItem(id: "hh-03", gatheringId: "g-past-hosted-02", gatheringTitle: "Banh Mi & Stories",
                             gatheringImageURL: URL(string: "https://picsum.photos/seed/banhmi/400/250"),
                             date: Date().addingTimeInterval(-86400 * 28), location: "Victoria Market",
                             attendeeCount: 15, maxAttendees: 15, culturalTags: ["Vietnamese", "Food Tours"],
                             averageRating: 4.9, status: .completed),
    ]

    // MARK: Reference Data

    static let defaultAvatars = ["🌿", "🌸", "🌊", "🔥", "⭐", "🦋", "🍊", "🌙", "💜", "🌺"]

    static let languages: [(code: String, name: String, nativeName: String)] = [
        ("en", "English", "English"),
        ("vi", "Vietnamese", "Tiếng Việt"),
        ("zh", "Mandarin", "中文"),
        ("ko", "Korean", "한국어"),
        ("ja", "Japanese", "日本語"),
        ("hi", "Hindi", "हिन्दी"),
        ("ar", "Arabic", "العربية"),
        ("es", "Spanish", "Español"),
        ("fr", "French", "Français"),
        ("pt", "Portuguese", "Português"),
        ("id", "Indonesian", "Bahasa Indonesia"),
        ("th", "Thai", "ภาษาไทย"),
        ("tl", "Tagalog", "Tagalog"),
    ]

    static let cities = [
        "Melbourne", "Sydney", "Brisbane", "Perth",
        "Adelaide", "Canberra", "Hobart", "Darwin", "Gold Coast"
    ]

    static let schoolsByCity: [String: [String]] = [
        "Melbourne": ["University of Melbourne", "Monash University", "RMIT University", "Deakin University", "La Trobe University"],
        "Sydney": ["University of Sydney", "UNSW", "UTS", "Macquarie University"],
        "Brisbane": ["University of Queensland", "QUT", "Griffith University"],
        "Perth": ["University of Western Australia", "Curtin University", "Murdoch University"],
        "Adelaide": ["University of Adelaide", "Flinders University", "UniSA"],
        "Canberra": ["Australian National University", "University of Canberra"],
        "Hobart": ["University of Tasmania"],
        "Darwin": ["Charles Darwin University"],
        "Gold Coast": ["Bond University", "Griffith University Gold Coast"],
    ]

    static let culturalTagOptions = CulturalTagOptions(
        background: ["Vietnamese", "Chinese", "Indian", "Korean", "Japanese", "Filipino",
                      "Thai", "Indonesian", "Malaysian", "Middle Eastern", "African",
                      "Latin American", "European", "Pacific Islander", "Australian"],
        languages: ["English", "Mandarin", "Vietnamese", "Korean", "Japanese", "Hindi",
                     "Arabic", "Spanish", "French", "Indonesian", "Thai", "Tagalog",
                     "Cantonese", "Portuguese"],
        interests: ["Cooking", "Music", "Dance", "Art", "Film", "Language Exchange",
                     "Hiking", "Sports", "Gaming", "Reading", "Photography",
                     "Meditation", "Festivals", "Food Tours"]
    )
}

// MARK: - Cultural Tag Options (for picker screens)

struct CulturalTagOptions {
    let background: [String]
    let languages: [String]
    let interests: [String]
}
