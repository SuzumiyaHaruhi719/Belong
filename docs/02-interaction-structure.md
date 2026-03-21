# Belong — Interaction Structure & Screen Architecture

**For Claude Code Agent / Vibe Coding Reference**
Last updated: 2026-03-21

---

## 1. Navigation Architecture

### 1.1 Bottom Tab Bar (5 tabs)

```
Tab 1: Gatherings   (icon: house)        → Task 1 — Discover & Attend
Tab 2: Posts         (icon: grid.2x2)     → Task 2 — Browse & Interact
Tab 3: Create        (icon: plus.circle)  → Task 3 — Create Gathering or Post
Tab 4: Chat          (icon: bubble.left)  → Task 4 — Notifications + DMs + Groups
Tab 5: Profile       (icon: person)       → Task 5 — Profile + Social + Settings
```

### 1.2 Tab Bar Behavior

| Behavior | Rule |
|----------|------|
| Badge on Chat tab | Sum of unread notifications + unread DM messages |
| Create tab tap | Opens bottom-sheet selector (BS01), does not navigate to a full screen |
| Re-tap current tab | Scrolls to top if already on that tab |
| Hide on push | Tab bar hides when pushing into detail screens (gathering detail, post detail, DM thread, settings) |
| Default tab on launch | Tab 1 (Gatherings) for new users; last-used tab for returning users |

### 1.3 Navigation Stack per Tab

```
Tab 1 — Gatherings
  S12  Gatherings Home Feed
  └── S13  Gathering Detail
      └── S14  Group Chat (post-join)
      └── S15  Attendee List
      └── S16  Reflect & Connect (post-event)

Tab 2 — Posts
  S20  Post Feed (waterfall grid)
  └── S21  Post Detail (carousel + comments)
      └── S22  Comment Thread (nested replies)
  └── S23  User Profile (other user, pushed from post)
  └── S24  Hashtag Feed (posts filtered by tag)

Tab 3 — Create (bottom sheet only)
  BS01  Create Selector
  └── S30  Create Gathering: Pick Template
      └── S31  Create Gathering: Customize Details
          └── S32  Create Gathering: Preview & Publish
  └── S33  Create Post: Editor
      └── S34  Create Post: Visibility & Link
          └── S35  Create Post: Preview & Publish

Tab 4 — Chat
  S40  Chat Hub (segmented: Notifications | DMs | Groups)
  └── S41  Notification Feed
  └── S42  DM Conversation List
      └── S43  DM Thread
  └── S44  Group Chat List
      └── S45  Group Chat Thread
  └── S46  New DM (user search)

Tab 5 — Profile
  S50  My Profile
  └── S51  Edit Profile
  └── S52  My Gatherings (hosted/attended/upcoming/saved)
  └── S53  My Posts Grid
  └── S54  Saved Posts
  └── S55  Following List
  └── S56  Followers List
  └── S57  Mutuals List
  └── S58  Browse History (posts + gatherings tabs)
  └── S59  Settings
      └── S60  Privacy Settings
      └── S61  Notification Settings
      └── S62  Blocked Users
      └── S63  Language Settings
```

---

## 2. Screen Architecture Table

### 2.1 Onboarding Screens (S01-S11)

| ID | Screen | HTA Ref | UI Pattern | Entry Point |
|----|--------|---------|------------|-------------|
| S01 | Welcome / Landing | 0.1 | Full-bleed hero + CTA | App launch (logged out) |
| S02 | Email Entry | 0.1.1 | Single-field form | S01 tap "Get Started" |
| S03 | OTP Verification | 0.1.2 | 6-digit code input + timer | S02 submit |
| S04 | Set Password | 0.1.3 | Password field + strength indicators | S03 verify success |
| S05 | Set Username | 0.1.4 | Single-field + live availability | S04 submit |
| S06 | Choose Avatar | 0.2.1 | 8-preset grid + upload | S05 submit |
| S07 | Language Preference | 0.2.3 | Scrollable list with flags | S06 submit |
| S08 | Select City | 0.3.1 | Searchable dropdown | S07 submit |
| S09 | Select School | 0.3.2 | Filtered dropdown by city | S08 submit |
| S10 | Cultural Tags | 0.4.1-0.4.3 | Multi-select chip cloud (3 categories) | S09 submit |
| S11 | Onboarding Complete | 0.4 done | Celebration + CTA "Explore" | S10 submit or skip |

### 2.2 Gatherings Tab (S12-S16)

| ID | Screen | HTA Ref | UI Pattern | Entry Point |
|----|--------|---------|------------|-------------|
| S12 | Gatherings Home Feed | 1.1, 1.2 | Hero top-pick card + scrollable list with filter pills | Tab 1 tap |
| S13 | Gathering Detail | 1.3 | Full-width image + info card + Join/Maybe/Save buttons | S12 tap card |
| S14 | Gathering Group Chat | 1.5 | Message thread + text input | S13 post-join |
| S15 | Attendee List | 1.6.2 | User cards with shared tags highlighted | S13 tap attendees |
| S16 | Reflect & Connect | 1.6 | Emoji rating + attendee save + share CTA | Push notification after event ends |

### 2.3 Posts Tab (S20-S24)

