import Foundation

// MARK: - Users
extension SampleData {

    // Stable UUIDs for cross-referencing
    static let userIdMai      = "u-00000001-mai-nguyen"
    static let userIdJin      = "u-00000002-jin-park"
    static let userIdPriya    = "u-00000003-priya-sharma"
    static let userIdAmira    = "u-00000004-amira-hassan"
    static let userIdCarlos   = "u-00000005-carlos-mendez"
    static let userIdYuki     = "u-00000006-yuki-tanaka"
    static let userIdAbel     = "u-00000007-abel-tesfaye"
    static let userIdMaria    = "u-00000008-maria-santos"
    static let userIdWei      = "u-00000009-wei-chen"
    static let userIdSade     = "u-00000010-sade-okafor"

    static let users: [User] = [
        User(
            id: userIdMai,
            email: "mnguyen@student.unimelb.edu.au",
            username: "mai.nguyen",
            displayName: "Mai Nguyen",
            avatarURL: nil,
            defaultAvatarId: 1,
            bio: "Vietnamese-Australian foodie who believes pho heals everything. Love hiking, cooking, and discovering hidden cafes around Melbourne.",
            city: "Melbourne",
            school: "University of Melbourne",
            appLanguage: "en",
            privacyProfile: .publicProfile,
            privacyDM: .everyone,
            notificationsEnabled: true,
            followerCount: 34,
            followingCount: 28,
            mutualCount: 22,
            gatheringsAttended: 12,
            gatheringsHosted: 3,
            postCount: 15,
            createdAt: cal(.day, -85),
            lastActiveAt: cal(.minute, -12)
        ),
        User(
            id: userIdJin,
            email: "jpark42@student.monash.edu",
            username: "jin.park",
            displayName: "Jin Park",
            avatarURL: nil,
            defaultAvatarId: 2,
            bio: "K-drama addict and aspiring chef. If I'm not watching K-pop dance practices I'm perfecting my bibimbap recipe.",
            city: "Melbourne",
            school: "Monash University",
            appLanguage: "ko",
            privacyProfile: .publicProfile,
            privacyDM: .mutualOnly,
            notificationsEnabled: true,
            followerCount: 45,
            followingCount: 38,
            mutualCount: 30,
            gatheringsAttended: 9,
            gatheringsHosted: 4,
            postCount: 18,
            createdAt: cal(.day, -72),
            lastActiveAt: cal(.minute, -45)
        ),
        User(
            id: userIdPriya,
            email: "psharma@student.rmit.edu.au",
            username: "priya.sharma",
            displayName: "Priya Sharma",
            avatarURL: nil,
            defaultAvatarId: 3,
            bio: "Colour, chaos, and chai. I organise cultural events on campus and dream about opening a fusion restaurant someday.",
            city: "Melbourne",
            school: "RMIT University",
            appLanguage: "en",
            privacyProfile: .publicProfile,
            privacyDM: .everyone,
            notificationsEnabled: true,
            followerCount: 50,
            followingCount: 42,
            mutualCount: 35,
            gatheringsAttended: 15,
            gatheringsHosted: 5,
            postCount: 20,
            createdAt: cal(.day, -90),
            lastActiveAt: cal(.hour, -1)
        ),
        User(
            id: userIdAmira,
            email: "ahassan@student.deakin.edu.au",
            username: "amira.hassan",
            displayName: "Amira Hassan",
            avatarURL: nil,
            defaultAvatarId: 4,
            bio: "Exploring Melbourne one coffee at a time. Arabic calligraphy artist and languages nerd. Trilingual and counting.",
            city: "Melbourne",
            school: "Deakin University",
            appLanguage: "en",
            privacyProfile: .schoolOnly,
            privacyDM: .mutualOnly,
            notificationsEnabled: true,
            followerCount: 18,
            followingCount: 22,
            mutualCount: 15,
            gatheringsAttended: 6,
            gatheringsHosted: 2,
            postCount: 8,
            createdAt: cal(.day, -60),
            lastActiveAt: cal(.hour, -3)
        ),
        User(
            id: userIdCarlos,
            email: "cmendez@students.latrobe.edu.au",
            username: "carlos.mendez",
            displayName: "Carlos Mendez",
            avatarURL: nil,
            defaultAvatarId: 5,
            bio: "Salsa dancer, coffee snob, and mechanical engineering student from Bogota. Always down for a good time and good food.",
            city: "Melbourne",
            school: "La Trobe University",
            appLanguage: "en",
            privacyProfile: .publicProfile,
            privacyDM: .everyone,
            notificationsEnabled: true,
            followerCount: 37,
            followingCount: 30,
            mutualCount: 24,
            gatheringsAttended: 11,
            gatheringsHosted: 3,
            postCount: 12,
            createdAt: cal(.day, -78),
            lastActiveAt: cal(.hour, -2)
        ),
        User(
            id: userIdYuki,
            email: "ytanaka@student.unimelb.edu.au",
            username: "yuki.tanaka",
            displayName: "Yuki Tanaka",
            avatarURL: nil,
            defaultAvatarId: 6,
            bio: "Tea ceremony enthusiast and botanical garden regular. Studying environmental science and finding beauty in small moments.",
            city: "Melbourne",
            school: "University of Melbourne",
            appLanguage: "en",
            privacyProfile: .publicProfile,
            privacyDM: .mutualOnly,
            notificationsEnabled: true,
            followerCount: 29,
            followingCount: 25,
            mutualCount: 19,
            gatheringsAttended: 8,
            gatheringsHosted: 3,
            postCount: 14,
            createdAt: cal(.day, -65),
            lastActiveAt: cal(.hour, -5)
        ),
        User(
            id: userIdAbel,
            email: "atesfaye@student.monash.edu",
            username: "abel.tesfaye",
            displayName: "Abel Tesfaye",
            avatarURL: nil,
            defaultAvatarId: 7,
            bio: "Ethiopian food ambassador. Music production hobbyist and med student who cooks injera to de-stress.",
            city: "Melbourne",
            school: "Monash University",
            appLanguage: "en",
            privacyProfile: .publicProfile,
            privacyDM: .everyone,
            notificationsEnabled: true,
            followerCount: 22,
            followingCount: 19,
            mutualCount: 14,
            gatheringsAttended: 7,
            gatheringsHosted: 2,
            postCount: 10,
            createdAt: cal(.day, -55),
            lastActiveAt: cal(.hour, -8)
        ),
        User(
            id: userIdMaria,
            email: "msantos@student.rmit.edu.au",
            username: "maria.santos",
            displayName: "Maria Santos",
            avatarURL: nil,
            defaultAvatarId: 8,
            bio: "Proud Filipina. Campus food tour guide, karaoke queen, and nursing student. I know every cheap eat within 5km of RMIT.",
            city: "Melbourne",
            school: "RMIT University",
            appLanguage: "en",
            privacyProfile: .publicProfile,
            privacyDM: .everyone,
            notificationsEnabled: true,
            followerCount: 41,
            followingCount: 35,
            mutualCount: 27,
            gatheringsAttended: 13,
            gatheringsHosted: 4,
            postCount: 17,
            createdAt: cal(.day, -80),
            lastActiveAt: cal(.minute, -30)
        ),
        User(
            id: userIdWei,
            email: "wchen@student.unimelb.edu.au",
            username: "wei.chen",
            displayName: "Wei Chen",
            avatarURL: nil,
            defaultAvatarId: 9,
            bio: "Comp-sci student and study group organiser. Mandarin tutor on the side. Big fan of hotpot and board game nights.",
            city: "Melbourne",
            school: "University of Melbourne",
            appLanguage: "zh",
            privacyProfile: .schoolOnly,
            privacyDM: .mutualOnly,
            notificationsEnabled: true,
            followerCount: 15,
            followingCount: 20,
            mutualCount: 12,
            gatheringsAttended: 5,
            gatheringsHosted: 2,
            postCount: 7,
            createdAt: cal(.day, -45),
            lastActiveAt: cal(.hour, -6)
        ),
        User(
            id: userIdSade,
            email: "sokafor@student.deakin.edu.au",
            username: "sade.okafor",
            displayName: "Sade Okafor",
            avatarURL: nil,
            defaultAvatarId: 10,
            bio: "Nigerian jollof supremacist. Law student, natural hair advocate, and weekend market explorer. My jollof rice is undefeated.",
            city: "Melbourne",
            school: "Deakin University",
            appLanguage: "en",
            privacyProfile: .publicProfile,
            privacyDM: .everyone,
            notificationsEnabled: true,
            followerCount: 33,
            followingCount: 27,
            mutualCount: 20,
            gatheringsAttended: 10,
            gatheringsHosted: 3,
            postCount: 13,
            createdAt: cal(.day, -70),
            lastActiveAt: cal(.hour, -4)
        ),
    ]

