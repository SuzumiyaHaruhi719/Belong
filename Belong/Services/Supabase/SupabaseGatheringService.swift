import Foundation
import Supabase

@MainActor
final class SupabaseGatheringService: GatheringServiceProtocol {
    private let manager = SupabaseManager.shared

    func fetchRecommended(city: String, limit: Int) async throws -> [Gathering] {
        // Use the recommend_gatherings RPC function
        let rows: [DBGathering] = try await manager.client
            .rpc("recommend_gatherings", params: RecommendParams(pLimit: limit))
            .execute()
            .value
        return try await enrichGatherings(rows)
    }

    func fetchFeed(city: String, page: Int, filter: String?) async throws -> [Gathering] {
        var query = manager.client.from("gatherings")
            .select("*")
            .eq("is_draft", value: false)
            .eq("status", value: "upcoming")
        if !city.isEmpty {
            query = query.eq("city", value: city)
        }
        if let filter, !filter.isEmpty {
            query = query.eq("template_type", value: filter)
        }
        let rows: [DBGathering] = try await query
            .order("starts_at", ascending: true)
            .range(from: page * 20, to: (page + 1) * 20 - 1)
            .execute()
            .value
        return try await enrichGatherings(rows)
    }

    func fetchDetail(id: String) async throws -> Gathering {
        let rows: [DBGathering] = try await manager.client.from("gatherings")
            .select()
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value
        guard let row = rows.first else { throw SupabaseServiceError.notFound }

        var gathering = mapDBGathering(row)

        // Fetch tags
        let tagRows: [DBGatheringTag] = try await manager.client.from("gathering_tags")
            .select()
            .eq("gathering_id", value: id)
            .execute()
            .value
        gathering.tags = tagRows.map(\.tagValue)

        // Fetch member count
        let members: [DBGatheringMember] = try await manager.client.from("gathering_members")
            .select()
            .eq("gathering_id", value: id)
            .in("status", values: ["joined", "maybe"])
            .execute()
            .value
        gathering.attendeeCount = members.filter { $0.status == "joined" }.count

        // Check current user state
        if let myId = manager.currentUserId {
            let myMembership = members.first { $0.userId == myId }
            gathering.isJoined = myMembership?.status == "joined"
            gathering.isMaybe = myMembership?.status == "maybe"

            // Check if saved
            let saves: [DBGatheringMember] = try await manager.client.from("gathering_members")
                .select()
                .eq("gathering_id", value: id)
                .eq("user_id", value: myId)
                .eq("status", value: "saved")
                .execute()
                .value
            gathering.isBookmarked = !saves.isEmpty
        }

        // Fetch host info
        if let hostRows: [DBUser] = try? await manager.client.from("users")
            .select("display_name, username, avatar_url, default_avatar_id")
            .eq("id", value: row.hostId ?? "")
            .limit(1)
            .execute()
            .value,
           let host = hostRows.first {
            gathering.hostName = host.displayName ?? host.username ?? ""
            gathering.hostAvatarEmoji = "🙂"
        }

        return gathering
    }

    func join(gatheringId: String) async throws -> Gathering {
        try await manager.client.rpc("join_gathering", params: JoinGatheringParams(pGatheringId: gatheringId, pStatus: "joined"))
            .execute()
        return try await fetchDetail(id: gatheringId)
    }

    func maybe(gatheringId: String) async throws {
        try await manager.client.rpc("join_gathering", params: JoinGatheringParams(pGatheringId: gatheringId, pStatus: "maybe"))
            .execute()
    }

    func save(gatheringId: String) async throws {
        try await manager.client.rpc("join_gathering", params: JoinGatheringParams(pGatheringId: gatheringId, pStatus: "saved"))
            .execute()
    }

    func unsave(gatheringId: String) async throws {
        let myId = try manager.requireUserId()
        try await manager.client.from("gathering_members")
            .delete()
            .eq("gathering_id", value: gatheringId)
            .eq("user_id", value: myId)
            .eq("status", value: "saved")
            .execute()
    }

    func leave(gatheringId: String) async throws {
        let myId = try manager.requireUserId()
        try await manager.client.from("gathering_members")
            .delete()
            .eq("gathering_id", value: gatheringId)
            .eq("user_id", value: myId)
            .execute()
    }

