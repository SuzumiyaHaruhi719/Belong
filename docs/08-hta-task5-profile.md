# Task 5: Profile & Social Tab

## 5.1 View / Edit personal info
- **Frontend:** Profile header (avatar, name, bio, school, tags, stats)
- **Backend:** `GET /api/users/me` (full profile)
- **Backend:** `PATCH /api/users/me { display_name, bio, city, school }`
- **Backend:** `POST /api/users/me/avatar` (image upload)
- **Backend:** `POST /api/users/me/tags { tags: [...] }` (update tags)
- **DB:** UPDATE users; DELETE + INSERT user_tags

## 5.2 Social Graph: Following / Followers / Mutuals

### 5.2.1 Following list
- **Backend:** `GET /api/users/me/following?page=1`
- **DB:** `SELECT users JOIN follows WHERE follower_id = :me`

### 5.2.2 Followers list
- **Backend:** `GET /api/users/me/followers?page=1`
- **DB:** `SELECT users JOIN follows WHERE following_id = :me`

### 5.2.3 Mutual friends list
- **Backend:** `GET /api/users/me/mutuals?page=1`
- **DB:**
  ```sql
  SELECT users FROM follows f1 JOIN follows f2
    ON f1.following_id = f2.follower_id
    AND f1.follower_id = f2.following_id
    WHERE f1.follower_id = :me
  ```

### Stats on profile header
- Following count: `SELECT COUNT(*) FROM follows WHERE follower_id = :me`
- Followers count: `SELECT COUNT(*) FROM follows WHERE following_id = :me`
- Mutuals count: (intersection query above with COUNT)

### Follow/Unfollow from any user profile
- **Backend:** `POST /api/users/:id/follow`
- **Backend:** `DELETE /api/users/:id/follow` (unfollow)
- **DB:** INSERT/DELETE follows; INSERT notification if new follow

## 5.3 My Gatherings tab
- **Frontend:** Tab showing gatherings user hosted or attended
- **Backend:** `GET /api/users/me/gatherings?role=all&page=1`
  - Filter: `?role=hosted` (gatherings I created)
  - Filter: `?role=attended` (gatherings I joined, past)
  - Filter: `?role=upcoming` (gatherings I joined, future)
  - Filter: `?role=saved` (bookmarked gatherings)
- **DB:** SELECT gatherings JOIN gathering_members WHERE user_id = :me

## 5.4 My Posts tab
- **Frontend:** Grid of user's own posts (like 小红书 profile)
- **Backend:** `GET /api/users/me/posts?page=1`
- **DB:** SELECT posts WHERE author_id = :me ORDER BY created_at DESC

## 5.5 Browse History

### 5.5.1 Posts history tab
- **Backend:** `GET /api/history?type=post&page=1`
- **DB:** `SELECT browse_history JOIN posts WHERE target_type = 'post'`

### 5.5.2 Gatherings history tab
- **Backend:** `GET /api/history?type=gathering&page=1`
- **DB:** `SELECT browse_history JOIN gatherings WHERE target_type = 'gathering'`

## 5.6 Settings

### 5.6.1 Privacy settings
- Profile visibility: public / school_only / followers_only
- DM permissions: mutual_only / everyone
- **Backend:** `PATCH /api/users/me/settings { privacy_profile, privacy_dm }`
- **DB:** UPDATE users

### 5.6.2 Notification settings
- Toggle: likes, comments, follows, gathering reminders, new posts
- **Backend:** `PATCH /api/users/me/settings { notifications_* }`
- **DB:** UPDATE users (or separate notification_settings table)

### 5.6.3 Report user
- **Backend:** `POST /api/reports { target_type: 'user', target_id, reason }`
- **DB:** INSERT reports

### 5.6.4 Block user
- **Backend:** `POST /api/users/:id/block`
- (same as Task 2.8.2 — shared endpoint)

### 5.6.5 Manage blocked users
- **Backend:** `GET /api/users/me/blocked`
- **Backend:** `DELETE /api/users/:id/block` (unblock)
- **DB:** SELECT/DELETE blocks

### 5.6.6 Logout
- **Backend:** `POST /api/auth/logout`
  - Invalidate refresh_token
- **Frontend:** Clear AsyncStorage, navigate to login screen
