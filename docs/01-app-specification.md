# Belong — App Specification
## Cultural Belonging Platform for International & Multicultural Students

---

## DESIGN SYSTEM

- **Fonts:** Fraunces (headings/display), Plus Jakarta Sans (body/UI). Fallback to system serif and sans-serif.
- **Colors:**
  - Primary: Terracotta `#C47B5A`
  - Background: Warm Cream `#FAF3EB`
  - Text: Dark Brown `#2C2825`
  - Cards/Surfaces: Soft White `#FEFCF9`
  - Accent: Gold `#D4A03C`
  - Success: Soft Green `#4A8A4A`
  - System/Backend indicator: Purple `#7B5FA0`
  - Error/Alert: Red `#C53030`
- **Corner radius:** 16–20pt (generous, organic feel)
- **Shadows:** Soft, warm-toned
- **Target device:** iPhone (responsive to all sizes, design reference iPhone 14 Pro 393×852)
- **Overall mood:** Warm, welcoming, inclusive, not clinical

---

## APP FLOW OVERVIEW

```
First-time user:  Task 0 (onboarding) → Tasks 1–6 (main loop)
Returning user:   Login → Tasks 1–6 (main loop)
Feedback loop:    Task 6 ratings feed back into Task 1–2 recommendations
```

The app has two major sections:
1. **ONE-TIME:** Registration & Onboarding (Task 0) — sequential, mostly required
2. **EVERY SESSION:** Main Loop (Tasks 1–6) — recurring after login

---

## TASK 0: REGISTRATION & ONBOARDING (one-time)

Flow: 0.1 → 0.2 → 0.3 (all required) → 0.4 (skippable)

### Task 0.1: Create Account
Steps (sequential): 0.1.1 → 0.1.2 → 0.1.3 → 0.1.4 → 0.1.5

