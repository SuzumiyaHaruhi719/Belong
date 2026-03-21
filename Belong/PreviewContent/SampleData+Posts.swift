import Foundation

// MARK: - Posts
extension SampleData {

    // Stable post IDs
    static let postIdPhoRecipe     = "p-00000001-pho-recipe"
    static let postIdKdrama        = "p-00000002-kdrama-review"
    static let postIdHoliPhotos    = "p-00000003-holi-photos"
    static let postIdSalsaRecap    = "p-00000004-salsa-recap"
    static let postIdCalligraphy   = "p-00000005-calligraphy"
    static let postIdMatchaGuide   = "p-00000006-matcha-guide"
    static let postIdInjera        = "p-00000007-injera-recipe"
    static let postIdFoodTour      = "p-00000008-food-tour"
    static let postIdStudyTips     = "p-00000009-study-tips"
    static let postIdJollofDebate  = "p-00000010-jollof-debate"
    static let postIdHiking        = "p-00000011-hiking"
    static let postIdStreetFood    = "p-00000012-street-food"
    static let postIdRangoli       = "p-00000013-rangoli"
    static let postIdStudyGroup    = "p-00000014-study-group"
    static let postIdCherryBlossom = "p-00000015-cherry-blossom"

    static let posts: [Post] = [
        // 1. Mai's pho recipe story
        Post(
            id: postIdPhoRecipe,
            authorId: userIdMai,
            content: "Finally nailed my mum's pho recipe after three attempts! The secret really is in the charred onion and ginger. Eight hours of simmering but so worth it. Who wants the recipe?",
            images: makeImages(postId: postIdPhoRecipe, seeds: ["pho-broth", "pho-toppings", "pho-bowl"], widths: [400, 400, 400], heights: [300, 250, 300]),
            tags: ["KoreanBBQ", "FoodieLife"],
            visibility: .publicPost,
            linkedGatheringId: gatheringIdPho,
            city: "Melbourne",
            school: "University of Melbourne",
            likeCount: 42,
            commentCount: 8,
            saveCount: 12,
            isLiked: false,
            isSaved: false,
            createdAt: cal(.day, -1),
            authorName: "Mai Nguyen",
            authorUsername: "mai.nguyen",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🌿",
            linkedGatheringTitle: "Vietnamese Pho Cooking Class"
        ),
        // 2. Jin's K-drama review
        Post(
            id: postIdKdrama,
            authorId: userIdJin,
            content: "Just finished rewatching Crash Landing on You for the third time and I still cry at the ending. Planning a K-drama marathon night if anyone wants to join. Snacks provided!",
            images: makeImages(postId: postIdKdrama, seeds: ["kdrama-snacks", "kdrama-setup"], widths: [400, 400], heights: [250, 300]),
            tags: ["KDrama", "MovieNight"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "Monash University",
            likeCount: 28,
            commentCount: 5,
            saveCount: 4,
            isLiked: true,
            isSaved: false,
            createdAt: cal(.day, -2),
            authorName: "Jin Park",
            authorUsername: "jin.park",
            authorAvatarURL: nil,
            authorAvatarEmoji: "⭐",
            linkedGatheringTitle: nil
        ),
        // 3. Priya's Holi celebration photos
        Post(
            id: postIdHoliPhotos,
            authorId: userIdPriya,
            content: "Last year's Holi was absolutely magical! Colours everywhere, amazing music, and the best samosas I have ever made. This year is going to be even bigger. Mark your calendars and wear white!",
            images: makeImages(postId: postIdHoliPhotos, seeds: ["holi-colour1", "holi-crowd", "holi-food", "holi-dance"], widths: [400, 400, 300, 400], heights: [300, 250, 300, 250]),
            tags: ["Holi", "ColorFestival", "Indian"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "RMIT University",
            likeCount: 89,
            commentCount: 15,
            saveCount: 22,
            isLiked: true,
            isSaved: true,
            createdAt: cal(.day, -3),
            authorName: "Priya Sharma",
            authorUsername: "priya.sharma",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🔥",
            linkedGatheringTitle: nil
        ),
        // 4. Carlos's salsa night recap
        Post(
            id: postIdSalsaRecap,
            authorId: userIdCarlos,
            content: "What a night! Thirty people showed up for salsa and we danced until security kicked us out. Already planning the next one. Thank you to everyone who came!",
            images: makeImages(postId: postIdSalsaRecap, seeds: ["salsa-crowd", "salsa-dance"], widths: [400, 400], heights: [250, 300]),
            tags: ["SalsaNight", "LatinDance"],
            visibility: .publicPost,
            linkedGatheringId: gatheringIdLatinDance,
            city: "Melbourne",
            school: "La Trobe University",
            likeCount: 35,
            commentCount: 7,
            saveCount: 5,
            isLiked: false,
            isSaved: false,
            createdAt: cal(.day, -4),
            authorName: "Carlos Mendez",
            authorUsername: "carlos.mendez",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🍊",
            linkedGatheringTitle: "Latin Dance Social"
        ),
        // 5. Amira's Arabic calligraphy
        Post(
            id: postIdCalligraphy,
            authorId: userIdAmira,
            content: "Spent the afternoon practising my Naskh script. There is something so meditative about Arabic calligraphy. Each letter flows into the next like a river. Would anyone be interested in a workshop?",
            images: makeImages(postId: postIdCalligraphy, seeds: ["calligraphy-art"], widths: [400], heights: [400]),
            tags: ["ArabicArt", "Calligraphy"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "Deakin University",
            likeCount: 18,
            commentCount: 3,
            saveCount: 6,
            isLiked: false,
            isSaved: false,
            createdAt: cal(.day, -5),
            authorName: "Amira Hassan",
            authorUsername: "amira.hassan",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🌙",
            linkedGatheringTitle: nil
        ),
        // 6. Yuki's matcha guide
        Post(
            id: postIdMatchaGuide,
            authorId: userIdYuki,
            content: "Your complete guide to making matcha the traditional way. Temperature matters more than you think! I have been practising the tea ceremony for five years and these are my top tips for beginners.",
            images: makeImages(postId: postIdMatchaGuide, seeds: ["matcha-whisk", "matcha-bowl", "matcha-set"], widths: [400, 300, 400], heights: [300, 300, 250]),
            tags: ["Matcha", "JapaneseTeaCeremony"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "University of Melbourne",
            likeCount: 55,
            commentCount: 12,
            saveCount: 18,
            isLiked: true,
            isSaved: true,
            createdAt: cal(.day, -6),
            authorName: "Yuki Tanaka",
            authorUsername: "yuki.tanaka",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🌺",
            linkedGatheringTitle: nil
        ),
        // 7. Abel's injera recipe
        Post(
            id: postIdInjera,
            authorId: userIdAbel,
            content: "Made injera from scratch today using teff flour my family sent from Addis. The fermentation takes three days but the tangy, spongy result is unbeatable. Paired it with doro wot and misir wot.",
            images: makeImages(postId: postIdInjera, seeds: ["injera-plate", "injera-cooking"], widths: [400, 400], heights: [300, 250]),
            tags: ["EthiopianFood", "Injera"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "Monash University",
            likeCount: 31,
            commentCount: 6,
            saveCount: 9,
            isLiked: false,
            isSaved: false,
            createdAt: cal(.day, -7),
            authorName: "Abel Tesfaye",
            authorUsername: "abel.tesfaye",
            authorAvatarURL: nil,
            authorAvatarEmoji: "💜",
            linkedGatheringTitle: nil
        ),
        // 8. Maria's campus food tour
        Post(
            id: postIdFoodTour,
            authorId: userIdMaria,
            content: "Completed my RMIT food tour guide! Thirty-two spots tested over four months. From the hidden dumplings on A'Beckett Street to the banh mi on Victoria Street, I have ranked them all. Link in bio soon.",
            images: makeImages(postId: postIdFoodTour, seeds: ["foodtour-dumplings", "foodtour-banhmi", "foodtour-ramen", "foodtour-map"], widths: [400, 400, 300, 400], heights: [250, 250, 300, 300]),
            tags: ["FoodTour", "Melbourne", "CampusLife"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "RMIT University",
            likeCount: 67,
            commentCount: 20,
            saveCount: 30,
            isLiked: true,
            isSaved: false,
            createdAt: cal(.day, -8),
            authorName: "Maria Santos",
            authorUsername: "maria.santos",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🦋",
            linkedGatheringTitle: nil
        ),
        // 9. Wei's study tips post
        Post(
            id: postIdStudyTips,
            authorId: userIdWei,
            content: "Exam season survival kit: Pomodoro timer, lo-fi beats, and a thermos of oolong tea. Here is my Baillieu Library setup. Drop your favourite study spot below!",
            images: makeImages(postId: postIdStudyTips, seeds: ["study-setup"], widths: [400], heights: [300]),
            tags: ["StudyTips", "UniLife"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "University of Melbourne",
            likeCount: 22,
            commentCount: 4,
            saveCount: 8,
            isLiked: false,
            isSaved: false,
            createdAt: cal(.day, -9),
            authorName: "Wei Chen",
            authorUsername: "wei.chen",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🌊",
            linkedGatheringTitle: nil
        ),
        // 10. Sade's jollof rice debate
        Post(
            id: postIdJollofDebate,
            authorId: userIdSade,
            content: "I said what I said: Nigerian jollof is the original and the best. We held a blind taste test at the workshop and Nigerian won six to two. The evidence speaks for itself. Ghanaians, come collect your L.",
            images: makeImages(postId: postIdJollofDebate, seeds: ["jollof-plated", "jollof-cooking"], widths: [400, 400], heights: [300, 250]),
            tags: ["JollofRice", "NigerianFood", "WestAfrican"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "Deakin University",
            likeCount: 45,
            commentCount: 18,
            saveCount: 7,
            isLiked: true,
            isSaved: false,
            createdAt: cal(.day, -10),
            authorName: "Sade Okafor",
            authorUsername: "sade.okafor",
            authorAvatarURL: nil,
            authorAvatarEmoji: "✨",
            linkedGatheringTitle: nil
        ),
        // 11. Mai's hiking adventure
        Post(
            id: postIdHiking,
            authorId: userIdMai,
            content: "Great Ocean Road day trip with the hiking crew! We stopped at every lookout and ate way too many fish and chips in Apollo Bay. Melbourne really does have everything within driving distance.",
            images: makeImages(postId: postIdHiking, seeds: ["hiking-cliff", "hiking-ocean", "hiking-group"], widths: [400, 400, 400], heights: [250, 300, 250]),
            tags: ["Hiking", "GreatOceanRoad", "Nature"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "University of Melbourne",
            likeCount: 38,
            commentCount: 6,
            saveCount: 10,
            isLiked: false,
            isSaved: false,
            createdAt: cal(.day, -12),
            authorName: "Mai Nguyen",
            authorUsername: "mai.nguyen",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🌿",
            linkedGatheringTitle: nil
        ),
        // 12. Jin's Korean street food
        Post(
            id: postIdStreetFood,
            authorId: userIdJin,
            content: "Found the most authentic tteokbokki in Melbourne! The aunty running the stall on Victoria Street uses her grandmother's recipe. Spicy, chewy, and exactly like home. Five stars, no notes.",
            images: makeImages(postId: postIdStreetFood, seeds: ["streetfood-tteokbokki", "streetfood-stall"], widths: [400, 400], heights: [300, 250]),
            tags: ["StreetFood", "Korean", "FoodieLife"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "Monash University",
            likeCount: 52,
            commentCount: 9,
            saveCount: 15,
            isLiked: false,
            isSaved: true,
            createdAt: cal(.day, -13),
            authorName: "Jin Park",
            authorUsername: "jin.park",
            authorAvatarURL: nil,
            authorAvatarEmoji: "⭐",
            linkedGatheringTitle: nil
        ),
        // 13. Priya's rangoli art
        Post(
            id: postIdRangoli,
            authorId: userIdPriya,
            content: "Spent four hours on this rangoli for Diwali prep at the student lounge. It is a traditional peacock design that my grandmother taught me. Flour, turmeric, and dried flower petals only.",
            images: makeImages(postId: postIdRangoli, seeds: ["rangoli-art"], widths: [400], heights: [400]),
            tags: ["Rangoli", "IndianArt", "Diwali"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "RMIT University",
            likeCount: 41,
            commentCount: 5,
            saveCount: 11,
            isLiked: false,
            isSaved: false,
            createdAt: cal(.day, -15),
            authorName: "Priya Sharma",
            authorUsername: "priya.sharma",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🔥",
            linkedGatheringTitle: nil
        ),
        // 14. Carlos's study group photo
        Post(
            id: postIdStudyGroup,
            authorId: userIdCarlos,
            content: "Study group turned into an impromptu cultural exchange. Started with thermodynamics and ended with everyone teaching each other phrases in our languages. This is what uni should be about.",
            images: makeImages(postId: postIdStudyGroup, seeds: ["studygroup-library", "studygroup-notes"], widths: [400, 400], heights: [250, 300]),
            tags: ["StudyGroup", "UniLife", "Friends"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "La Trobe University",
            likeCount: 19,
            commentCount: 3,
            saveCount: 2,
            isLiked: false,
            isSaved: false,
            createdAt: cal(.day, -17),
            authorName: "Carlos Mendez",
            authorUsername: "carlos.mendez",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🍊",
            linkedGatheringTitle: nil
        ),
        // 15. Yuki's cherry blossom walk
        Post(
            id: postIdCherryBlossom,
            authorId: userIdYuki,
            content: "The cherry blossoms along the Yarra are in full bloom right now and it feels like being back in Kyoto for a moment. Packed a bento and sat under the trees for hours. Melbourne surprises me sometimes.",
            images: makeImages(postId: postIdCherryBlossom, seeds: ["cherry-tree", "cherry-path", "cherry-bento", "cherry-river"], widths: [400, 400, 300, 400], heights: [300, 250, 300, 250]),
            tags: ["CherryBlossom", "Japanese", "Nature", "Melbourne"],
            visibility: .publicPost,
            linkedGatheringId: nil,
            city: "Melbourne",
            school: "University of Melbourne",
            likeCount: 73,
            commentCount: 25,
            saveCount: 20,
            isLiked: true,
            isSaved: true,
            createdAt: cal(.day, -19),
            authorName: "Yuki Tanaka",
            authorUsername: "yuki.tanaka",
            authorAvatarURL: nil,
            authorAvatarEmoji: "🌺",
            linkedGatheringTitle: nil
        ),
    ]

    // MARK: - Post Comments (for post[0] — pho recipe)

    static let postComments: [PostComment] = {
        let commentId1 = "c-00000001"
        let commentId2 = "c-00000002"
        let commentId3 = "c-00000003"
        let commentId4 = "c-00000004"
        let commentId5 = "c-00000005"
        let commentId6 = "c-00000006"
        let commentId7 = "c-00000007-reply"
        let commentId8 = "c-00000008-reply"

        return [
            PostComment(
                id: commentId1,
                postId: postIdPhoRecipe,
                authorId: userIdJin,
                content: "This looks incredible! I always thought pho was impossible to make at home. You've inspired me to try.",
                parentCommentId: nil,
                likeCount: 5,
                isLiked: false,
                createdAt: cal(.day, -1, hour: -2),
                authorName: "Jin Park",
                authorUsername: "jin.park",
                authorAvatarEmoji: "⭐",
                replies: nil
            ),
            PostComment(
                id: commentId2,
                postId: postIdPhoRecipe,
                authorId: userIdPriya,
                content: "Eight hours! That is dedication. Does it freeze well? I want to batch cook.",
                parentCommentId: nil,
                likeCount: 3,
                isLiked: true,
                createdAt: cal(.day, -1, hour: -3),
                authorName: "Priya Sharma",
                authorUsername: "priya.sharma",
                authorAvatarEmoji: "🔥",
                replies: [
                    PostComment(
                        id: commentId7,
                        postId: postIdPhoRecipe,
                        authorId: userIdMai,
                        content: "Yes! The broth freezes beautifully. I usually make a double batch and freeze half in containers.",
                        parentCommentId: commentId2,
                        likeCount: 4,
                        isLiked: false,
                        createdAt: cal(.day, -1, hour: -1),
                        authorName: "Mai Nguyen",
                        authorUsername: "mai.nguyen",
                        authorAvatarEmoji: "🌿",
                        replies: nil
                    ),
                ]
            ),
            PostComment(
                id: commentId3,
                postId: postIdPhoRecipe,
                authorId: userIdYuki,
                content: "The charred ginger technique is similar to what we do for some Japanese broths. Love the cross-cultural connection!",
                parentCommentId: nil,
                likeCount: 7,
                isLiked: true,
                createdAt: cal(.day, -1, hour: -5),
                authorName: "Yuki Tanaka",
                authorUsername: "yuki.tanaka",
                authorAvatarEmoji: "🌺",
                replies: [
                    PostComment(
                        id: commentId8,
                        postId: postIdPhoRecipe,
                        authorId: userIdMai,
                        content: "Right?! Broth cultures unite. We should do a ramen vs pho cook-off one day.",
                        parentCommentId: commentId3,
                        likeCount: 6,
                        isLiked: false,
                        createdAt: cal(.day, -1, hour: -4),
                        authorName: "Mai Nguyen",
                        authorUsername: "mai.nguyen",
                        authorAvatarEmoji: "🌿",
                        replies: nil
                    ),
                ]
            ),
            PostComment(
                id: commentId4,
                postId: postIdPhoRecipe,
                authorId: userIdCarlos,
                content: "I need this in my life. Colombian sancocho takes forever too so I respect the commitment.",
                parentCommentId: nil,
                likeCount: 2,
                isLiked: false,
                createdAt: cal(.day, -1, hour: -6),
                authorName: "Carlos Mendez",
                authorUsername: "carlos.mendez",
                authorAvatarEmoji: "🍊",
                replies: nil
            ),
            PostComment(
                id: commentId5,
                postId: postIdPhoRecipe,
                authorId: userIdMaria,
                content: "Save me a bowl next time! I know a spot in Footscray that does amazing pho if you need taste-testing competition.",
                parentCommentId: nil,
                likeCount: 3,
                isLiked: false,
                createdAt: cal(.day, -1, hour: -8),
                authorName: "Maria Santos",
                authorUsername: "maria.santos",
                authorAvatarEmoji: "🦋",
                replies: nil
            ),
            PostComment(
                id: commentId6,
                postId: postIdPhoRecipe,
                authorId: userIdAbel,
                content: "Long-simmered broths are the best broths. Injera ferments for three days so I understand the patience needed.",
                parentCommentId: nil,
                likeCount: 4,
                isLiked: false,
                createdAt: cal(.day, -1, hour: -10),
                authorName: "Abel Tesfaye",
                authorUsername: "abel.tesfaye",
                authorAvatarEmoji: "💜",
                replies: nil
            ),
        ]
    }()

    // MARK: - Trending Tags

    static let trendingTags: [String] = [
        "FoodieLife", "KoreanBBQ", "CampusLife", "Melbourne",
        "UniLife", "StudyTips", "CulturalExchange", "StreetFood",
        "Nature", "DanceLife", "ArtLife", "FaithCommunity"
    ]

    // MARK: - Private Helpers

    private static func makeImages(postId: String, seeds: [String], widths: [Int], heights: [Int]) -> [PostImage] {
        seeds.enumerated().map { index, seed in
            PostImage(
                id: "\(postId)-img-\(index)",
                postId: postId,
                imageURL: URL(string: "https://picsum.photos/seed/\(seed)/\(widths[index])/\(heights[index])")!,
                displayOrder: index,
                width: widths[index],
                height: heights[index]
            )
        }
    }

    private static func cal(_ component: Calendar.Component, _ value: Int, hour extra: Int = 0) -> Date {
        let base = Calendar.current.date(byAdding: component, value: value, to: Date())!
        if extra == 0 { return base }
        return Calendar.current.date(byAdding: .hour, value: extra, to: base)!
    }
}
