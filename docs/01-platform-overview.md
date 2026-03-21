# Belong — Complete Platform Specification

**For Claude Code Agent / Vibe Coding Reference**
Last updated: 2026-03-21

## PROJECT OVERVIEW

- **App Name:** Belong
- **Type:** Mobile-first social platform (React Native or Flutter)
- **Target Users:** International & multicultural university students
- **Core Features:** Cultural gatherings + Social posts (小红书-style) + Chat + Social graph
- **Auth:** .edu email only, OTP verification

## TECH STACK RECOMMENDATION

| Layer | Options |
|-------|---------|
| Frontend | React Native (Expo) or Flutter |
| Backend | Node.js (Express) + Supabase OR Firebase |
| Database | PostgreSQL (Supabase) or Firestore |
| Auth | Supabase Auth / Firebase Auth with custom .edu validation |
| Storage | Supabase Storage / Firebase Storage (images) |
| Realtime | Supabase Realtime / Firebase Realtime DB (chat, notifications) |
| Search | PostgreSQL full-text search or Algolia |
| Push Notifications | Expo Notifications / Firebase Cloud Messaging |
| Recommendation Engine | Simple scoring algorithm → later ML |

## BOTTOM NAV MAPPING

```
Tab 1: 🏠 Gatherings  → Task 1 (Discover & Attend)
Tab 2: 📝 Posts        → Task 2 (Browse & Interact)
Tab 3: ➕ Create       → Task 3 (Create Gathering or Post)
Tab 4: 💬 Chat         → Task 4 (Notifications + DMs + Groups)
Tab 5: 👤 Profile      → Task 5 (Profile + Social + Settings)
```

## CROSS-TAB NAVIGATION MAP

```
Task 1.6.3 (Reflect → Share as post)     → Task 3.3 (Create Post, pre-filled)
Task 2.7   (Post → Linked gathering)     → Task 1.3 (Gathering detail → Join)
Task 1.6.2 (Save connections)            → Task 5.2 (Auto-suggest follow)
Task 2.5   (Follow from post)            → Task 5.2 (Following list updated)
Task 2.6.2 (Share post in chat)          → Task 4.2 (DM with shared post)
Task 3.2.3 (Publish gathering)           → Task 1.1 (Appears in others' feeds)
Task 3.3.4 (Publish post)               → Task 2.1 (Appears in followers' feeds)
Task 4.1   (Tap notification)            → Task 2.2 or Task 1 (target content)
Task 5.3   (My Gatherings → tap one)     → Task 1 (Gathering detail)
Task 5.4   (My Posts → tap one)          → Task 2.2 (Post detail)
```

## CONTENT FLYWHEEL

```
Attend Gathering (Task 1)
    ↓
Reflect & Rate (Task 1.6) — feedback stored → improves recommendations
    ↓
Share as Post (Task 1.6.3 → Task 3.3) — creates content
    ↓
Others See Post (Task 2.1) — discovery
    ↓
Jump to Linked Gathering (Task 2.7 → Task 1.3) — conversion
    ↓
Attend Gathering (Task 1) — loop continues
```

## REALTIME SUBSCRIPTIONS (WebSocket / Supabase Realtime)

```
Channel: user:{user_id}:notifications
  → New notification arrives → update badge count + show in-app alert

Channel: conversation:{conversation_id}
  → New message → append to chat UI
  → Typing indicator (optional, future)

Channel: gathering:{gathering_id}:members
  → Someone joins → update attendee count in real-time
```

## DOCUMENT INDEX

| Doc | Contents |
|-----|----------|
| `01-platform-overview.md` | This file — overview, tech stack, navigation |
| `02-database-schema.md` | Complete SQL schema for all tables |
| `03-hta-task0-onboarding.md` | Register & Onboard flow with backend ops |
| `04-hta-task1-gatherings.md` | Gatherings tab — discover, join, reflect |
| `05-hta-task2-posts.md` | Posts tab — 小红书-style feed & interactions |
| `06-hta-task3-create.md` | Create tab — gatherings & posts |
| `07-hta-task4-chat.md` | Chat & Notifications tab — DMs, groups |
| `08-hta-task5-profile.md` | Profile & Social tab — settings, social graph |
| `09-api-endpoints.md` | Complete API endpoint reference |
| `10-recommendation-engine.md` | Recommendation algorithm with feedback loop |