| ID | Screen | HTA Ref | UI Pattern | Entry Point |
|----|--------|---------|------------|-------------|
| S20 | Post Feed | 2.1 | 2-column masonry/waterfall grid, pull-to-refresh | Tab 2 tap |
| S21 | Post Detail | 2.2, 2.3, 2.4 | Image carousel + text + like/save/share bar + comments | S20 tap post card |
| S22 | Comment Thread | 2.4 | Nested reply list + @mention input | S21 tap comment or "View all" |
| S23 | Other User Profile | 2.5 | Profile header + posts grid + Follow button | S21 tap author avatar |
| S24 | Hashtag Feed | 2.1 variant | Waterfall grid filtered by #tag + tag header | S21 tap hashtag |

### 2.4 Create Tab (S30-S35)

| ID | Screen | HTA Ref | UI Pattern | Entry Point |
|----|--------|---------|------------|-------------|
| S30 | Gathering: Pick Template | 3.2.1 | Template card grid (6 types) | BS01 tap "Create Gathering" |
| S31 | Gathering: Customize | 3.2.2 | Multi-section form with smart defaults | S30 tap template |
| S32 | Gathering: Preview & Publish | 3.2.3 | Card preview + description + publish/draft | S31 tap "Next" |
| S33 | Post: Editor | 3.3.1, 3.3.2 | Image picker grid + text editor with #autocomplete | BS01 tap "Create Post" |
| S34 | Post: Visibility & Link | 3.3.3 | Visibility radio + gathering link dropdown | S33 tap "Next" |
| S35 | Post: Preview & Publish | 3.3.4 | Full post preview + publish button | S34 tap "Next" |

### 2.5 Chat Tab (S40-S46)

| ID | Screen | HTA Ref | UI Pattern | Entry Point |
|----|--------|---------|------------|-------------|
| S40 | Chat Hub | 4.1, 4.2, 4.3 | Segmented control (Notifications / DMs / Groups) | Tab 4 tap |
| S41 | Notification Feed | 4.1 | Grouped notification list, mark-all-read | S40 "Notifications" segment |
| S42 | DM Conversation List | 4.2.1 | Conversation rows sorted by last message | S40 "DMs" segment |
| S43 | DM Thread | 4.2.2, 4.2.3 | Message bubbles + text input + image + share-post | S42 tap conversation |
| S44 | Group Chat List | 4.3 | Gathering group rows | S40 "Groups" segment |
| S45 | Group Chat Thread | 4.3 | Message bubbles (same component as S43) | S44 tap group |
| S46 | New DM | 4.2.5 | User search + start conversation | S42 tap compose button |

### 2.6 Profile Tab (S50-S63)

| ID | Screen | HTA Ref | UI Pattern | Entry Point |
|----|--------|---------|------------|-------------|
| S50 | My Profile | 5.1 | Avatar + name + bio + stats row (following/followers/mutuals) + tab bar (posts/gatherings) | Tab 5 tap |
| S51 | Edit Profile | 5.1 | Form: avatar, display name, bio, city, school, tags | S50 tap edit icon |
| S52 | My Gatherings | 5.3 | Segmented list (hosted/attended/upcoming/saved) | S50 tap "Gatherings" tab |
| S53 | My Posts Grid | 5.4 | 3-column thumbnail grid | S50 tap "Posts" tab (inline) |
| S54 | Saved Posts | 5.4 variant | Waterfall grid of bookmarked posts | S50 tap bookmark icon |
| S55 | Following List | 5.2.1 | User rows with unfollow button | S50 tap following count |
| S56 | Followers List | 5.2.2 | User rows with follow-back button | S50 tap followers count |
| S57 | Mutuals List | 5.2.3 | User rows with DM shortcut | S50 tap mutuals count |
| S58 | Browse History | 5.5 | Segmented tabs (posts/gatherings) with chronological list | S50 tap history icon |
| S59 | Settings | 5.6 | Grouped list (privacy, notifications, blocked, language, logout) | S50 tap gear icon |
| S60 | Privacy Settings | 5.6.1 | Toggle/picker list | S59 tap "Privacy" |
| S61 | Notification Settings | 5.6.2 | Toggle list per notification type | S59 tap "Notifications" |
| S62 | Blocked Users | 5.6.5 | User rows with unblock button | S59 tap "Blocked Users" |
| S63 | Language Settings | 0.2.3, 5.6 | Language list with flags | S59 tap "Language" |

### 2.7 Bottom Sheets (BS01-BS05)

| ID | Sheet | Trigger | Contents |
|----|-------|---------|----------|
| BS01 | Create Selector | Tab 3 tap | Two large buttons: "Create Gathering" + "Create Post" |
| BS02 | Share Post | S21 tap share icon | Options: Copy link, Share in DM (opens conversation picker), Share externally |
| BS03 | Report / Block | S21 or S23 long-press or "..." menu | Options: Report post/user, Block user |
| BS04 | Gathering Actions | S13 "..." menu | Options: Share, Report, Cancel (if host) |
| BS05 | Image Viewer | S21 tap image in carousel | Full-screen zoomable image with swipe-to-dismiss |

### 2.8 Screen Count Summary