    func create(_ gathering: Gathering) async throws -> Gathering {
        // Use publish_gathering RPC for atomic creation
        let params = PublishGatheringParams(
            pTitle: gathering.title,
            pDescription: gathering.description,
            pTemplateType: gathering.templateType.rawValue,
            pEmoji: gathering.emoji,
            pImageUrl: gathering.imageURL?.absoluteString,
            pCity: gathering.city,
            pSchool: gathering.school,
            pLocationName: gathering.locationName,
            pLatitude: gathering.latitude,
            pLongitude: gathering.longitude,
            pStartsAt: formatSupabaseDate(gathering.startsAt),
            pEndsAt: gathering.endsAt.map { formatSupabaseDate($0) },
            pMaxAttendees: gathering.maxAttendees,
            pVisibility: gathering.visibility.rawValue,
            pVibe: gathering.vibe.rawValue,
            pTags: gathering.tags,
            pIsDraft: gathering.isDraft
        )

        // RPC returns JSON: {"gathering_id": "uuid"}
        let result: PublishGatheringResult = try await manager.client
            .rpc("publish_gathering", params: params)
            .execute()
            .value
        return try await fetchDetail(id: result.gatheringId)
    }

    func update(_ gathering: Gathering) async throws -> Gathering {
        // Update gathering row
        let updates = DBGathering(
            id: gathering.id,
            hostId: nil,
            title: gathering.title,
            description: gathering.description,
            templateType: gathering.templateType.rawValue,
            emoji: gathering.emoji,
            imageUrl: gathering.imageURL?.absoluteString,
            city: gathering.city,
            school: gathering.school,
            locationName: gathering.locationName,
            latitude: gathering.latitude,
            longitude: gathering.longitude,
            startsAt: formatSupabaseDate(gathering.startsAt),
            endsAt: gathering.endsAt.map { formatSupabaseDate($0) },
            maxAttendees: gathering.maxAttendees,
            visibility: gathering.visibility.rawValue,
            vibe: gathering.vibe.rawValue,
            status: gathering.status.rawValue,
            isDraft: gathering.isDraft
        )
        try await manager.client.from("gatherings")
            .update(updates)
            .eq("id", value: gathering.id)
            .execute()

        // Update tags: delete old, insert new
        try await manager.client.from("gathering_tags")
            .delete()
            .eq("gathering_id", value: gathering.id)
            .execute()
        if !gathering.tags.isEmpty {
            let tagRows = gathering.tags.map { DBGatheringTag(gatheringId: gathering.id, tagValue: $0) }
            try await manager.client.from("gathering_tags")
                .insert(tagRows)
                .execute()
        }

        return try await fetchDetail(id: gathering.id)
    }

    func cancel(gatheringId: String) async throws {
        try await manager.client.from("gatherings")
            .update(StatusUpdate(status: "cancelled"))
            .eq("id", value: gatheringId)
            .execute()
    }

    func submitFeedback(gatheringId: String, emoji: FeedbackLevel) async throws {
        let score: Int
        switch emoji {
        case .meh: score = 1
        case .okay: score = 2
        case .good: score = 3
        case .great: score = 4
        case .amazing: score = 5
        }
        try await manager.client.rpc("submit_gathering_feedback", params: SubmitFeedbackParams(
            pGatheringId: gatheringId,
            pEmojiRating: emoji.rawValue,
            pRatingScore: score
        )).execute()
    }

