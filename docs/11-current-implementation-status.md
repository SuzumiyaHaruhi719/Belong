# Current Implementation Status

Last updated: 2026-03-23

## Overview

The app has moved from UI prototype to a functional product with real Supabase backend. This document tracks what is implemented, what works end-to-end, and what remains.

## Backend Infrastructure

### Supabase Project
- **Project:** `fdpolacfrisftrtwytgo`
- **Region:** Default
- **Database:** 22 tables with RLS policies
- **Auth:** Email OTP + password-based registration
- **Realtime:** Enabled on `messages` table
- **Storage:** 4 buckets configured (avatars, post-images, gathering-images, profile-backgrounds)
- **RPC Functions:** 12 server-side functions

### Migrations Applied
1. `000001` — Core tables (users, user_tags, follows, blocks, reports, otp_codes)
2. `000002` — Gatherings tables + feedback + affinity
3. `000003` — Posts tables (images, tags, likes, comments, saves)
4. `000004` — Chat tables (conversations, members, messages)
5. `000005` — Notifications + browse history
6. `000006` — RLS policies (40+)
7. `000007` — Storage buckets
8. `000008` — RPC functions (12)

## Feature Status

### Auth & Onboarding
| Feature | Status | Notes |
|---------|--------|-------|
| Email entry + .edu validation | Working | Validates .edu suffix |
| OTP code sending | Working | Uses Supabase Auth `signInWithOTP` |
| OTP verification | Working | 6-digit code, handles expired/invalid |
| Password setup | Working | Strength validation |
| Username selection | Working | Real-time availability check via DB |
| Avatar + display name | Working | Persists to `users` table |
| Language selection | Working | Stores in `app_language` |
| City + school | Working | Free text, stored in profile |
| Cultural tags | Working | Multi-select, stored in `user_tags` |
| Login (returning user) | Working | Email + password |
| Session restore | Working | Checks `auth.session` on launch |
| Logout | Working | Clears session |

### Gatherings
| Feature | Status | Notes |
|---------|--------|-------|
| Feed with recommendations | Working | Uses `recommend_gatherings` RPC |
| Gathering detail | Working | Shows all fields from DB |
| Join gathering | Working | `join_gathering` RPC |
| Leave gathering | Working | `leave_gathering` RPC |
| Maybe gathering | Working | `maybe_gathering` RPC |
| Save/bookmark | Working | Toggles in `gathering_members` |
| Create gathering (template) | Working | 6 templates with smart defaults |
| Customize gathering | Working | Form with all fields |
| Preview + publish | Working | `publish_gathering` RPC |
| Draft save | Working | Saves with `is_draft: true` |
| Search gatherings | Working | Text search on title/description |
| Attendees list | Working | Shows joined/maybe members |
| Post-event feedback | Working | Emoji rating bottom sheet |

### Posts
| Feature | Status | Notes |
|---------|--------|-------|
| Posts feed | Working | Uses `get_posts_feed` RPC |
| Post detail | Working | Full view with images |
| Create post | Working | Text + images + tags + visibility |
| Like toggle | Working | `toggle_post_like` RPC |
| Save toggle | Working | `toggle_post_save` RPC |
| Comment | Working | `add_post_comment` RPC |
| Link to gathering | Partial | UI exists, selection needs improvement |
| User posts grid | Working | Shows on profile |

### Chat & Messaging
| Feature | Status | Notes |
|---------|--------|-------|
| Conversation list | Working | Shows DMs + group chats |
| Send message | Working | Real-time via Supabase |
| Receive message (realtime) | Working | Supabase Realtime subscription |
| Unread badge | Working | Real-time update on any tab |
| In-app banner | Working | Slide-down notification with sender info |
| Banner tap → conversation | Working | Navigates to correct chat |
| DM gating (mutual follow) | Working | 1 ice-breaker, unlimited if mutual |
| Group chat (gathering) | Working | Auto-created for gathering members |
| New conversation | Working | `get_or_create_dm` RPC |
| Mark as read | Working | Updates `last_read_at` |

### Profile & Social
| Feature | Status | Notes |
|---------|--------|-------|
| View own profile | Working | All fields from DB |
| Edit profile | Working | Display name, bio, city, school |
| Edit cultural tags | Working | Updates `user_tags` table |
| Follow user | Working | Persists to `follows` table, verified on load |
| Unfollow user | Working | Toggle via `toggle_user_follow` RPC |
| Followers/following list | Working | Paginated query |
| Mutuals count | Working | Intersection of followers/following |
| View other user profile | Working | From chat avatar tap or connections |
| Change password | Working | Supabase Auth `updateUser` |
| Settings | Working | Privacy, notifications, about |
| Block user | Working | `block_user` RPC |
| Saved gatherings | Working | Filtered from `gathering_members` |
| Saved posts | Working | From `post_saves` table |
| Browse history | Working | `browse_history` table |

### Notifications
| Feature | Status | Notes |
|---------|--------|-------|
| Notification list | Working | Grouped by type (comments, likes, mentions) |
| Follow notifications | Working | Created by `toggle_user_follow` RPC |
| In-app message banner | Working | Real-time, slide-down, tappable |
| Push notifications (APNs) | Not implemented | Requires Apple Developer account |

## Known Limitations

1. **SMTP:** Using Supabase default — limited to 4 emails/hour. Production needs custom SMTP.
2. **Image uploads:** StorageService protocol exists but MockStorageService is active. Images selected via PhotosPicker are not persisted to Supabase Storage.
3. **Emoji rendering:** iOS 26 simulator may show `?` boxes for some emoji in Text views. Works on real devices.
4. **No push notifications:** APNs not configured. Only in-app banner and badge for messages.
5. **No scheduled tasks:** No Edge Functions for reminders, cleanup, or digest emails.
6. **Search:** Basic text matching only — no full-text search or location-based filtering.

## Test Accounts

| Email | Password | Username | Role |
|-------|----------|----------|------|
| mai@unimelb.edu | Belong123! | mai.nguyen | Test user (seed data) |
| test@test.edu | Test1234! | testuser | Test user (seed data) |

## Recommendation Algorithm

### Gatherings (`recommend_gatherings`)
- Tag matching: background +10, language +8, interest +5
- Affinity from feedback: (score - 3.0) × 3
- Social: following host +5, same school +3
- Urgency: ≤2 days +4, ≤7 days +1, >7 days -3
- Scarcity: ≤2 spots left +3

### Posts (`get_posts_feed`)
- Following +30, same school +15, same city +10
- Engagement: likes × 0.5 + comments × 1.0
- Time decay: -5 per day