| Section | Screens | IDs |
|---------|---------|-----|
| Onboarding | 11 | S01-S11 |
| Gatherings Tab | 5 | S12-S16 |
| Posts Tab | 5 | S20-S24 |
| Create Tab | 6 | S30-S35 |
| Chat Tab | 7 | S40-S46 |
| Profile Tab | 14 | S50-S63 |
| Bottom Sheets | 5 | BS01-BS05 |
| **Total** | **53** | |

---

## 3. Interaction Patterns

### 3.1 Waterfall / Masonry Grid (Posts Feed — S20, S24, S53, S54)

```
Layout: 2-column staggered grid
Card anatomy:
  ┌────────────┐  ┌────────────┐
  │            │  │  Cover     │
  │  Cover     │  │  Image     │
  │  Image     │  │            │
  │  (variable │  ├────────────┤
  │   height)  │  │ Title      │
  ├────────────┤  │ ♥ 42  💬 5 │
  │ Title      │  └────────────┘
  │ ♥ 128 💬 23│
  └────────────┘
```

| Property | Value |
|----------|-------|
| Column count | 2 |
| Gutter | 8pt |
| Card corner radius | 12pt |
| Image aspect ratio | Preserved from original (variable height) |
| Text truncation | Title: 2 lines max; Body hidden on card |
| Tap target | Entire card → push S21 |
| Lazy loading | Load images as cards enter viewport (200pt prefetch buffer) |
| Skeleton | Gray shimmer rectangles matching card layout |
| Pagination | Cursor-based infinite scroll, load 20 posts per page |
| Pull-to-refresh | Standard iOS pull-down indicator |

### 3.2 Image Carousel (Post Detail — S21)

```
┌──────────────────────────┐
│                          │
│    ◄  [  Image  ]  ►     │
│                          │
│      ● ● ○ ○ ○          │  ← page indicator dots
└──────────────────────────┘
```

| Property | Value |
|----------|-------|
| Swipe direction | Horizontal |
| Page indicator | Dot row below image; filled = current, outline = other |
| Pinch-to-zoom | Opens BS05 (full-screen image viewer) |
| Tap | Opens BS05 |
| Max images per post | 9 |
| Aspect ratio | Images displayed at original aspect ratio, max height 70% of screen |
| Preloading | Preload adjacent 1 image left and right |

### 3.3 Like Toggle (Heart Icon — S20 card, S21)

| State | Appearance | Action |
|-------|------------|--------|
| Not liked | Outline heart (gray) | Tap → fill red + scale-bounce animation + increment count |
| Liked | Filled heart (red) | Tap → outline gray + decrement count |
| Animation | 0.2s spring scale from 1.0 → 1.3 → 1.0 | Haptic feedback (light impact) |
| Double-tap on image | Triggers like (if not already liked) + large heart overlay animation | Same as tap heart |
| Optimistic update | Immediately toggle UI; revert on API failure | Show toast "Something went wrong" on failure |

### 3.4 Comment Thread with @Mentions and Nested Replies (S21, S22)

```
┌─────────────────────────────────┐
│ 👤 username_1              2h   │
│ This looks amazing! #KoreanBBQ  │
│ ♥ 3   Reply                     │
│                                 │
│   👤 username_2           1h    │  ← nested reply (indented)
│   @username_1 I know right!     │
│   ♥ 1   Reply                   │
│                                 │
│ 👤 username_3              30m  │
│ Where is this?                  │
│ ♥ 0   Reply                     │
├─────────────────────────────────┤
│ Add a comment... [@mention]  ➤  │  ← sticky input at bottom
└─────────────────────────────────┘
```

| Property | Value |
|----------|-------|
| Nesting depth | Max 1 level (reply-to-reply flattened to same level with @mention) |
| @mention autocomplete | Triggered by typing "@", fuzzy search on username/display_name |
| @mention display | Blue text, tappable → navigate to user profile |
| Reply action | Tap "Reply" → pre-fills @username in input, focuses keyboard |
| Sort | Top-level comments sorted by newest first; replies sorted by oldest first within thread |
| Pagination | Load 20 comments per page, infinite scroll |
| Like comment | Heart icon per comment, same toggle pattern as post like |

### 3.5 Share Post in DM (Embedded Card — S43, S45)

```
┌─ Message bubble ───────────────┐
│ ┌─ Shared Post Card ─────────┐ │
│ │ [Thumbnail]  Title...      │ │
│ │              @author       │ │
│ │              ♥ 42  💬 5    │ │
│ └────────────────────────────┘ │
│ "Check this out!"              │
└────────────────────────────────┘
```

| Property | Value |
|----------|-------|
| Card size | Compact: 60pt thumbnail + 2-line text |
| Tap | Navigate to post detail (S21) via deep link |
| Fallback | If post deleted, show "This post is no longer available" |

### 3.6 Follow / Unfollow Toggle

| Context | Location | Button Style |
|---------|----------|-------------|
| Post detail | Next to author avatar (S21) | Pill button: "Follow" / "Following" |
| Other user profile | Below bio (S23) | Full-width button: "Follow" / "Following" / "Follow Back" |
| Attendee list | Inline per row (S15) | Small pill: "Follow" / "Following" |
| Followers list | Inline per row (S56) | Small pill: "Follow Back" / "Following" |
| Mutual follow | Anywhere | "Following" label + green mutual badge |

