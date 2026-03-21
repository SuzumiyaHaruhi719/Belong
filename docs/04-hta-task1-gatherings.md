# Task 1: Gatherings Tab — Discover & Attend

## 1.1 See top pick (home screen of Gatherings tab)
- **Frontend:** Hero card with gathering details, trust signals
- **Backend:** `GET /api/gatherings/recommended?limit=1`
  - **RECOMMENDATION ALGORITHM:**
    1. Filter by `city = user.city AND status = 'upcoming'`
    2. Filter out gatherings user already joined/saved/dismissed
    3. Filter out gatherings by blocked users
    4. Score each gathering:
       - +10 per matching cultural_background tag
       - +8 per matching language tag
       - +5 per matching interest_vibe tag
       - +3 if same school
       - +5 if host is followed by user
       - +2 if any mutual friend is attending
       - +N based on user's historical feedback (from `gathering_feedback` + `gathering_tags` → `user_tag_affinity`)
       - -5 if starts > 7 days from now (prefer sooner)
       - +3 if almost full (< 2 spots left = urgency boost)
    5. Return top-scored gathering
    6. If user has NO tags → fall back to: same city + same school + soonest
  - Return: `{ gathering, host_profile, attendee_count, matching_tags[] }`
- **DB:** Complex JOIN across gatherings, gathering_tags, user_tags, gathering_members, gathering_feedback, follows, blocks

## 1.2 Browse feed (optional fallback)
- **Frontend:** Scrollable list with filter pills, search bar
- **Backend:** `GET /api/gatherings/feed?page=1&limit=20&filter=:filter`
  - Same scoring as 1.1 but return top 20 per page
  - Support filters: `?tag=Food`, `?tag=Korean`, `?date=this_week`
  - Support search: `?q=korean+bbq` (full-text search on title+description)
  - Pagination: cursor-based (use created_at + id)
- **DB:** Same as 1.1 but `LIMIT 20 OFFSET` (paginated)

## 1.3 Join / Maybe / Save

### 1.3.1 One-tap Join
- **Frontend:** Button state change → green "You're in!"
- **Backend:** `POST /api/gatherings/:id/join`
  - Check gathering not full (`count members < max_attendees`)
  - Check gathering not cancelled
  - `INSERT INTO gathering_members (status='joined')`
  - Create notification for host: "X joined your gathering"
  - Add user to gathering's group conversation: `INSERT INTO conversation_members`
  - Return `{ success, updated_attendee_count }`
- **DB:** INSERT gathering_members; INSERT conversation_members; INSERT notifications

### 1.3.2 Maybe / Express interest
- **Frontend:** Amber state, private (host not notified)
- **Backend:** `POST /api/gatherings/:id/maybe`
  - `INSERT INTO gathering_members (status='maybe')`
  - NO notification to host
  - Schedule reminder notification 24h before event
- **DB:** INSERT gathering_members; schedule job in task queue

### 1.3.3 Save / Bookmark
- **Frontend:** Bookmark icon toggle
- **Backend:** `POST /api/gatherings/:id/save`
  - `INSERT INTO gathering_members (status='saved')`
- **DB:** INSERT gathering_members

## 1.4 Confirmation + Calendar
- **Frontend:** Success screen with event summary, calendar button
- **Backend:** `GET /api/gatherings/:id/calendar`
  - Return .ics file or deep link to native calendar
- **Calendar integration:** Generate ICS with VEVENT data

## 1.5 Prepare — Group Chat (post-join only)
- **Frontend:** Chat screen (same component as Task 4)
- **Backend:** `GET /api/conversations/:conv_id/messages?page=1`
- **Backend:** `POST /api/conversations/:conv_id/messages { content, type }`
- **Realtime:** Subscribe to conversation channel for live messages
- **Access control:** Only gathering_members with status='joined' can access

## 1.6 Reflect & Connect (after event ends)

**Triggered:** When `gathering.ends_at` passes OR host marks as complete

### 1.6.1 Emoji check-in
- **Frontend:** 5 emoji options, one-tap select
- **Backend:** `POST /api/gatherings/:id/feedback { emoji: 'good' }`
  - Map emoji to score: meh=1, okay=2, good=3, great=4, amazing=5
  - `INSERT INTO gathering_feedback`
  - This data feeds the recommendation algorithm (Task 1.1 Step 4)
- **DB:** INSERT INTO gathering_feedback

### 1.6.2 Save connections
- **Frontend:** Attendee cards with "Save" button, shared tags highlighted
- **Backend:** `GET /api/gatherings/:id/attendees`
  - Return attendees with their tags
  - Compute shared_tags between current user and each attendee
  - Return `{ attendees: [{ user, tags, shared_tags }] }`
- **Backend:** `POST /api/users/:id/follow` (auto-suggest follow)
  - INSERT INTO follows
  - Create notification: "X started following you"
  - If mutual → both can now DM freely
- **DB:** INSERT INTO follows; INSERT INTO notifications

### 1.6.3 Share as post (links to Task 3.3)
- **Frontend:** "Share your experience" button → opens post editor
- **Pre-fill:** linked_gathering_id, suggest gathering's tags as hashtags
- This creates the **CONTENT FLYWHEEL:** attend → post → others see → attend

## 1.7 Store Feedback (BACKEND / SYSTEM)
- **Trigger:** After 1.6.1 feedback is submitted
- **Backend:** Background job / trigger function:
  - Store rating + all gathering_tags as a preference signal
  - UPDATE recommendation weights for this user:
    - If rated 'amazing' for a gathering tagged 'Korean' + 'Food' → increase affinity score for 'Korean' and 'Food' tags
    - If rated 'meh' for 'Study' tag → decrease weight for 'Study' recommendations
    - Algorithm: exponential moving average of ratings per tag
  - Store in `user_tag_affinity` table:
    - `UPDATE: new_score = (old_score * count + new_rating) / (count + 1)`
- **This is the FEEDBACK LOOP that makes Task 1.1 smarter over time**