| Step | Action | Details |
|------|--------|---------|
| 0.1.1 | Enter .edu email | Text input, validate ends with .edu |
| 0.1.2 | Receive & enter OTP | 6-digit verification code sent to email |
| 0.1.3 | Set password | Min 8 chars, must include uppercase, lowercase, number, special char (!@#) |
| 0.1.4 | Set username | Unique username |
| 0.1.5 | Email verified ✓ | Confirmation state, proceed to next screen |

### Task 0.2: Set Up Profile
Steps (sequential): 0.2.1 → 0.2.2 → 0.2.3

| Step | Action | Details |
|------|--------|---------|
| 0.2.1 | Choose avatar | Default options provided, or upload custom |
| 0.2.2 | Set username | Display name (may differ from login username) |
| 0.2.3 | App language | Picker: English, 中文, 한국어, and more |

### Task 0.3: Location & School (required)
Steps (sequential): 0.3.1 → 0.3.2

| Step | Action | Details |
|------|--------|---------|
| 0.3.1 | Select city | Dropdown or search, e.g. Boston |
| 0.3.2 | Select school | Dropdown or search, e.g. NEU, BU, MIT, Harvard |

### Task 0.4: Cultural Tags (skippable)
User can choose from 3 categories, or skip all. Show a prominent "Skip for now" option.

| Step | Action | Details |
|------|--------|---------|
| 0.4.1 | Cultural background | Multi-select chips: Korean, Filipino, Chinese, Indian, Nigerian, Brazilian, etc. |
| 0.4.2 | Language | Multi-select chips: Mandarin, 한국어, Hindi, Tagalog, Portuguese, etc. |
| 0.4.3 | Interests & vibe | Multi-select chips: Food, Study, Chill, Music, Sports, Art, Nightlife, etc. |
| 0.4.4 | Skip for now | Button to skip, can fill later in Profile settings |

---

## LOGIN (returning users)

- Email/phone + password
- After successful login → enter main loop (Tasks 1–6)

---

## TASK 1: OPEN & ORIENT

Purpose: When the user opens the app, immediately show a curated top pick — no quiz or onboarding wall.

| Step | Action | Details |
|------|--------|---------|
| 1.1 | Open app | User launches app, no quiz or extra prompts needed |
| 1.2 | See top pick | System automatically shows a curated "top pick" gathering card based on user's cultural tags + location + past ratings. Card shows: event image, title, cultural tags, location, time, trust signals (attendee count, host rating) |

---

## TASK 2: DISCOVER

Purpose: Recommendation-first browsing. User explores gatherings beyond the top pick.

| Step | Action | Details |
|------|--------|---------|
| 2.1 | Top recommendations | Scrollable feed of recommended gatherings with trust signals (attendee count, ratings, cultural tag matches) |
| 2.2 | Browse | Fallback feed — browse all gatherings if recommendations don't match. Filter/search by tag, date, location |
| 2.3 | Save / Bookmark | Save a gathering for later without joining |

---

## TASK 3: JOIN & CONFIRM

Purpose: Instant join — no approval process, no waiting.

| Step | Action | Details |
|------|--------|---------|
| 3.1 | One-tap join | Single button press to join a gathering instantly |
| 3.2 | Confirm + calendar | Confirmation screen, option to add to device calendar |
| 3.3 | "Maybe" | Low-commitment alternative — express interest without fully joining |

---

## TASK 4: PREPARE

Purpose: Post-join preparation. Only available after user has joined a gathering.

| Step | Action | Details |
|------|--------|---------|
| 4.1 | Message | Access group chat for the gathering. Chat with other attendees and host |
| 4.2 | Reminder | System sends a push notification reminder before the event |

---

## TASK 5: HOST A GATHERING (guided)

Purpose: Let any user create and host their own cultural gathering using templates.

| Step | Action | Details |
|------|--------|---------|
| 5.1 | Pick template | Choose from pre-built gathering templates (e.g. "Potluck Dinner", "Language Exchange", "Movie Night", "Study Group", "Cultural Festival") |
| 5.2 | Customize | Fill in details with smart defaults pre-populated from template: title, description, date/time, location, max attendees, cultural tags |
| 5.3 | Preview & publish | Review the gathering listing, then publish it live to the platform |

---

## TASK 6: REFLECT, CONNECT & FEEDBACK

Purpose: Post-event reflection. Ratings are stored and used to improve future recommendations (feedback loop).

| Step | Action | Details |
|------|--------|---------|
| 6.1 | Emoji check-in | User selects an emoji to rate their experience (e.g. 😊😐😕🎉🤝) |
| 6.2 | Store rating + event tags | SYSTEM/BACKEND: Save the emoji rating and associated event tags to database. This data feeds the recommendation engine. NOT user-facing. |
| 6.3 | Save connections | Optional: save/follow other attendees as connections for future gatherings |

---

## FEEDBACK LOOP (critical system behavior)

```
Task 6.2 (stored ratings + event tags)
    ↓
Recommendation engine processes rating data
    ↓
Task 1.2 (top pick) and Task 2.1 (recommendations) improve over time
```

When a user rates positively, future recommendations prioritize: similar cultural tags, same host (if highly rated), similar gathering types, same location area.

When a user rates negatively, the system deprioritizes similar gatherings.

---

## NAVIGATION STRUCTURE

Bottom tab bar with 4 tabs:
1. **Home** — Task 1 (top pick) + Task 2 (discovery feed)
2. **My Events** — Task 3 (joined events) + Task 4 (preparation/chat) + Task 6 (post-event feedback)
3. **Host** — Task 5 (create gathering flow)
4. **Profile** — User profile, cultural tags editing, settings, saved/bookmarked gatherings

---

## DATA MODELS

### User
```
- id: unique identifier
- email: .edu email address
- username: string
- avatarURL: string (or default avatar ID)
- appLanguage: string (en, zh, ko, etc.)
- city: string
- school: string
- culturalTags:
    - backgrounds: [string]
    - languages: [string]
    - interests: [string]
- createdAt: timestamp
```

### Gathering
```
- id: unique identifier
- hostID: reference to User
- title: string
- description: string
- templateType: string (potluck, language_exchange, movie_night, etc.)
- dateTime: timestamp
- location: string (or coordinates)
- maxAttendees: int
- culturalTags: [string]
- attendees: [userID]
- maybes: [userID]
- status: draft | published | completed | cancelled
- createdAt: timestamp
```

### Feedback
```
- id: unique identifier
- userID: reference to User
- gatheringID: reference to Gathering
- emojiRating: string (emoji value)
- eventTags: [string]
- createdAt: timestamp
```

### Connection
```
- id: unique identifier
- userID: reference to User
- connectedUserID: reference to User
- metAtGatheringID: reference to Gathering
- createdAt: timestamp
```

---

## BUILD ORDER (recommended phases)

| Phase | Focus | Screens |
|-------|-------|---------|
| 1 | Onboarding | Welcome/splash → Email sign-up → OTP → Profile setup → Location & school → Cultural tags |
| 2 | Home & Discovery | Home screen with top pick → Discovery feed → Gathering detail → Save/bookmark |
| 3 | Join & Prepare | Join confirmation → Calendar integration → Group chat → Push notification reminders |
| 4 | Host a Gathering | Template picker → Customize form → Preview & publish |
| 5 | Feedback & Connections | Post-event emoji check-in → Connection saving → Feedback data storage |
| 6 | Recommendation Engine | Aggregate ratings → Weight recommendations → Improve Tasks 1.2 and 2.1 |

---

## NOTES FOR CODING AGENTS

- Start with mock/dummy data for all gatherings and users. Backend integration comes later.
- Every screen must use the design system colors and fonts defined above.
- The onboarding flow (Task 0) uses `NavigationStack` with sequential progression.
- The main app (Tasks 1–6) uses a `TabView` with 4 tabs.
- Cultural tag chips should be multi-selectable with visual toggle states.
- The "Skip for now" option in Task 0.4 must be visually prominent — not hidden.
- Gathering cards in the feed must show: image, title, cultural tags as small chips, attendee count, host rating, location, and date/time.
- The feedback emoji picker (Task 6.1) should feel lightweight and fun — not a form.
- System/backend processes (Task 6.2) are not user-facing — they happen silently after the user submits feedback.