| State | Appearance |
|-------|------------|
| Not following | Filled accent button "Follow" |
| Following (not mutual) | Outline button "Following" |
| Mutual follow | Outline button "Following" + small mutual icon |
| Follow back available | Filled accent button "Follow Back" |
| Tap "Following" | Confirmation alert "Unfollow @username?" → confirm to unfollow |

### 3.7 Notification Badge (Chat Tab)

| Property | Value |
|----------|-------|
| Badge location | Top-right of Chat tab icon |
| Badge content | Total count of unread notifications + unread DM messages |
| Max display | "99+" for counts > 99 |
| Color | Red filled circle with white text |
| Clear behavior | Entering S41 marks all notifications as read; entering S43 marks that conversation as read |
| Realtime update | WebSocket subscription on `user:{id}:notifications` channel |

### 3.8 DM Mutual-Follow Gating (S43)

```
┌──────────────────────────────┐
│ [Message thread area]        │
│                              │
├──────────────────────────────┤
│ If NOT mutual follow:        │
│                              │
│  ┌──────────────────────┐    │
│  │ 🔒 You can send 1     │    │
│  │ message. Follow each  │    │
│  │ other to chat freely. │    │
│  └──────────────────────┘    │
│                              │
│ [input disabled after 1 msg] │
└──────────────────────────────┘
```

| Condition | Behavior |
|-----------|----------|
| Mutual follow | Unlimited messages, full chat experience |
| Not mutual, 0 messages sent | Allow 1 message; show info banner above input |
| Not mutual, 1 message sent | Input disabled; show "Follow each other to chat more" banner + Follow button |
| Blocked user | Conversation hidden entirely |

### 3.9 Hashtag Autocomplete (Post Editor — S33)

| Property | Value |
|----------|-------|
| Trigger | User types "#" character in text editor |
| Dropdown | Floating list below cursor, max 5 suggestions |
| Source | `GET /api/tags/trending?q=:query` (debounced 300ms) |
| Selection | Tap suggestion → insert tag + space, dismiss dropdown |
| Manual tag | Continue typing after "#" → accepted as custom tag on space/return |
| Display | Tags rendered as blue text in editor |
| Parsing | All #tags extracted at publish time; stored without "#" prefix |

### 3.10 Gathering Template Wizard (S30 → S31 → S32)

```
Step 1: Pick Template (S30)
  ┌──────┐ ┌──────┐ ┌──────┐
  │ 🍜   │ │ 📖   │ │ 🎉   │
  │ Food │ │Study │ │Hang  │
  └──────┘ └──────┘ └──────┘
  ┌──────┐ ┌──────┐ ┌──────┐
  │ 🌍   │ │ 🙏   │ │ ⚽   │
  │Cultur│ │Faith │ │Active│
  └──────┘ └──────┘ └──────┘

Step 2: Customize (S31)
  [Title           ]   ← text input
  [Cultural Tags   ]   ← multi-select chips (pre-filled from user tags)
  [Date] [Time     ]   ← pickers
  [Location        ]   ← text + optional map
  [Max attendees: 6]   ← stepper (pre-filled from template)
  [Visibility: Matching Tags ▼]  ← picker
  [Vibe: Low-key ▼]   ← picker

Step 3: Preview & Publish (S32)
  ┌─ Card Preview ─────────────┐
  │ 🍜 Korean BBQ Night        │
  │ Thu 7 PM · Gen Korean BBQ  │
  │ 3/6 spots · #Korean #Food  │
  └────────────────────────────┘
  [Description: ______________ ]
  [ Save Draft ]  [ Publish ✓ ]
```

### 3.11 Post Editor Flow (S33 → S34 → S35)

```
Step 1: Editor (S33)
  ┌──────────────────────────┐
  │ [+] [img] [img] [img]   │  ← image picker grid (max 9, drag to reorder)
  │                          │
  │ Write something...       │  ← text editor with #autocomplete
  │ #KoreanBBQ #FoodieLife   │
  │                          │
  │              [ Next → ]  │
  └──────────────────────────┘

Step 2: Visibility & Link (S34)
  Visibility:
    ○ Public
    ● School only
    ○ Followers only

  Link a gathering (optional):
    [ Korean BBQ Night — Mar 25 ▼ ]

  [ ← Back ]        [ Next → ]

Step 3: Preview & Publish (S35)
  ┌─ Post Preview ─────────────┐
  │ [Image carousel preview]   │
  │ Content text...            │
  │ #KoreanBBQ #FoodieLife     │
  │ 🔗 Korean BBQ Night        │
  │ 👁 School only              │
  └────────────────────────────┘
  [ ← Back ]      [ Publish ✓ ]
```

---

## 4. HTA-to-UI Pattern Mapping

This section maps every HTA leaf task to its concrete UI pattern, ensuring nothing is lost between task analysis and implementation.

### 4.1 Task 0: Onboarding

