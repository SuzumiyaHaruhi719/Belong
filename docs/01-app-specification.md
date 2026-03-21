# Belong -- App Specification

**For Claude Code Agent / Vibe Coding Reference**
Last updated: 2026-03-21

---

## 1. PROJECT OVERVIEW

- **App Name:** Belong
- **Tagline:** Find your people. Share your story. Belong here.
- **Type:** Native iOS app (SwiftUI)
- **Target Users:** International and multicultural university students
- **Core Problem:** Cultural isolation on US college campuses -- students from underrepresented cultural backgrounds struggle to find community
- **Core Features:** Cultural gatherings + Social posts (RED/Xiaohongshu-style) + Direct and group messaging + Social graph with follow system
- **Auth:** .edu email only, OTP verification (no social login)

---

## 2. DESIGN SYSTEM

### 2.1 Typography

| Role | Font | Weight | Size |
|------|------|--------|------|
| H1 (screen titles) | Fraunces | Bold | 28pt |
| H2 (section headers) | Fraunces | SemiBold | 22pt |
| H3 (card titles) | Fraunces | Medium | 18pt |
| Body | Plus Jakarta Sans | Regular | 16pt |
| Body Small | Plus Jakarta Sans | Regular | 14pt |
| Caption | Plus Jakarta Sans | Medium | 12pt |
| Button | Plus Jakarta Sans | SemiBold | 16pt |
| Tab label | Plus Jakarta Sans | Medium | 10pt |

### 2.2 Color Palette

| Token | Name | Hex | Usage |
|-------|------|-----|-------|
| `primary` | Terracotta | #C47B5A | Buttons, active states, accents |
| `primaryLight` | Light Terracotta | #D4956F | Hover/pressed states, secondary accents |
| `background` | Warm Cream | #FAF3EB | Page backgrounds |
| `surface` | White | #FFFFFF | Cards, modals, input fields |
| `textPrimary` | Dark Brown | #2C2825 | Headings, body text |
| `textSecondary` | Medium Brown | #6B5E57 | Captions, secondary labels |
| `textTertiary` | Light Brown | #A89889 | Placeholders, disabled text |
| `border` | Sand | #E8DDD3 | Card borders, dividers |
| `success` | Sage Green | #7BA37E | Confirmations, joined status |
| `warning` | Amber | #E6A84D | Maybe status, caution states |
| `error` | Coral Red | #D45B5B | Errors, destructive actions |
| `info` | Slate Blue | #5B8FB9 | Informational badges, links |
| `tagChip` | Blush Pink | #F2D9CF | Tag chip backgrounds |
| `tagChipText` | Deep Terracotta | #8B5E3C | Tag chip text |

### 2.3 Spacing & Radius

| Token | Value |
|-------|-------|
| `xs` | 4pt |
| `sm` | 8pt |
| `md` | 12pt |
| `lg` | 16pt |
| `xl` | 24pt |
| `xxl` | 32pt |
| Card corner radius | 16pt |
| Button corner radius | 12pt |
| Chip corner radius | 20pt (full pill) |
| Avatar corner radius | 50% (circle) |
| Input corner radius | 12pt |

### 2.4 Elevation & Shadows

| Level | Usage | Shadow |
|-------|-------|--------|
| 0 | Flat backgrounds | None |
| 1 | Cards, chips | 0 2px 8px rgba(44,40,37,0.06) |
| 2 | Floating buttons, modals | 0 4px 16px rgba(44,40,37,0.10) |
| 3 | Bottom sheets, overlays | 0 -4px 24px rgba(44,40,37,0.12) |

### 2.5 Iconography

- **Style:** SF Symbols (iOS native), outlined default, filled for active/selected states
- **Tab bar icons:** 24pt, regular weight (inactive), filled variant (active)
- **In-content icons:** 20pt
- **Action icons:** 24pt

### 2.6 Component Conventions

