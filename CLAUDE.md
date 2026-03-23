# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Belong is a SwiftUI iOS app for international/multicultural students to discover and host cultural gatherings, share posts, and connect with peers. Targeting iOS 26.2+, iPhone and iPad.

## Build & Run

Open `Belong.xcodeproj` in Xcode and build/run (`Cmd+R`). Uses Swift Package Manager for dependencies (Supabase Swift SDK).

- **Bundle ID:** `hhh.Belong`
- **Deployment Target:** iOS 26.2
- **Swift Version:** 5.0
- **Dependencies:** `supabase-swift` (via SPM)

## Architecture

- **SwiftUI** throughout — no UIKit
- Entry point: `Belong/BelongApp.swift` (`@main`, `WindowGroup` scene)
- Root navigation: `RootView` → `SplashView` / `OnboardingFlow` / `MainTabView` based on `AppState.authStatus`
- Source files live in `Belong/` (inner directory); `Belong.xcodeproj` is at repo root
- `MainActor` isolation enabled project-wide
- Approachable concurrency enabled

### App Structure

```
RootView
├── SplashView (auth check)
├── OnboardingFlow (NavigationStack, 11 steps)
│   └── Welcome → Email → OTP → Password → Username → EmailConfirmed
│       → Avatar → Language → CitySchool → CulturalTags → Complete
└── MainTabView (5 tabs)
    ├── Gatherings (feed + detail + search + attendees)
    ├── Posts (feed + detail + comments + likes)
    ├── Create (bottom sheet → gathering flow or post screen)
    ├── Chat (conversations + DM + group chat + notifications)
    └── Profile (view + edit + settings + connections + saved)
```

### Service Architecture (Protocol-based DI)

```
DependencyContainer
├── authService: AuthServiceProtocol    → SupabaseAuthService
├── userService: UserServiceProtocol    → SupabaseUserService
├── gatheringService: GatheringServiceProtocol → SupabaseGatheringService
├── postService: PostServiceProtocol    → SupabasePostService
├── chatService: ChatServiceProtocol    → SupabaseChatService
├── notificationService: ...            → SupabaseNotificationService
└── storageService: StorageServiceProtocol → MockStorageService (TODO: real)
```

Toggle `DependencyContainer.useLiveBackend` to switch between Supabase and Mock services.

## Backend — Supabase

### Project Info
- **URL:** `https://fdpolacfrisftrtwytgo.supabase.co`
- **Anon Key:** stored in `SupabaseManager.swift`
- **Migrations:** `supabase/migrations/` (8 migration files)

### Database Tables (22 total)
- **Users:** `users`, `user_tags`, `follows`, `blocks`, `reports`, `otp_codes`
- **Gatherings:** `gatherings`, `gathering_tags`, `gathering_members`, `gathering_feedback`, `user_tag_affinity`
- **Posts:** `posts`, `post_images`, `post_tags`, `post_likes`, `post_comments`, `post_saves`
- **Chat:** `conversations`, `conversation_members`, `messages`
- **Other:** `notifications`, `browse_history`

### RPC Functions (12)
- `recommend_gatherings` — recommendation algorithm with tag matching + social signals
- `toggle_user_follow` — atomic follow/unfollow with notification
- `submit_gathering_feedback` — emoji rating with EMA affinity update
- `publish_gathering` — create/publish gathering with tags
- `toggle_post_like`, `toggle_post_save`, `add_post_comment`
- `create_post_with_tags` — create post with images + tags
- `join_gathering`, `leave_gathering`, `maybe_gathering`
- `get_or_create_dm`, `block_user`

### Storage Buckets (4)
- `avatars`, `post-images`, `gathering-images`, `profile-backgrounds`

### RLS Policies
- 40+ policies across all tables
- `SECURITY DEFINER` on RPC functions to bypass RLS where needed
- Public SELECT on gatherings, posts, follows; owner-only mutations

### Realtime
- `messages` table has Realtime enabled for live chat
- Global listener in `MainTabView` for badge updates + in-app banner notifications

## Key Features — Current State

### Working (end-to-end with Supabase)
- **Auth:** Email OTP registration, password login, session restore
- **Onboarding:** 11-step flow with real Supabase writes
- **Gatherings:** Create (template → customize → preview → publish), browse feed, detail view, join/leave/maybe
- **Posts:** Create with images + tags, feed, detail, like, comment, save
- **Chat:** DM + group chat, realtime message delivery, unread badges
- **In-app banner:** Slide-down notification when receiving messages
- **Profile:** View/edit, cultural tags, follow/unfollow (persisted), connections
- **Recommendation:** SQL-based scoring algorithm for gatherings and posts