| HTA Task | Screen | UI Pattern | Gesture |
|----------|--------|------------|---------|
| 0.1.1 Enter .edu email | S02 | Single text field + "Continue" button | Type → tap |
| 0.1.2 Enter OTP | S03 | 6-digit segmented input + resend link (60s cooldown) | Type → auto-submit on 6th digit |
| 0.1.3 Set password | S04 | Password field + 4 strength indicators (checkmarks) | Type → tap |
| 0.1.4 Set username | S05 | Text field + live "available" / "taken" label (debounced 500ms) | Type → tap |
| 0.2.1 Choose avatar | S06 | 2x4 grid of preset emojis + camera upload button | Tap to select |
| 0.2.3 Set language | S07 | Scrollable list rows with flag + language name | Tap to select |
| 0.3.1 Select city | S08 | Searchable dropdown with autocomplete | Type to filter → tap |
| 0.3.2 Select school | S09 | Dropdown filtered by selected city | Tap to select |
| 0.4.1-3 Cultural tags | S10 | 3-section chip cloud (background, language, interest) | Tap chips to toggle |
| 0.4.4 Skip | S10 | "Skip for now" link at bottom | Tap |

### 4.2 Task 1: Gatherings

| HTA Task | Screen | UI Pattern | Gesture |
|----------|--------|------------|---------|
| 1.1 See top pick | S12 | Hero card (image + title + tags + trust signals) | Tap card → S13 |
| 1.2 Browse feed | S12 | Scrollable list below hero; filter pills (tag, date) + search bar | Scroll, tap filter, type search |
| 1.3.1 Join | S13 | Green "Join" button → state change to "You're in!" | Tap |
| 1.3.2 Maybe | S13 | Amber "Maybe" button | Tap |
| 1.3.3 Save | S13 | Bookmark icon toggle in nav bar | Tap |
| 1.4 Confirmation | S13 | Inline success banner + "Add to Calendar" button | Tap calendar |
| 1.5 Group chat | S14 | Chat thread (same component as S45) | Type + send |
| 1.6.1 Emoji check-in | S16 | 5 large emoji buttons, one-tap select | Tap |
| 1.6.2 Save connections | S16 | Attendee cards with "Follow" pill + shared tags | Tap follow |
| 1.6.3 Share as post | S16 | "Share your experience" CTA → opens S33 pre-filled | Tap |

### 4.3 Task 2: Posts

| HTA Task | Screen | UI Pattern | Gesture |
|----------|--------|------------|---------|
| 2.1 Browse feed | S20 | 2-column waterfall grid | Scroll, tap card |
| 2.2 View post detail | S21 | Image carousel + text + engagement bar | Swipe images, scroll |
| 2.3 Like post | S21, S20 | Heart icon toggle + bounce animation | Tap heart or double-tap image |
| 2.4 Comment | S21, S22 | Text input at bottom + nested reply list | Type, tap reply, @mention |
| 2.5 Follow poster | S21, S23 | "Follow" pill button next to author | Tap |
| 2.6.1 Save post | S21 | Bookmark icon toggle in engagement bar | Tap |
| 2.6.2 Share in chat | S21 → BS02 | Share sheet → conversation picker → send | Tap share → select convo |
| 2.7 Jump to gathering | S21 | "View Gathering" button (if linked_gathering_id) | Tap → push S13 |
| 2.8.1 Report post | S21 → BS03 | "..." menu → Report option → reason picker | Tap → select → submit |
| 2.8.2 Block user | S21 → BS03 | "..." menu → Block option → confirmation alert | Tap → confirm |

### 4.4 Task 3: Create

| HTA Task | Screen | UI Pattern | Gesture |
|----------|--------|------------|---------|
| 3.1 Selector | BS01 | Two large buttons with icons and descriptions | Tap |
| 3.2.1 Pick template | S30 | 2x3 grid of template cards with emoji + label | Tap |
| 3.2.2 Customize | S31 | Multi-section form (title, tags, date, location, max, visibility, vibe) | Fill fields |
| 3.2.3 Preview & publish | S32 | Card preview + description + publish/draft buttons | Tap publish |
| 3.3.1 Upload images | S33 | Image picker grid: [+] button + thumbnails, drag-to-reorder | Tap [+], long-press drag |
| 3.3.2 Write text + tags | S33 | Text editor with # autocomplete dropdown | Type, tap suggestion |
| 3.3.3 Visibility + link | S34 | Radio buttons + dropdown | Tap |
| 3.3.4 Publish | S35 | Full preview + "Publish" button | Tap |

### 4.5 Task 4: Chat

| HTA Task | Screen | UI Pattern | Gesture |
|----------|--------|------------|---------|
| 4.1 Notifications | S40, S41 | Segmented control → notification list grouped by type | Tap segment, scroll |
| 4.1 Tap notification | S41 | Tap row → deep link to target (post detail, gathering, user) | Tap |
| 4.2.1 DM list | S40, S42 | Segmented control → conversation rows with last message preview | Tap segment, scroll |
| 4.2.2 Open DM | S43 | Message bubbles + text input + image button + share-post button | Scroll, type, send |
| 4.2.3 Send message | S43 | Text input → send button (or mutual-gating banner if restricted) | Type → tap send |
| 4.2.4 Share post in DM | S43 | Embedded post card in message bubble | Tap card → S21 |
| 4.2.5 New DM | S46 | User search field + results list → start conversation | Type → tap user → S43 |
| 4.3 Group chats | S40, S44 | Segmented control → gathering group rows | Tap segment, scroll |
| 4.3 Group thread | S45 | Same chat component as S43, no mutual-follow restriction | Type → send |

### 4.6 Task 5: Profile