    func fetchAttendees(gatheringId: String) async throws -> [GatheringMember] {
        let rows: [DBGatheringMember] = try await manager.client.from("gathering_members")
            .select()
            .eq("gathering_id", value: gatheringId)
            .in("status", values: ["joined", "maybe"])
            .execute()
            .value

        // Fetch user info for each member
        let userIds = rows.compactMap(\.userId)
        guard !userIds.isEmpty else { return [] }
        let users: [DBUser] = try await manager.client.from("users")
            .select("id, display_name, username, avatar_url, default_avatar_id")
            .in("id", values: userIds)
            .execute()
            .value
        let userMap = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })

        return rows.map { row in
            let user = userMap[row.userId ?? ""]
            return GatheringMember(
                gatheringId: row.gatheringId ?? gatheringId,
                userId: row.userId ?? "",
                status: MemberStatus(rawValue: row.status ?? "joined") ?? .joined,
                joinedAt: parseSupabaseDate(row.joinedAt),
                userName: user?.displayName ?? user?.username ?? "User",
                userAvatarEmoji: "🙂",
                sharedTags: []
            )
        }
    }

    func fetchTemplates() async throws -> [HostingTemplate] {
        // Templates are static, not in the database
        return SampleData.hostingTemplates
    }

    func search(query: String, city: String) async throws -> [Gathering] {
        let rows: [DBGathering] = try await manager.client.from("gatherings")
            .select()
            .eq("is_draft", value: false)
            .or("title.ilike.%\(query)%,description.ilike.%\(query)%")
            .order("starts_at", ascending: true)
            .limit(30)
            .execute()
            .value
        return try await enrichGatherings(rows)
    }

    // MARK: - Draft Support

    func saveDraft(_ gathering: Gathering) async throws -> Gathering {
        var draft = gathering
        draft.isDraft = true
        if gathering.id.isEmpty || gathering.id.hasPrefix("temp-") {
            // New draft → create
            return try await create(draft)
        } else {
            // Existing draft → update
            return try await update(draft)
        }
    }

    func fetchDrafts() async throws -> [Gathering] {
        let myId = try manager.requireUserId()
        let rows: [DBGathering] = try await manager.client.from("gatherings")
            .select()
            .eq("host_id", value: myId)
            .eq("is_draft", value: true)
            .order("updated_at", ascending: false)
            .execute()
            .value
        return rows.map { mapDBGathering($0) }
    }

    func publishDraft(gatheringId: String) async throws -> Gathering {
        try await manager.client.from("gatherings")
            .update(PublishDraftUpdate(isDraft: false, status: "upcoming"))
            .eq("id", value: gatheringId)
            .execute()
        return try await fetchDetail(id: gatheringId)
    }

    // MARK: - Helpers

    private func enrichGatherings(_ rows: [DBGathering]) async throws -> [Gathering] {
        let gatheringIds = rows.compactMap(\.id)
        guard !gatheringIds.isEmpty else { return [] }

        // Batch-fetch tags
        let allTags: [DBGatheringTag] = try await manager.client.from("gathering_tags")
            .select()
            .in("gathering_id", values: gatheringIds)
            .execute()
            .value
        let tagsByGathering = Dictionary(grouping: allTags, by: \.gatheringId)

        // Batch-fetch member counts
        let allMembers: [DBGatheringMember] = try await manager.client.from("gathering_members")
            .select()
            .in("gathering_id", values: gatheringIds)
            .in("status", values: ["joined"])
            .execute()
            .value
        let membersByGathering = Dictionary(grouping: allMembers, by: { $0.gatheringId ?? "" })

        // Batch-fetch host info
        let hostIds = Array(Set(rows.compactMap(\.hostId)))
        var hostMap: [String: DBUser] = [:]
        if !hostIds.isEmpty {
            let hosts: [DBUser] = try await manager.client.from("users")
                .select("id, display_name, username, avatar_url")
                .in("id", values: hostIds)
                .execute()
                .value
            hostMap = Dictionary(uniqueKeysWithValues: hosts.map { ($0.id, $0) })
        }

        return rows.map { row in
            var g = mapDBGathering(row)
            let gid = row.id ?? ""
            g.tags = (tagsByGathering[gid] ?? []).map(\.tagValue)
            g.attendeeCount = (membersByGathering[gid] ?? []).count
            if let host = hostMap[row.hostId ?? ""] {
                g.hostName = host.displayName ?? host.username ?? ""
            }
            return g
        }
    }
}

// Helper for mixed-type JSON encoding
struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

extension Dictionary where Key == String, Value == AnyEncodable {
    init(_ dict: [String: Any]) {
        self = [:]
        for (key, value) in dict {
            if let v = value as? String { self[key] = AnyEncodable(v) }
            else if let v = value as? Bool { self[key] = AnyEncodable(v) }
            else if let v = value as? Int { self[key] = AnyEncodable(v) }
        }
    }
}