| Component | Spec |
|-----------|------|
| Primary Button | Terracotta fill, white text, 48pt height, 12pt radius |
| Secondary Button | White fill, terracotta border, terracotta text, 48pt height |
| Ghost Button | No border, terracotta text only |
| Text Input | White fill, sand border, 48pt height, 12pt radius, 16px horizontal padding |
| Avatar (small) | 36pt circle |
| Avatar (medium) | 48pt circle |
| Avatar (large) | 80pt circle |
| Tag Chip | Blush pink fill, deep terracotta text, 32pt height, pill radius |
| Card | White fill, sand border, 16pt radius, 16pt padding |
| Bottom Sheet | White fill, 24pt top radius, drag handle indicator |

---

## 3. BOTTOM TAB NAVIGATION

5 tabs in the main TabView:

```
Tab 1:  Gatherings   (icon: person.3)           -> Task 1
Tab 2:  Posts         (icon: square.grid.2x2)    -> Task 2
Tab 3:  Create        (icon: plus.circle.fill)   -> Task 3
Tab 4:  Chat          (icon: bubble.left.and.bubble.right) -> Task 4
Tab 5:  Profile       (icon: person.crop.circle) -> Task 5
```

- The Create tab (center) uses a larger, terracotta-filled icon to stand out
- Chat tab shows unread badge count (notifications + unread messages combined)
- Profile tab shows a red dot if there are unseen notifications about followers

---

## 4. TASK BREAKDOWN (Hierarchical Task Analysis)

### Task 0: Register & Onboard (one-time)

| Step | Description |
|------|-------------|
| 0.1 | Create account: enter .edu email, receive and verify OTP, set password, set username |
| 0.2 | Profile setup: choose avatar (preset or upload), set display name, set app language |
| 0.3 | Location & School (required): select city, select school |
| 0.4 | Cultural tags (skippable): cultural background, languages spoken, interests/vibes |
| 0.5 | Onboarding complete -> land on Gatherings tab (Task 1) |

**Auth flow:** .edu email -> OTP code (6-digit, 10min expiry) -> set password (bcrypt) -> set username -> JWT issued

---

### Task 1: Gatherings Tab -- Discover, Join, Reflect

The primary experience loop. Users discover culturally-relevant gatherings, RSVP, attend, and reflect afterward.

| Step | Description |
|------|-------------|
| 1.1 | **See top pick** -- Hero card showing the #1 recommended gathering based on tag matching, school, follows, and feedback history. Falls back to same-city + soonest if no tags. |
| 1.2 | **Browse feed** -- Scrollable list below the hero card. Filter pills (Food, Study, Cultural, etc.), search bar, cursor-based pagination. Same scoring algorithm as 1.1 but returns top 20 per page. |
| 1.3 | **Join / Maybe / Save** -- One-tap join (inserts gathering_member with status=joined, notifies host, adds to group chat). Maybe = private interest (no host notification, 24h reminder scheduled). Save = bookmark for later. |
| 1.4 | **Confirmation + Calendar** -- Success screen with event summary, "Add to Calendar" button generating .ics data. |
| 1.5 | **Prepare -- Group Chat** -- After joining, access the gathering's group conversation. Same chat component as Task 4. Only visible to joined members. |
| 1.6 | **Reflect & Connect** (post-event) -- Emoji check-in (1-5 rating mapped from emoji, stored in gathering_feedback). Save connections (view attendees, shared tags highlighted, one-tap follow). Share as post (links to Task 3 Create Post with pre-filled gathering link and suggested hashtags). |
| 1.7 | **Store feedback** (system/backend) -- Background job updates user_tag_affinity table using exponential moving average. High rating on tagged gathering increases affinity; low rating decreases it. This is the feedback loop that makes 1.1 smarter over time. |

**Recommendation algorithm summary (for 1.1 and 1.2):**
1. Filter: same city, status=upcoming, not already joined/saved/dismissed, not from blocked users
2. Score: +10 matching cultural_background tag, +8 matching language tag, +5 matching interest tag, +3 same school, +5 host is followed, +2 mutual friend attending, +N from user_tag_affinity history, -5 if >7 days out, +3 if almost full
3. Sort by score descending
4. No tags fallback: same city + same school + soonest

---

### Task 2: Posts Tab -- Browse Feed, View, Interact

A RED/Xiaohongshu-style social content feed. Users browse image-rich posts in a 2-column waterfall grid, interact with likes/comments/saves, and discover gatherings through linked posts.

