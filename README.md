# Belong

**A cultural belonging platform for international students — because finding your people shouldn't be left to chance.**

Belong is a native iOS app that helps students from diverse cultural backgrounds discover real-world gatherings, share experiences, and build lasting connections on campus. It's not another content feed — it's a platform designed around the belief that true belonging starts when people actually meet.

---

## Why Belong Exists

Most universities have some version of an events page for cultural activities. In practice, these systems function more like bulletin boards: hard to browse, slow to update, and controlled by a handful of official organizations. The result is that only a narrow slice of cultural expression ever gets surfaced, while countless smaller, equally meaningful communities remain invisible.

Belong flips this model. Instead of waiting for institutions to define what counts as a "cultural event," Belong puts that power in every student's hands. Want to host a homestyle cooking night for Lunar New Year? Start a language exchange over coffee? Organize a watch party for a cricket match at 2 AM? On Belong, any student can create a gathering — no club affiliation, no approval process, no gatekeeping.

The core thesis is simple: **the fastest path to belonging is showing up somewhere and realizing "these people get me."** Everything in the app is built to lower the barrier between wanting that feeling and experiencing it.

---

## Core Features

### 🎉 Gatherings
The heart of Belong. Gatherings are real-world meetups organized by students, for students. The home feed uses a personalized recommendation algorithm that factors in your city, cultural tags, upcoming timing, host relationships, and past participation — with the goal of surfacing an event you'd actually want to attend within seconds of opening the app.

Creating a gathering is designed to feel lightweight: templates, customizable forms, live preview, draft saving, and a clear publish flow that reduces the anxiety of "what if nobody shows up."

### 📝 Posts
A visual content stream inspired by Pinterest-style masonry layout. Posts let users share photos, stories, and reflections — often tied to a gathering they attended or a cultural moment they want to capture. Posts serve as the connective tissue between events: they extend the life of a gathering beyond the moment it happens and attract new people to future ones.

Posts are important, but they're not the destination. They exist to document, inspire, and draw people toward real-world connection — not to replace it.

### 💬 Chat
Direct and group messaging, unified under an Activity tab that merges notifications and conversations. Chat keeps the momentum going after a gathering ends and helps organizers coordinate before one begins.

### 👤 Profile
More than a settings page — Profile is an identity hub showing social stats, a grid of your posts, follow/follower relationships, and the gatherings you've hosted or attended. It's how other students get a sense of who you are and what communities you're part of.

### 🔐 Campus-Verified Identity
Authentication is limited to `.edu` email addresses with OTP verification, ensuring every user is a real student on a real campus. This scoping decision is intentional: Belong is built for the trust dynamics of a campus community, not the open internet.

---

## Architecture

### Frontend
- **Platform:** iOS (SwiftUI)
- **Pattern:** MVVM — Views and ViewModels are organized by feature module
- **Modules:** Onboarding · Gatherings · Posts · Chat · Profile

### Backend
- **Database:** PostgreSQL via [Supabase](https://supabase.com)
- **Key tables:** `users`, `user_tags`, `follows`, `gatherings`, `gathering_members`, `gathering_feedback`, `posts`
- **API surface:** RESTful endpoints covering auth, users, gatherings, posts, conversations, notifications, uploads, history, and reports

### Recommendation Engine
Gathering recommendations are scored using a weighted combination of signals:
- Geographic proximity (same city)
- Temporal relevance (starting soon)
- Cultural tag overlap with user preferences
- Historical feedback (emoji reactions after attending)
- Social graph signals (host you follow, mutual friends attending)

Post-event emoji feedback updates tag affinity scores, creating a lightweight feedback loop that improves recommendations over time.

---

## Project Structure

```
Belong/
├── Belong.xcodeproj/       # Xcode project configuration
├── Belong/                  # iOS source code
│   ├── Views/               # SwiftUI views by feature
│   ├── ViewModels/          # MVVM view models
│   ├── Models/              # Data models
│   ├── Services/            # API & mock service layer
│   └── BelongApp.swift      # App entry point
├── docs/                    # Product spec, UI spec, DB schema, API design,
│                            # recommendation algorithm documentation
└── supabase/                # Database migrations & Supabase configuration
```

---

## Current Status

Belong is in active development. The product specification, database schema, API contracts, and UI design are fully defined. The iOS frontend has a working component structure with high-fidelity views across all five modules.

The service layer currently uses mock implementations (`MockAuthService`, `MockGatheringService`, `MockPostService`, etc.), meaning the app runs end-to-end with simulated data. The next phase focuses on replacing these mocks with live Supabase integration and completing the real data flow for gathering creation, post publishing, profile navigation, and draft persistence.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| iOS Client | SwiftUI, MVVM |
| Backend | Supabase (PostgreSQL, Auth, Storage) |
| Language | Swift 5.9+ |
| Min Deployment | iOS 17.0 |
| Docs | Markdown specs in `/docs` |

---

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/SuzumiyaHaruhi719/Belong.git
   ```

2. **Open in Xcode**
   ```
   open Belong.xcodeproj
   ```

3. **Build & Run**
   Select an iOS 17+ simulator and hit `Cmd + R`. The app runs with mock services by default — no backend configuration needed for local development.

4. **Backend setup** *(optional, for Supabase integration)*
   - Create a Supabase project
   - Apply migrations from `supabase/`
   - Update the Supabase URL and anon key in the app configuration

---

## Philosophy

Belong is not a content platform with an events feature bolted on. It's an offline-first community platform that uses content as a supporting layer. The distinction matters:

- **Content platforms** optimize for time-on-screen. Belong optimizes for showing up in person.
- **Event tools** treat gatherings as logistics. Belong treats them as the core unit of belonging.
- **Generic social apps** connect everyone to everyone. Belong connects you to people who share something deeper — a culture, a language, a hometown, a lived experience.

The long-term vision is a campus where no student has to wonder "is there anyone here like me?" — because Belong already showed them where to find their people.

---

## License

This project is currently unlicensed. All rights reserved by the author.

---

## Contact

Built by [@SuzumiyaHaruhi719](https://github.com/SuzumiyaHaruhi719)
