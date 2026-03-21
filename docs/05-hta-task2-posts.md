# Task 2: Posts Tab — 小红书-style Feed & Interactions

## 2.1 Browse feed (waterfall grid)
- **Frontend:** 2-column masonry/waterfall layout, pull-to-refresh
- **Backend:** `GET /api/posts/feed?page=1&limit=20`
  - **FEED ALGORITHM:**
    - Source 1: Posts from users I follow (weight: high)
    - Source 2: Posts from same city (weight: medium)
    - Source 3: Posts from same school (weight: medium-high)
    - Source 4: Posts matching my cultural tags (weight: medium)
    - Source 5: Trending posts in my city (like_count > threshold)
    - Filter out: blocked users, reported posts, already-seen (optional)
    - Scoring: `recency * 0.3 + relevance * 0.4 + popularity * 0.3`
    - Pagination: cursor-based
  - Return: `{ posts: [{ id, author, images, content_preview, like_count, comment_count, is_liked, tags }] }`
- **DB:** Complex query with JOIN follows, user_tags, post_tags
- **Optimization:** Consider materialized view or cache for feed

## 2.2 View post detail
- **Frontend:** Full-screen post view (images carousel + text + comments)
- **Backend:** `GET /api/posts/:id`
  - Return full post with all images, author profile, tags
  - Return comments (paginated)
  - Return linked_gathering if exists
  - Record in browse_history
- **Backend:** `POST /api/history { target_type: 'post', target_id: :id }`
- **DB:** SELECT post + images + author; INSERT browse_history

## 2.3 Like post
- **Frontend:** Heart icon toggle with animation
- **Backend:** `POST /api/posts/:id/like` (toggle)
  - If not liked: `INSERT INTO post_likes; UPDATE posts SET like_count + 1`
  - If already liked: `DELETE FROM post_likes; UPDATE like_count - 1`
  - If new like: CREATE notification for post author
  - Return `{ liked: true/false, like_count }`
- **DB:** INSERT/DELETE post_likes; UPDATE posts; INSERT notifications

## 2.4 Comment on post
- **Frontend:** Text input at bottom, comment list
- **Backend:** `POST /api/posts/:id/comments { content, parent_comment_id? }`
  - INSERT INTO post_comments
  - UPDATE posts SET comment_count + 1
  - Create notification for post author (and parent comment author if reply)
  - Parse @mentions in content → create mention notifications
  - Return `{ comment }`
- **DB:** INSERT post_comments; UPDATE posts; INSERT notifications (batch)

## 2.5 Follow poster
- **Frontend:** "Follow" button on post detail or author profile
- **Backend:** `POST /api/users/:id/follow`
  - INSERT INTO follows
  - Create notification: "X started following you"
  - Check if mutual → if yes, both can now DM freely
  - If followed user creates new post/gathering → push notification
- **DB:** INSERT follows; INSERT notifications; check mutual query

## 2.6 Save / Share post

### 2.6.1 Save (bookmark)
- **Backend:** `POST /api/posts/:id/save`
- **DB:** INSERT post_saves

### 2.6.2 Share in chat
- **Frontend:** Share sheet → select conversation
- **Backend:** `POST /api/conversations/:conv_id/messages { message_type: 'shared_post', shared_post_id: :post_id }`
- **DB:** INSERT messages with type='shared_post'

## 2.7 Jump to linked gathering
- **Frontend:** If `post.linked_gathering_id` exists, show "View Gathering" button
- **Backend:** `GET /api/gatherings/:linked_gathering_id`
- **Navigation:** Deep link to Gatherings tab → gathering detail

## 2.8 Report / Block

### 2.8.1 Report post
- **Backend:** `POST /api/reports { target_type: 'post', target_id, reason }`
- **DB:** INSERT reports

### 2.8.2 Block user
- **Backend:** `POST /api/users/:id/block`
  - INSERT INTO blocks
  - Auto-unfollow both directions
  - Remove from all shared conversations
  - Filter out from all future feeds/recommendations
- **DB:** INSERT blocks; DELETE follows (both); UPDATE conversation_members