| Step | Description |
|------|-------------|
| 2.1 | **Browse waterfall feed** -- 2-column masonry/waterfall grid layout. Each card shows: cover image (first from post_images), title/caption truncated, author avatar + name, like count + heart icon. Infinite scroll with cursor-based pagination. Feed is personalized: posts from followed users, same-city users, matching tags, trending. |
| 2.2 | **View post detail** -- Full-screen post view. Image carousel (swipeable, from post_images). Author info (avatar, name, tap to view profile). Full caption text. Hashtags (tappable, link to tag search). Linked gathering card (if linked_gathering_id is set -- tap to go to gathering detail in Task 1). Timestamp. |
| 2.3 | **Like** -- Heart icon toggle. Optimistic UI update. `INSERT/DELETE post_likes`. Increments/decrements `posts.like_count`. Creates notification for post author (type=like). |
| 2.4 | **Comment** -- Bottom sheet with comment list (threaded -- parent_comment_id for replies). Text input to add comment. Supports @mentions (triggers notification type=mention). Comment count updates on post. |
| 2.5 | **Follow author** -- Follow button on post detail and author profile. `INSERT INTO follows`. Creates notification (type=follow). If mutual follow, DM becomes available. |
| 2.6 | **Save & Share** -- Save/bookmark: `INSERT INTO post_saves`. Share in chat: opens conversation picker, sends message with shared_post_id (message_type=shared_post). |
| 2.7 | **Jump to linked gathering** -- If post has linked_gathering_id, show a gathering card in the post detail. Tap navigates to Task 1.3 (gathering detail with join option). This is the content flywheel conversion point. |

**Feed algorithm (for 2.1):**
1. Mix: 40% from followed users, 30% same city/school, 20% matching tags, 10% trending (high like_count in last 48h)
2. Filter out: posts from blocked users, posts user has already dismissed
3. Sort by weighted score with recency decay
4. Record views in browse_history for "already seen" dedup

---

### Task 3: Create Tab -- Create Gathering or Create Post

The Create tab presents a choice: create a gathering or create a post. Both flows share this tab.