### Partially Working
- **Storage uploads:** Protocol exists but uses MockStorageService (image picker UI wired but uploads don't persist to Supabase Storage)
- **Push notifications:** No APNs/FCM integration yet (in-app banner only)
- **Search:** Gathering search exists but may not cover all filter combinations

### Not Yet Implemented
- **Edge Functions:** No server-side scheduled tasks (reminders, cleanup)
- **Custom SMTP:** Using Supabase default (4 emails/hour limit)
- **App Store submission:** No paid Apple Developer account

## File Organization

```
Belong/
├── App/           # AppState, RootView, MainTabView, DependencyContainer,
│                  # SupabaseManager, InAppBannerManager
├── Models/        # User, Gathering, Post, Message, Conversation, etc.
├── Views/
│   ├── Onboarding/  # Welcome through Complete (11 screens)
│   ├── Gatherings/  # Feed, Detail, Search, Attendees, Map
│   ├── Posts/       # Feed, Detail, Comments, Likes, UserPosts
│   ├── Chat/        # List, Detail, Info, GroupChat, NewConversation
│   ├── Create/      # GatheringFlow, PostScreen, TemplatePicker
│   └── Profile/     # Profile, EditProfile, Settings, Connections, etc.
├── ViewModels/    # Screen-specific ViewModels
├── Components/    # Reusable UI: BelongButton, GatheringCard, PostCard,
│                  # MessageBubble, AvatarView, ChipView, etc.
├── Sheets/        # Bottom sheets: JoinConfirmation, PostEventFeedback, etc.
├── Services/
│   ├── Protocols/ # Service interfaces
│   ├── Supabase/  # Real Supabase implementations + DTOs
│   └── Mock/      # Mock implementations with sample data
├── Resources/     # DesignTokens (colors, fonts, spacing)
└── PreviewContent/ # SampleData for Xcode previews
```

## Design System

- **Fonts:** Fraunces (headings), Plus Jakarta Sans (body/UI)
- **Colors:** Terracotta `#C47B5A`, Warm Cream `#FAF3EB`, Dark Brown `#2C2825`, Surface `#FEFCF9`, Gold `#D4A03C`, Green `#4A8A4A`, Error `#C53030`
- **Spacing:** 8pt base unit (defined in `DesignTokens.swift`)
- **Corner radius:** 16–20pt (generous, organic feel)
- **Buttons:** 56pt height, full-width primary, 5 states defined

## Product Knowledge Base

Detailed specs in `docs/`:

| File | Contents |
|------|---------|
| `docs/01-app-specification.md` | Design system, task breakdown, data models, build order |
| `docs/02-interaction-structure.md` | Screen map (S01–S26 + 3 sheets), HTA→UI mapping, user flows |
| `docs/03-ui-specification.md` | Pixel-level UI spec: components, microcopy, edge cases |
| `docs/01-platform-overview.md` | Platform overview, tech stack, content flywheel |
| `docs/02-database-schema.md` | Full PostgreSQL schema (22 tables) |
| `docs/03-hta-task0-onboarding.md` | Onboarding task hierarchy |
| `docs/04-hta-task1-gatherings.md` | Gatherings discovery + join flow |
| `docs/05-hta-task2-posts.md` | Posts feed algorithm + interactions |
| `docs/06-hta-task3-create.md` | Create gathering + post flows |
| `docs/07-hta-task4-chat.md` | Chat + notifications system |
| `docs/08-hta-task5-profile.md` | Profile + social graph + settings |
| `docs/09-api-endpoints.md` | API endpoint reference |
| `docs/10-recommendation-engine.md` | Recommendation algorithm details |

## Key Design Decisions

- **Real Supabase backend** — all data persists to PostgreSQL via Supabase
- **Protocol-based services** — easy to swap Mock ↔ Supabase implementations
- **5 tabs:** Gatherings, Posts, Create, Chat, Profile
- **Cultural tag chips** are multi-selectable with terracotta fill
- **"Skip for now"** on cultural tags must be visually equal to primary button
- **DM gating:** Mutual follow required for unlimited messaging; one ice-breaker message allowed
- **Emoji feedback** is a bottom sheet, one-tap submit
- **Realtime chat** via Supabase Realtime WebSocket subscription
- **In-app banner** for message notifications (slide-down from top, auto-dismiss)
- **Follow state** persists to `follows` table and is verified on profile load
