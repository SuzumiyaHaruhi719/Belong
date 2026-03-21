# Task 4: Chat & Notifications Tab

## 4.1 Social Notifications (top section of Chat tab)
- **Frontend:** Notification feed, grouped by type
  - ❤️ "Min-jun liked your post"
  - 💬 "Jiwoo commented on your post"
  - 👤 "Soyeon started following you"
  - @ "You were mentioned in a comment"
  - 🔔 "Korean BBQ Night is in 1 hour!"
  - 📝 "Min-jun posted something new"
- **Backend:** `GET /api/notifications?page=1&limit=30`
  - Return paginated, newest first
- **Backend:** `PATCH /api/notifications/read-all`
  - `UPDATE notifications SET is_read = true WHERE recipient_id = :me`
- **Realtime:** Subscribe to `user:{user_id}:notifications` channel
  - On new notification → increment badge count on Chat tab
- **DB:** `SELECT FROM notifications WHERE recipient_id ORDER BY created_at DESC`

## 4.2 Private Messages (DMs)

### 4.2.1 Conversation list
- **Frontend:** List of DM conversations, sorted by last message
- **Backend:** `GET /api/conversations?type=dm`
  - Return conversations with last message preview
  - Include unread count per conversation
  - Filter out conversations with blocked users
- **DB:** SELECT conversations JOIN messages (latest) JOIN users

### 4.2.2 Open conversation
- **Frontend:** Message thread, text input, image upload, share post button
- **Backend:** `GET /api/conversations/:id/messages?page=1&limit=50`
- **Realtime:** Subscribe to `conversation:{id}` channel
- **DB:** SELECT messages WHERE conversation_id ORDER BY created_at

### 4.2.3 Send message
- **Backend:** `POST /api/conversations/:id/messages`
  - **DM RULES CHECK:**
    - If mutual follow → allow unlimited messages
    - If NOT mutual follow:
      - Count existing messages from sender in this conversation
      - If count >= 1 → REJECT with error "Follow each other to chat more"
      - If count == 0 → allow this one message
  - INSERT INTO messages
  - UPDATE conversations SET updated_at = now()
  - Push notification to recipient (if not currently viewing conversation)
  - Realtime: broadcast to conversation channel
- **DB:** INSERT messages; UPDATE conversations; INSERT notifications

### 4.2.4 Share post in DM
- **Backend:** `POST /api/conversations/:id/messages { message_type: 'shared_post', shared_post_id: :id }`
- **Frontend:** Render shared post as embedded card in chat

### 4.2.5 Start new DM
- **Frontend:** User search → start conversation
- **Backend:** `POST /api/conversations { type: 'dm', member_ids: [:other_user_id] }`
  - Check if conversation already exists between these two users
  - If exists → return existing conversation
  - If not → CREATE conversation + add both as members
  - Apply block check
- **DB:** SELECT existing or INSERT conversations + conversation_members

## 4.3 Group Chats (gathering groups)
- **Frontend:** List of gathering group conversations
- **Backend:** `GET /api/conversations?type=gathering_group`
  - Only show groups where user is a member (status='joined')
- Same message sending as 4.2.3 but NO mutual-follow restriction (group members can all chat freely)
- Auto-created when user joins a gathering (Task 1.3.1)