    // Extra host not in main user list (gathering host)
    static let hostLinhTran = User(
        id: "u-00000011-linh-tran",
        email: "ltran@student.unimelb.edu.au",
        username: "linh.tran",
        displayName: "Linh Tran",
        avatarURL: nil,
        defaultAvatarId: 11,
        bio: "Professional pho maker and Vietnamese culture enthusiast. Running cooking classes since 2024!",
        city: "Melbourne",
        school: "University of Melbourne",
        appLanguage: "en",
        privacyProfile: .publicProfile,
        privacyDM: .everyone,
        notificationsEnabled: true,
        followerCount: 48,
        followingCount: 32,
        mutualCount: 25,
        gatheringsAttended: 14,
        gatheringsHosted: 5,
        postCount: 16,
        createdAt: cal(.day, -88),
        lastActiveAt: cal(.hour, -1)
    )

    static var allUsers: [User] { users + [hostLinhTran] }

    // MARK: - Cultural Tag Presets

    static let culturalBackgrounds: [String] = [
        "Vietnamese", "Korean", "Chinese", "Indian", "Japanese",
        "Filipino", "Thai", "Indonesian", "Middle Eastern", "African",
        "Latin American", "European", "Pacific Islander", "Australian",
        "Ethiopian", "Nigerian", "Brazilian", "Mexican", "Pakistani", "Ghanaian"
    ]

