import Foundation

@MainActor
final class MockPostService: PostServiceProtocol {
    private var posts: [Post] = []
    private var comments: [String: [PostComment]] = [:]

    nonisolated init() {}

    private func ensureLoaded() {
        if posts.isEmpty {
            posts = SampleData.posts
        }
    }

    nonisolated func fetchFeed(page: Int, filter: String?) async throws -> [Post] {
        try await Task.sleep(for: .milliseconds(600))
        return await MainActor.run {
            ensureLoaded()
            if let filter {
                return posts.filter { $0.tags.contains(filter) }
            }
            return posts
        }
    }

    nonisolated func fetchDetail(id: String) async throws -> Post {
        try await Task.sleep(for: .milliseconds(500))
        return await MainActor.run {
            ensureLoaded()
            return posts.first(where: { $0.id == id }) ?? posts[0]
        }
    }

    nonisolated func create(content: String, imageURLs: [URL], tags: [String], visibility: PostVisibility, linkedGatheringId: String?, city: String? = nil, school: String? = nil) async throws -> Post {
        try await Task.sleep(for: .milliseconds(800))
        return await MainActor.run {
            let postId = UUID().uuidString
            let images = imageURLs.enumerated().map { index, url in
                PostImage(
                    id: "\(postId)-img-\(index)",
                    postId: postId,
                    imageURL: url,
                    displayOrder: index,
                    width: nil,
                    height: nil
                )
            }
            let post = Post(
                id: postId,
                authorId: SampleData.currentUser.id,
                content: content,
                images: images,
                tags: tags,
                visibility: visibility,
                linkedGatheringId: linkedGatheringId,
                city: SampleData.currentUser.city,
                school: SampleData.currentUser.school,
                likeCount: 0,
                commentCount: 0,
                saveCount: 0,
                isLiked: false,
                isSaved: false,
                createdAt: Date(),
                authorName: SampleData.currentUser.displayName,
                authorUsername: SampleData.currentUser.username,
                authorAvatarURL: SampleData.currentUser.avatarURL,
                authorAvatarEmoji: SampleData.avatarEmoji(for: SampleData.currentUser.id),
                linkedGatheringTitle: nil
            )
            posts.insert(post, at: 0)
            return post
        }
    }

    nonisolated func delete(postId: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
        await MainActor.run {
            posts.removeAll { $0.id == postId }
        }
    }

    nonisolated func toggleLike(postId: String) async throws -> (liked: Bool, count: Int) {
        try await Task.sleep(for: .milliseconds(400))
        return await MainActor.run {
            ensureLoaded()
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].isLiked.toggle()
                posts[index].likeCount += posts[index].isLiked ? 1 : -1
                return (liked: posts[index].isLiked, count: posts[index].likeCount)
            }
            return (liked: false, count: 0)
        }
    }

    nonisolated func toggleSave(postId: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(400))
        return await MainActor.run {
            ensureLoaded()
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].isSaved.toggle()
                return posts[index].isSaved
            }
            return false
        }
    }

    nonisolated func fetchComments(postId: String, page: Int) async throws -> [PostComment] {
        try await Task.sleep(for: .milliseconds(600))
        return await MainActor.run {
            if let existing = comments[postId] {
                return existing
            }
            let sampleComments = SampleData.postComments
            comments[postId] = sampleComments
            return sampleComments
        }
    }

    nonisolated func addComment(postId: String, content: String, parentId: String?) async throws -> PostComment {
        try await Task.sleep(for: .milliseconds(500))
        return await MainActor.run {
            let comment = PostComment(
                id: UUID().uuidString,
                postId: postId,
                authorId: SampleData.currentUser.id,
                content: content,
                parentCommentId: parentId,
                likeCount: 0,
                isLiked: false,
                createdAt: Date(),
                authorName: SampleData.currentUser.displayName,
                authorUsername: SampleData.currentUser.username,
                authorAvatarEmoji: SampleData.avatarEmoji(for: SampleData.currentUser.id),
                replies: nil
            )
            comments[postId, default: []].append(comment)

            if let index = posts.firstIndex(where: { $0.id == postId }) {
                posts[index].commentCount += 1
            }
            return comment
        }
    }

    nonisolated func deleteComment(commentId: String) async throws {
        try await Task.sleep(for: .milliseconds(400))
        await MainActor.run {
            for (postId, postComments) in comments {
                comments[postId] = postComments.filter { $0.id != commentId }
            }
        }
    }

    nonisolated func fetchTrendingTags(query: String) async throws -> [String] {
        try await Task.sleep(for: .milliseconds(400))
        let tags = SampleData.trendingTags
        if query.isEmpty { return tags }
        return tags.filter { $0.lowercased().contains(query.lowercased()) }
    }
}