| HTA Task | Screen | UI Pattern | Gesture |
|----------|--------|------------|---------|
| 5.1 View profile | S50 | Avatar + name + bio + stats row + inline tab bar (Posts / Gatherings) | Scroll |
| 5.1 Edit profile | S51 | Form fields: avatar, name, bio, city, school, tags | Tap edit icon → fill → save |
| 5.2.1 Following | S55 | User list with "Following" pill (tap → unfollow confirm) | Scroll, tap |
| 5.2.2 Followers | S56 | User list with "Follow Back" or "Following" pill | Scroll, tap |
| 5.2.3 Mutuals | S57 | User list with "Message" shortcut button | Scroll, tap |
| 5.3 My Gatherings | S52 | Segmented tabs: Hosted / Attended / Upcoming / Saved | Tap segment, scroll |
| 5.4 My Posts | S53 | 3-column thumbnail grid (tap → S21) | Scroll, tap |
| 5.5 Browse History | S58 | Segmented tabs: Posts / Gatherings, chronological list | Tap segment, scroll |
| 5.6.1 Privacy | S60 | Pickers: profile visibility, DM permissions | Tap to change |
| 5.6.2 Notifications | S61 | Toggle switches per type (likes, comments, follows, reminders, new posts) | Tap toggle |
| 5.6.5 Blocked users | S62 | User list with "Unblock" button | Tap unblock |
| 5.6.6 Logout | S59 | "Log Out" button → confirmation alert → clear session | Tap → confirm |

---

## 5. State Handling

### 5.1 Empty States

| Screen | Condition | Display |
|--------|-----------|---------|
| S12 Gatherings Feed | No gatherings in city | Illustration + "No gatherings yet. Be the first to create one!" + CTA to Create |
| S12 Gatherings Feed | No tag matches | "No matches for your interests. Try broadening your tags in Profile." |
| S20 Post Feed | No posts in feed | Illustration + "Nothing here yet. Follow people or explore hashtags!" |
| S24 Hashtag Feed | No posts with tag | "#TagName — No posts yet. Be the first to share!" |
| S41 Notifications | Zero notifications | Illustration + "All caught up! No new notifications." |
| S42 DM List | No conversations | Illustration + "No messages yet. Start a conversation!" + CTA to S46 |
| S44 Group List | No group chats | "Join a gathering to unlock group chat!" |
| S52 My Gatherings | No gatherings (per segment) | Per-segment: "You haven't hosted/attended/saved any gatherings yet." |
| S53 My Posts | No posts | "Share your first post!" + CTA to Create |
| S54 Saved Posts | No saved posts | "Bookmark posts you love and find them here." |
| S55-S57 Social Lists | Empty following/followers/mutuals | "No one here yet." |
| S58 Browse History | No history | "Your browsing history will appear here." |
| S62 Blocked Users | No blocks | "You haven't blocked anyone." |

### 5.2 Loading States

| Pattern | Where Used | Behavior |
|---------|------------|----------|
| Skeleton shimmer | S12 (list cards), S20 (waterfall cards), S41 (notification rows), S42 (conversation rows) | Gray animated rectangles matching the layout shape |
| Spinner overlay | S13 (join action), S32 (publish), S35 (publish) | Centered spinner with dimmed background; blocks interaction |
| Pull-to-refresh | S12, S20, S41, S42, S44 | iOS standard pull-down spinner at top |
| Inline spinner | S03 (OTP verify), S05 (username check), S33 (image upload) | Small spinner next to the input field |
| Pagination loader | S12, S20, S22, S41, S42, S55-S58 | Small spinner at bottom of list during infinite scroll |
| Image placeholder | S20 (waterfall), S21 (carousel) | Low-resolution blurred thumbnail → full image crossfade |

### 5.3 Error States

| Error Type | Display | Recovery |
|------------|---------|----------|
| Network offline | Persistent banner at top: "No internet connection" | Auto-retry when connection restored; show cached data if available |
| API 500 | Inline error card: "Something went wrong" + "Try Again" button | Tap retry → re-fetch |
| API 401 (token expired) | Silent refresh token attempt; if fails → redirect to S01 | Auto-redirect |
| API 403 (blocked/private) | "This content is not available" | Back button |
| API 404 (deleted content) | "This post/gathering has been removed" | Back button |
| Image upload failure | Red border on failed image + retry icon overlay | Tap to retry upload |
| Join gathering full | Button disabled: "This gathering is full" | Save/Maybe still available |
| Join gathering cancelled | Button disabled: "This gathering was cancelled" | Back button |
| DM send failure | Message bubble shows red "!" + "Tap to retry" | Tap to resend |
| Publish failure | Alert: "Failed to publish. Your draft has been saved." | Retry or edit draft |
| OTP expired | Inline error: "Code expired" + "Resend" button | Tap resend |
| Username taken | Inline error: "This username is already taken" | Edit username field |
| Rate limit (OTP) | "Too many attempts. Try again in X minutes." | Wait and retry |

### 5.4 Optimistic Updates

| Action | Optimistic Behavior | Rollback on Failure |
|--------|---------------------|---------------------|
| Like post | Immediately fill heart + increment count | Revert heart + decrement + toast |
| Unlike post | Immediately outline heart + decrement count | Revert + toast |
| Follow user | Immediately switch to "Following" button state | Revert + toast |
| Unfollow user | Immediately switch to "Follow" button state | Revert + toast |
| Save/bookmark | Immediately toggle bookmark icon | Revert + toast |
| Send message | Immediately append bubble with "sending" state | Show red "!" retry icon |
| Join gathering | Immediately show "You're in!" + increment count | Revert + error alert |