    static let languages: [String] = [
        "English", "Mandarin", "Cantonese", "Vietnamese", "Korean",
        "Japanese", "Hindi", "Arabic", "Spanish", "French",
        "Portuguese", "Indonesian", "Thai", "Tagalog", "Twi"
    ]

    static let interestVibes: [String] = [
        "Food", "Study", "Music", "Sports", "Faith",
        "Art", "Dancing", "Low-key hangout", "Cooking", "Gaming",
        "Movies", "Hiking", "Photography", "Language Exchange",
        "Festivals", "Food Tours", "Meditation"
    ]

    static let cities: [String] = [
        "Melbourne", "Sydney", "Brisbane", "Perth", "Adelaide"
    ]

    static let schoolsByCity: [String: [String]] = [
        "Melbourne": [
            "University of Melbourne",
            "Monash University",
            "RMIT University",
            "Deakin University",
            "La Trobe University"
        ],
        "Sydney": [
            "University of Sydney",
            "UNSW Sydney",
            "University of Technology Sydney",
            "Macquarie University",
            "Western Sydney University"
        ],
        "Brisbane": [
            "University of Queensland",
            "Queensland University of Technology",
            "Griffith University",
            "Bond University",
            "James Cook University"
        ],
        "Perth": [
            "University of Western Australia",
            "Curtin University",
            "Murdoch University",
            "Edith Cowan University",
            "University of Notre Dame Australia"
        ],
        "Adelaide": [
            "University of Adelaide",
            "Flinders University",
            "University of South Australia",
            "Torrens University",
            "Carnegie Mellon University Australia"
        ],
    ]

    // Avatar emojis indexed by user position
    static let userAvatarEmojis: [String: String] = [
        userIdMai:    "🌿",
        userIdJin:    "⭐",
        userIdPriya:  "🔥",
        userIdAmira:  "🌙",
        userIdCarlos: "🍊",
        userIdYuki:   "🌺",
        userIdAbel:   "💜",
        userIdMaria:  "🦋",
        userIdWei:    "🌊",
        userIdSade:   "✨",
        hostLinhTran.id: "🌸",
    ]

    static func avatarEmoji(for userId: String) -> String {
        userAvatarEmojis[userId] ?? "👤"
    }

    // MARK: - Date Helpers (private)

    private static func cal(_ component: Calendar.Component, _ value: Int) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: Date())!
    }
}