| Step | Description |
|------|-------------|
| 3.1 | **Choose type** -- Two large cards: "Host a Gathering" and "Share a Post". If arriving from Task 1.6.3 (reflect -> share), skip straight to 3.3 with pre-fill. |
| 3.2 | **Create Gathering** -- Step 1: Choose template (Food, Study, Hangout, Cultural, Faith, Active -- sets emoji and default tags). Step 2: Fill details (title, description, location with autocomplete, date/time picker, max attendees 2-20, visibility: open/matching_tags/invite_only, vibe: low_key/hype/chill/welcoming). Step 3: Preview and publish. On publish: `INSERT INTO gatherings`, `INSERT INTO gathering_tags`, create group conversation, host auto-joined as member. Support save as draft (is_draft=true). |
| 3.3 | **Create Post** -- Step 1: Select photos (1-9 images from camera roll or camera, reorder with drag). Step 2: Write caption, add hashtags (autocomplete from existing tags), optionally link a gathering (search user's past/upcoming gatherings), set visibility. Step 3: Preview and publish. On publish: `INSERT INTO posts`, `INSERT INTO post_images` (with display_order, width, height), `INSERT INTO post_tags`. Images uploaded to storage, compressed and resized. |

---

### Task 4: Chat & Notifications

The Chat tab has two sections accessible via a segmented control at the top: Notifications and Messages.

| Step | Description |
|------|-------------|
| 4.1 | **Notifications feed** -- Chronological list of notifications grouped by type. Types: like, comment, follow, mention, gathering_reminder, gathering_joined, new_post_from_following, new_gathering_from_following, dm_message, follow_suggestion. Each notification shows: actor avatar, action text, target preview, timestamp. Tap navigates to the relevant content (post detail, gathering detail, profile, or conversation). Mark as read on view. Unread count shown as badge on Chat tab. |
| 4.2 | **DM conversations** -- List of direct message conversations sorted by last message time. Requires mutual follow to initiate a DM. Conversation list shows: other user's avatar + name, last message preview, timestamp, unread indicator. |
| 4.3 | **Group chats** -- Gathering group conversations. Auto-created when a gathering is published. Members added when they join (status=joined). Shows gathering emoji + title as conversation name. Same message UI as DMs. |
| 4.4 | **Chat detail** -- Message bubbles (sent = right-aligned terracotta, received = left-aligned white). Supports: text messages, image messages (tap to view full), shared posts (rendered as mini post card, tap to view post detail). Text input bar with send button. Image attach button. Real-time via WebSocket/Supabase Realtime subscription on conversation channel. |
| 4.5 | **Share post in chat** -- From Task 2.6, user picks a conversation. Message is created with message_type=shared_post and shared_post_id set. Recipient sees a rich preview card of the post. |

---

### Task 5: Profile & Social

The Profile tab is the user's identity hub: view/edit profile, manage social connections, see personal content, and access settings.

| Step | Description |
|------|-------------|
| 5.1 | **My profile view** -- Avatar, display name, username, bio, school, city, cultural tags displayed as chips. Stats row: X gatherings attended, Y posts, Z followers, W following. Two content tabs below stats: "My Gatherings" and "My Posts". |
| 5.2 | **Social graph** -- Tap on follower/following count to view lists. Followers list, Following list, Mutuals list (computed: users in both follows directions). Each row: avatar, name, username, follow/unfollow button. Search within lists. Block and Report accessible from user profile (long press or three-dot menu). Block: `INSERT INTO blocks`, immediately hide all content from blocked user. Report: `INSERT INTO reports` with reason and optional details. |
| 5.3 | **My Gatherings** -- List of gatherings the user has hosted or attended. Filter: Upcoming, Past, Hosted, Saved. Tap navigates to gathering detail (Task 1). |
| 5.4 | **My Posts** -- Grid of user's own posts (2-column grid, same style as Task 2 feed). Tap navigates to post detail (Task 2.2). |
| 5.5 | **Browse History** -- Chronological list of recently viewed posts and gatherings (from browse_history table). Useful for finding something seen earlier. |
| 5.6 | **Edit Profile** -- Edit display name, bio, avatar, cultural tags, language tags, interest tags. All saved via PATCH /api/users/me and POST /api/users/me/tags. |
| 5.7 | **Other user's profile** -- Same layout as 5.1 but for another user. Shows Follow/Unfollow button, Message button (if mutual follow), Block/Report in overflow menu. |
| 5.8 | **Settings** -- App language, privacy settings (profile visibility: public/school_only/followers_only, DM access: mutual_only/everyone), notification preferences (toggle per type), account management (change password, delete account), about/legal. |

---

## 5. CROSS-TAB NAVIGATION MAP

These are the key navigation paths that connect different parts of the app:

```
Task 1.6.3  (Reflect -> Share as post)       -> Task 3.3  (Create Post, pre-filled with gathering link)
Task 2.7    (Post -> Linked gathering)        -> Task 1.3  (Gathering detail with Join option)
Task 1.6.2  (Save connections after event)    -> Task 5.2  (Auto-suggest follow, updates following list)
Task 2.5    (Follow from post detail)         -> Task 5.2  (Following list updated)
Task 2.6.2  (Share post in chat)              -> Task 4.4  (DM or group chat with shared post card)
Task 3.2.3  (Publish gathering)               -> Task 1.1  (Appears in others' recommended feeds)
Task 3.3.4  (Publish post)                    -> Task 2.1  (Appears in followers' waterfall feeds)
Task 4.1    (Tap notification)                -> Task 2.2 or Task 1.3 (target content detail)
Task 5.3    (My Gatherings -> tap one)        -> Task 1.3  (Gathering detail)
Task 5.4    (My Posts -> tap one)             -> Task 2.2  (Post detail)
Task 5.7    (Other user profile -> Message)   -> Task 4.4  (DM conversation)
```

---

## 6. CONTENT FLYWHEEL

The core engagement loop that drives growth:

```
Attend Gathering (Task 1.3)
    |
    v
Reflect & Rate (Task 1.6) -- feedback stored, improves recommendations
    |
    v
Share as Post (Task 1.6.3 -> Task 3.3) -- creates content with gathering link
    |
    v
Others See Post in Feed (Task 2.1) -- discovery through waterfall feed
    |
    v
Jump to Linked Gathering (Task 2.7 -> Task 1.3) -- conversion
    |
    v
Attend Gathering (Task 1.3) -- loop continues, new user creates their own post
```

Secondary loops:
- Follow loop: See post -> follow author -> see more of their content -> attend their gatherings
- Chat loop: See post -> share in DM -> friend sees -> both attend gathering
- Recommendation loop: Attend -> rate -> algorithm learns -> better recommendations -> attend more

---

## 7. DATA MODELS (Summary)

Full SQL schema in `02-database-schema.md`. Tables:

| Table | Purpose |
|-------|---------|
| `users` | User accounts (.edu email, profile info, privacy settings, app language) |
| `user_tags` | Cultural background, language, and interest tags per user (category + tag_value) |
| `follows` | Directed follow relationships (mutual = both rows exist) |
| `blocks` | Block relationships (hides all content from blocked user) |
| `reports` | User/content reports with reason and status |
| `gatherings` | Events with template type, location, time, capacity, visibility, vibe |
| `gathering_tags` | Tags associated with a gathering |
| `gathering_members` | RSVP status per user per gathering (joined/maybe/saved/left) |
| `gathering_feedback` | Post-event emoji ratings (1-5 score, feeds recommendation engine) |
| `posts` | Social posts with content, location, visibility, linked gathering, engagement counts |
| `post_images` | Images attached to posts (URL, display order, dimensions) |
| `post_tags` | Hashtags on posts (stored without #) |
| `post_likes` | Like relationships (user + post) |
| `post_comments` | Comments with threading support (parent_comment_id for replies) |
| `post_saves` | Bookmark/save relationships |
| `conversations` | Chat conversations (type: dm or gathering_group) |
| `conversation_members` | Members of each conversation with last_read_at for unread tracking |
| `messages` | Chat messages (text, image, shared_post, system types) |
| `notifications` | All notification types with actor, target, read status |
| `browse_history` | View history for posts and gatherings (for dedup and history feature) |
| `otp_codes` | One-time password codes for .edu email verification |
| `user_tag_affinity` | Learned tag preferences from gathering feedback (exponential moving average) |

---

## 8. REALTIME SUBSCRIPTIONS

WebSocket / Supabase Realtime channels:

```
Channel: user:{user_id}:notifications
  -> New notification arrives -> update badge count on Chat tab + show in-app alert

Channel: conversation:{conversation_id}
  -> New message -> append to chat UI in real-time
  -> Typing indicator (future enhancement)

Channel: gathering:{gathering_id}:members
  -> Someone joins -> update attendee count in real-time on gathering cards
```

---

## 9. TECH STACK

| Layer | Choice |
|-------|--------|
| Frontend | SwiftUI (iOS native) |
| Backend | Node.js (Express) + Supabase |
| Database | PostgreSQL (Supabase) |
| Auth | Supabase Auth with custom .edu validation + OTP |
| Storage | Supabase Storage (images -- avatars, post images, chat images) |
| Realtime | Supabase Realtime (chat messages, notifications, member counts) |
| Search | PostgreSQL full-text search (gatherings, posts, users, tags) |
| Push Notifications | APNs (Apple Push Notification service) |
| Recommendation Engine | Tag-matching scoring algorithm with feedback-driven affinity weights |

---

## 10. DOCUMENT INDEX

| Doc | Contents |
|-----|----------|
| `01-app-specification.md` | This file -- complete app spec, design system, task breakdown, navigation |
| `02-database-schema.md` | Complete SQL schema for all tables |
| `03-hta-task0-onboarding.md` | Register & Onboard flow with backend operations |
| `04-hta-task1-gatherings.md` | Gatherings tab -- discover, join, reflect, feedback loop |
| `05-hta-task2-posts.md` | Posts tab -- RED-style waterfall feed and interactions |
| `06-hta-task3-create.md` | Create tab -- create gathering or post |
| `07-hta-task4-chat.md` | Chat & Notifications tab -- DMs, group chats, notification feed |
| `08-hta-task5-profile.md` | Profile & Social tab -- profile, social graph, settings |
| `09-api-endpoints.md` | Complete API endpoint reference |
| `10-recommendation-engine.md` | Recommendation algorithm with feedback loop details |