---

## 6. Validation Rules

### 6.1 Onboarding Validation

| Field | Rule | Feedback |
|-------|------|----------|
| Email | Must end with `.edu`; max 255 chars | Inline error: "Please use a .edu email address" |
| OTP | Exactly 6 digits; expires in 10 min | Inline error: "Invalid code" or "Code expired" |
| Password | >= 8 chars, uppercase + lowercase, 1 number, 1 special char | Realtime strength checklist (4 items, green check per rule) |
| Username | 3-30 chars; alphanumeric + underscore only; not reserved | Inline: "Available" (green) or "Taken" (red), debounced 500ms |
| Avatar | jpg/png only; max 5MB | Alert: "Image too large" or "Unsupported format" |
| City | Required; must match cities table | Dropdown enforces valid selection |
| School | Required; must match schools table (filtered by city) | Dropdown enforces valid selection |
| Cultural tags | Optional; min 0, no max | "Skip for now" link |

### 6.2 Gathering Validation

| Field | Rule | Feedback |
|-------|------|----------|
| Title | Required; 1-100 chars | Inline character counter, red at limit |
| Date/Time | Must be in the future | Inline error: "Please select a future date" |
| Location | Required; 1-200 chars | Inline error on empty |
| Max attendees | 2-50 (stepper) | Stepper enforces range |
| Description | Optional; max 2000 chars | Character counter |
| Cultural tags | At least 1 recommended, not enforced | Soft prompt: "Add tags to help people find your gathering" |
| Visibility | Required; default from template | Pre-selected |
| Vibe | Required; default from template | Pre-selected |

### 6.3 Post Validation

| Field | Rule | Feedback |
|-------|------|----------|
| Images | At least 1 required; max 9 | [+] button disabled at 9; inline count "3/9" |
| Image format | jpg/png/heic; max 10MB each | Alert: "Image too large" or "Unsupported format" |
| Image reorder | Drag to reorder; first image = cover | Visual drag handle |
| Content text | Required; 1-5000 chars | Character counter, red near limit |
| Hashtags | Parsed from # in content; max 30 tags | Tags beyond 30 silently ignored |
| Hashtag format | Alphanumeric + underscore after #; no spaces | Auto-terminate tag on space/punctuation |
| Visibility | Required; default "Public" | Radio group |
| Linked gathering | Optional; only user's own gatherings | Dropdown |

### 6.4 Chat Validation

| Field | Rule | Feedback |
|-------|------|----------|
| DM text message | 1-2000 chars | Character counter for long messages |
| DM image | jpg/png; max 10MB | Alert on oversized |
| DM mutual gating | 1 message if not mutual follow | Banner: "Follow each other to chat more" + disabled input |
| Group message | 1-2000 chars; no mutual restriction | Same text input component |
| New DM user search | Min 1 char to search | Results appear after 1 char, debounced 300ms |

### 6.5 Profile Validation

| Field | Rule | Feedback |
|-------|------|----------|
| Display name | 1-50 chars | Inline counter |
| Bio | 0-300 chars | Inline counter |
| Avatar upload | jpg/png; max 5MB; resized to 256x256 | Same as onboarding |
| City/School change | Must match valid entries | Dropdown enforces |
| Tags update | Same chip cloud as onboarding | Immediate save |

---

## 7. Friction Map

Friction points are moments where user intent may be blocked, creating abandonment risk. Each entry identifies the friction, its location, and the mitigation strategy.

### 7.1 Onboarding Friction

| ID | Friction Point | Screen | Severity | Mitigation |
|----|----------------|--------|----------|------------|
| F01 | OTP email not arriving | S03 | High | Resend button (60s cooldown); check-spam hint; rate limit: 3 per hour |
| F02 | Password rules too strict | S04 | Medium | Realtime checklist shows progress; rules visible before typing |
| F03 | Username taken | S05 | Medium | Live availability check; suggest alternatives (append numbers) |
| F04 | Cultural tags overwhelming | S10 | Low | Prominent "Skip" link; categorized sections; max 20 visible per category with "Show more" |

### 7.2 Gatherings Friction

| ID | Friction Point | Screen | Severity | Mitigation |
|----|----------------|--------|----------|------------|
| F05 | No relevant gatherings | S12 | High | Fallback to same-city + soonest; prompt to create one; show trending nearby |
| F06 | Gathering full | S13 | Medium | "Maybe" and "Save" still available; suggest similar gatherings |
| F07 | Social anxiety about joining | S13 | High | Show mutual friends attending; show shared cultural tags; low attendee count (small groups) |
| F08 | Forgotten event | S14 | Medium | Push notification 24h + 1h before; calendar integration at join time |

### 7.3 Posts Friction

| ID | Friction Point | Screen | Severity | Mitigation |
|----|----------------|--------|----------|------------|
| F09 | Empty post feed | S20 | High | Pre-populate with trending + same-school posts; suggest users to follow |
| F10 | Posting anxiety — "is this good enough?" | S33 | High | No follower-count display on new accounts; gentle prompts; drafts auto-saved |
| F11 | Hashtag choice paralysis | S33 | Medium | Autocomplete with trending tags; suggest tags from user's cultural profile |
| F12 | Low engagement on posts | S21 | Medium | Boost new-user posts in school feed for 24h; encourage first likers |
| F13 | Comment toxicity | S22 | Medium | Report/block per comment; future: content moderation filter |

