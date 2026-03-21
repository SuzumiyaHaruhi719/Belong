# Task 3: Create Tab — Gatherings & Posts

## 3.1 Tap (+) → popup selector
- **Frontend:** Bottom sheet / modal with two options
  - "Create Gathering" (icon + description)
  - "Create Post" (icon + description)
- **Backend:** No API call needed (pure UI)

## 3.2 Create Gathering (template wizard)

### 3.2.1 Pick template
- **Frontend:** Template cards with preset defaults
- **Backend:** `GET /api/gatherings/templates`
  - Return preset templates with default values:
    ```json
    [{ "type": "food", "emoji": "🍜", "default_max": 6,
       "default_visibility": "matching_tags", "default_vibe": "low_key" }, ...]
    ```
  - Templates: food, study, hangout, cultural, faith, active

### 3.2.2 Customize details
- **Frontend:** Form with smart defaults pre-filled from template
  - Title (text input)
  - Cultural tags (multi-select, pre-filled from user's own tags)
  - Date + time (pickers)
  - Location (text input + optional map)
  - Max attendees (pre-filled from template)
  - Visibility (pre-filled from template)
  - Vibe (pre-filled from template)
- **Backend:** No call yet (all local state)

### 3.2.3 Preview & Publish
- **Frontend:** Card preview + description editor + publish/draft buttons
- **Backend:** `POST /api/gatherings`
  - Validate all required fields
  - INSERT INTO gatherings
  - INSERT INTO gathering_tags (batch)
  - INSERT INTO gathering_members (host as first member, status='joined')
  - CREATE conversation for this gathering (type='gathering_group')
  - If not draft: push notifications to users with matching tags in same city:
    ```sql
    SELECT users WHERE city = :city AND id IN (
      SELECT user_id FROM user_tags WHERE tag_value IN (:gathering_tags)
    )
    ```
  - Return `{ gathering }`
- **DB:** INSERT gatherings, gathering_tags, gathering_members, conversations, conversation_members; batch INSERT notifications

## 3.3 Create Post

### 3.3.1 Upload images
- **Frontend:** Multi-image picker (max 9), drag to reorder
- **Backend:** `POST /api/uploads/images` (multipart, per image)
  - Accept jpg/png/heic, max 10MB each
  - Resize: create thumbnail (400px) + full (1200px)
  - Upload to storage bucket
  - Return `{ image_url, thumbnail_url, width, height }`
- **Storage:** `/posts/{user_id}/{uuid}.jpg`

### 3.3.2 Write text + #hashtags
- **Frontend:** Text editor with hashtag detection (auto-suggest on #)
- **Backend:** `GET /api/tags/trending?q=:query` (autocomplete for hashtags)
- **Parse:** Extract all #tags from content at submission time

### 3.3.3 Set visibility + link gathering
- **Frontend:**
  - Visibility picker: Public / School only / Followers only
  - "Link a gathering" (optional) → dropdown of user's gatherings
- **Backend:** No API call (local state)

### 3.3.4 Publish
- **Backend:** `POST /api/posts`
  - INSERT INTO posts (content, visibility, linked_gathering_id, city, school)
  - INSERT INTO post_images (batch, with display_order)
  - INSERT INTO post_tags (extracted from #hashtags in content)
  - Push notifications to followers:
    ```sql
    SELECT follower_id FROM follows WHERE following_id = :user_id
    ```
    → batch INSERT notifications (type='new_post_from_following')
  - Return `{ post }`
- **DB:** INSERT posts, post_images, post_tags; batch INSERT notifications