### 7.4 Chat Friction

| ID | Friction Point | Screen | Severity | Mitigation |
|----|----------------|--------|----------|------------|
| F14 | DM rejected (not mutual follow) | S43 | High | Clear explanation banner; "Follow" button inline; 1 free message to introduce yourself |
| F15 | Notification overload | S41 | Medium | Group notifications by type; batch similar (e.g., "5 people liked your post"); notification settings granular toggle |
| F16 | Unwanted DMs | S43 | Medium | Privacy setting: mutual_only (default) or everyone; block/report accessible |
| F17 | No one to message | S42 | Medium | Suggest users from recent gatherings; "People you may know" section |

### 7.5 Profile & Social Friction

| ID | Friction Point | Screen | Severity | Mitigation |
|----|----------------|--------|----------|------------|
| F18 | Empty profile feels lonely | S50 | Medium | Prompt cards: "Add a bio", "Share your first post", "Find people from your culture" |
| F19 | Who to follow? | S55, S56 | Medium | Auto-suggest follows after attending gatherings (Task 1.6.2); "Discover people" section |
| F20 | Profile feels incomplete | S50 | Low | Progress indicator: "Profile 60% complete — add a bio to reach 80%" |

---

## 8. Cross-Tab Navigation Flows

### 8.1 Content Flywheel Flow

```
Attend Gathering (S13 Join)
    ↓
Reflect & Rate (S16 emoji feedback → feeds recommendation engine)
    ↓
Share as Post (S16 CTA → S33 pre-filled with gathering link + tags)
    ↓
Others Browse Feed (S20 → see post in waterfall)
    ↓
View Post Detail (S21 → see linked gathering)
    ↓
Jump to Gathering (S21 "View Gathering" → S13)
    ↓
Attend Gathering (loop continues)
```

### 8.2 Social Graph Growth Flow

```
See post in feed (S20)
    ↓
View post detail (S21) → tap Follow on author
    ↓
Mutual follow established → unlocks unlimited DMs (S43)
    ↓
Chat → discover shared interests → join same gathering (S13)
    ↓
Attend together → reflect → save connections (S16) → more follows
```

### 8.3 Cross-Tab Deep Links

| Source | Action | Destination | Data Passed |
|--------|--------|-------------|-------------|
| S16 "Share as Post" | Tap CTA | S33 (Post Editor) | `linked_gathering_id`, suggested tags |
| S21 "View Gathering" | Tap button | S13 (Gathering Detail) | `gathering_id` |
| S21 tap author | Tap avatar/name | S23 (Other User Profile) | `user_id` |
| S21 tap hashtag | Tap #tag | S24 (Hashtag Feed) | `tag_value` |
| S41 tap notification (like) | Tap row | S21 (Post Detail) | `post_id` |
| S41 tap notification (follow) | Tap row | S23 (Other User Profile) | `user_id` |
| S41 tap notification (comment) | Tap row | S21 (Post Detail) scrolled to comment | `post_id`, `comment_id` |
| S41 tap notification (gathering) | Tap row | S13 (Gathering Detail) | `gathering_id` |
| S43 tap shared post card | Tap card | S21 (Post Detail) | `post_id` |
| S50 tap "Posts" tab | Tap segment | S53 (My Posts Grid) inline | — |
| S50 tap "Gatherings" tab | Tap segment | S52 (My Gatherings) inline | — |
| S53 tap post thumbnail | Tap image | S21 (Post Detail) | `post_id` |
| S52 tap gathering row | Tap row | S13 (Gathering Detail) | `gathering_id` |
| S23 tap post in grid | Tap image | S21 (Post Detail) | `post_id` |

---

## 9. Design Principles

These principles guide every screen and interaction decision in the app.

### 9.1 Cultural Safety First
Every interaction should make multicultural students feel welcomed, not othered. Cultural tags are opt-in, never mandatory. Language preferences respected throughout. Small group sizes (default 6) reduce social anxiety.

### 9.2 Progressive Disclosure
New users see the simplest version of each screen. Advanced features (hashtag autocomplete, visibility settings, linked gatherings) reveal as users engage more. Onboarding tags are skippable — the recommendation engine improves as users interact.

### 9.3 One Primary Action Per Screen
Each screen has one clear primary CTA. S13: "Join". S33: "Next". S35: "Publish". Secondary actions exist but are visually subdued.

### 9.4 Optimistic & Forgiving
All social actions (like, follow, save, join) are optimistic with instant feedback. Destructive actions (unfollow, leave gathering) require confirmation. Drafts auto-save. Undo is preferred over "Are you sure?" where possible.

### 9.5 Content Over Chrome
Post feed uses edge-to-edge images. Gathering cards are image-forward. Profile shows content grid prominently. Navigation chrome is minimal — tab bar hides on push, status bar blurs over content.

### 9.6 Realtime Feels Alive
Badge counts update via WebSocket. New messages appear instantly. Typing indicators (future). Attendee counts update live when someone joins. The app should feel like a living community, not a static directory.
