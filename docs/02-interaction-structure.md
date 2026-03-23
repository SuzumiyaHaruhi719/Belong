# Belong — Interaction Structure Analysis

Produced by: Senior Mobile Product Designer + Front-end Architect pass
Purpose: Translate the HTA into a production-ready mobile interaction structure before any UI code is written.

---

## 1. Goals & Completion Criteria

**Primary goal:** Get an international/multicultural student from zero → attending a culturally relevant gathering where they feel they belong — in the fewest possible steps.

**Secondary goals:**
- Build a personal cultural identity profile that improves over time
- Enable any user to host a gathering with minimal friction
- Surface connections formed at gatherings for future use
- Create a self-improving recommendation loop from passive post-event feedback

**Completion criteria (per session):**
- First-time: account created + at least one cultural tag set (or explicitly skipped) + home feed visible
- Discovery session: user either joins, saves, or "maybes" at least one gathering
- Post-event: emoji rating submitted (even a single tap counts)
- Hosting: gathering published and visible in feed

---

## 2. Friction Map, Drop-off Points & Emotional Sensitivity

### Highest-Friction Steps

| Step | Friction Type | Severity |
|------|--------------|----------|
| 0.1.2 OTP entry | External dependency (email delivery delay, spam folder) | Critical |
| 0.1.3 Password rules | Complex requirements, cognitive load mid-flow | High |
| 0.3 City + School | Must be accurate — wrong school = wrong community | High |
| 5.2 Customize gathering | Long form, fear of empty fields, intimidation of hosting | High |
| 6.1 Emoji check-in | Requires re-engaging after event is over (cold re-open) | Medium |

### Likely Drop-off Points

1. **OTP screen** — user gets impatient, email delayed, no resend visible → abandons sign-up
2. **Cultural tags (0.4)** — "Why do I have to tell you my ethnicity?" → privacy anxiety → exit
3. **Join confirmation** — social anxiety spike: "Will I know anyone there?" → backs out
4. **Host form (5.2)** — blank slate intimidation; smart defaults not visible → abandons
5. **Post-event feedback** — push notification ignored; screen feels like a chore → skipped permanently

### Emotionally Sensitive Moments

| Moment | Sensitivity | Design Response |
|--------|------------|-----------------|
| Entering cultural background (0.4.1) | Identity disclosure, fear of stereotyping | Frame as "help us find your people", make "skip" equally prominent |
| Joining first gathering alone (3.1) | Social anxiety, vulnerability | Show who's going + "X people like you are attending" |
| Maybe vs. Join (3.3) | Fear of commitment, fear of being rude if backing out | "Maybe" must not feel like a lesser choice |
| Post-event bad experience (6.1) | Emotional disappointment, don't want to re-engage | Emoji picker must feel low-stakes, no explanatory text required |
| Hosting with 0 RSVPs | Fear of failure, embarrassment | Show "gathering is live" ≠ show attendee count of 0 initially |

---

## 3. Screen Architecture

### ONBOARDING (Task 0) — Sequential, one-time

| Screen ID | Screen | Purpose | Required Info | Primary CTA | Secondary CTA |
|-----------|--------|---------|--------------|-------------|---------------|
| S01 | Welcome | Orient, emotional buy-in | App name, tagline, value prop | "Get started" | "Log in" |
| S02 | Email Entry | Capture .edu email | Email input, .edu validation | "Send verification code" | — |
| S03 | OTP Verification | Verify identity | 6-digit code, countdown timer | "Verify" (auto) | "Resend code" |
| S04 | Password Setup | Secure account | Password field, inline strength meter | "Continue" | — |
| S05 | Username | Set unique login handle | Username input, availability check | "Continue" | — |
| S06 | Email Confirmed | Celebrate milestone | Success state, what comes next | "Set up your profile →" | — |
| S07 | Avatar & Display Name | Personalize | Avatar grid + upload, display name | "Continue" | — |
| S08 | App Language | Localize experience | Language picker | "Continue" | — |
| S09 | City & School | Anchor to local community | City search → School search | "Continue" | — |
| S10 | Cultural Tags | Personalize recommendations | 3 chip groups + "Skip for now" | "Find my people →" | "Skip for now" |
| S11 | Onboarding Complete | Celebrate, transition | Completion state, gathering teaser | "See what's happening →" | — |

### MAIN APP — Tab 1: Home

| Screen ID | Screen | Purpose | Primary CTA | Secondary CTA |
|-----------|--------|---------|-------------|---------------|
| S12 | Home Feed | Immediate orientation + discovery | Tap card → S13 | Search / Filter |
| S13 | Gathering Detail | Full context before decision | "Join" | "Maybe" / "Save" |

### MAIN APP — Tab 2: My Events

| Screen ID | Screen | Purpose | Primary CTA | Secondary CTA |
|-----------|--------|---------|-------------|---------------|
| S14 | My Events List | Hub for joined + upcoming + past | Tap event → S13 | — |
| S15 | Join Confirmation (BS01) | Reduce anxiety, confirm commitment | "Add to calendar" | "Done" |
| S16 | Group Chat | Pre-event connection | Send message | View attendees |
| S17 | Post-Event Feedback (BS02) | Lightweight rating | Tap emoji (1-tap) | "Skip" |
| S18 | Save Connections (BS03) | Preserve relationships | "Connect" | "Skip" |

### MAIN APP — Tab 3: Host

| Screen ID | Screen | Purpose | Primary CTA | Secondary CTA |
|-----------|--------|---------|-------------|---------------|
| S19 | Template Picker | Lower hosting activation energy | Tap template | X (cancel) |
| S20 | Customize Form | Flesh out gathering details | "Preview →" | "Save draft" |
| S21 | Preview & Publish | Final review, build confidence | "Publish gathering" | "Edit" |
| S22 | Published Confirmation | Celebrate, reduce post-publish anxiety | "View my gathering" | "Share" |

### MAIN APP — Tab 4: Profile

| Screen ID | Screen | Purpose | Primary CTA | Secondary CTA |
|-----------|--------|---------|-------------|---------------|
| S23 | Profile | Identity hub | "Edit profile" | Settings gear |
| S24 | Edit Cultural Tags | Re-configure preferences | "Save" | "Cancel" |
| S25 | Saved Gatherings | Access bookmarked events | Tap card → S13 | Swipe to remove |
| S26 | Settings | Account management | Per-item actions | — |

---

## 4. HTA → Mobile UI Pattern Mapping

| HTA Step | Action | UI Pattern | Rationale |
|----------|--------|-----------|-----------|
| 0.1.1–0.1.5 | Account creation steps | **Stepper / multi-screen wizard** | Progressive commitment, one field per screen |
| 0.2.1–0.2.3 | Profile setup | **Multi-screen wizard (continued)** | Same visual rhythm |
| 0.3.1–0.3.2 | City & School | **Full screen with search inputs** | Dropdowns don't scale; search is faster |
| 0.4.1–0.4.3 | Cultural tag chips | **Full screen with chip grid + skip** | Needs space; multi-select needs visual density |
| 1.1 | Open app | **Full screen (Home tab, auto-loaded)** | No interaction needed; system acts |
| 1.2 | Top pick card | **Hero card at top of Home screen** | Dominant visual, immediate orientation |
| 2.1 | Recommendations feed | **Scrollable feed (inline cards)** | Standard mobile discovery pattern |
| 2.2 | Browse/filter | **Filter chips + search bar (inline expansion)** | Filter is secondary to feed; avoid extra screen |
| 2.3 | Save/bookmark | **Inline action on card (icon tap)** | Zero-friction, no screen change |
| 3.1 | One-tap join | **Primary CTA on Gathering Detail screen** | Full screen detail is correct before commitment |
| 3.2 | Join confirmation + calendar | **Bottom sheet** | Lightweight, doesn't break context |
| 3.3 | "Maybe" | **Secondary CTA on Gathering Detail** | Same access level as Join, different weight |
| 4.1 | Group chat | **Full screen** | Chat needs full focus |
| 4.2 | Reminder | **System push notification (no screen)** | Passive; user does not trigger this |
| 5.1 | Template picker | **Full screen grid/cards** | Visual comparison across templates |
| 5.2 | Customize form | **Full screen scrollable form** | Too many fields for a bottom sheet |
| 5.3 | Preview & publish | **Full screen with rendered card** | Confidence-building before commitment |
| 6.1 | Emoji check-in | **Bottom sheet** | Lightweight, dismissible |
| 6.2 | Store rating (system) | **No UI — silent background operation** | Never surface to user |
| 6.3 | Save connections | **Bottom sheet after emoji submit** | Natural follow-on, entirely skippable |

---

## 5. Missing Flows (Not in HTA)

### Onboarding Additions
- **Value proposition screen** before email entry — three illustrated benefit statements
- **Social proof signal** on welcome: "Join 4,200+ students at NEU, BU, and MIT"

### Permissions

| Permission | When to Ask | Context |
|-----------|------------|---------|
| Push notifications | After first successful join (step 3.2) | "Get reminders before your gathering" |
| Calendar access | When user taps "Add to calendar" in join confirmation | User-intent triggered |
| Location | Defer to v2 — not in current HTA | — |

> Never ask all permissions on app launch. Each permission tied to a specific user action.

### Loading States
- **Home feed skeleton** — 3 ghost cards while recommendations load; never show blank feed
- **OTP send confirmation** — inline loading on button, then "Code sent to [email]" toast
- **Gathering join** — button loading spinner, then transition to confirmation
- **Publishing gathering** — "Publishing your gathering…" full-screen progress

### Empty States

| Screen | Empty State Title | Body | CTA |
|--------|------------------|------|-----|
| Home feed (new user) | (no title) | "We're warming up your feed — here are popular gatherings near you" | Show generic popular gatherings |
| Home feed (post-filter) | "Nothing here" | "Nothing matching that filter right now" | "Clear filters" |
| My Events > Upcoming | "No upcoming gatherings yet" | — | "Browse gatherings →" |
| My Events > Past | "No past gatherings" | "Attend a gathering to see your history here" | — |
| Saved | "Nothing saved yet" | "Tap the bookmark on any gathering to save it here" | — |
| Group Chat | — | "Be the first to say hello 👋" | — |

### Validation (inline, not blocking)

| Input | Validation | Feedback |
|-------|-----------|---------|
| Email | Must end in .edu | "Please use your university email" |
| OTP | Wrong code | "Incorrect code — X attempts remaining" |
| OTP | Expired | "Code expired" + auto-surface "Resend" |
| Password | Strength | Live checklist: each rule checks off as met |
| Username | Availability | Real-time "✓ available" / "✗ taken" |
| Hosting form | Missing required field | Inline field highlight on "Preview" tap |
| Hosting form | Date in the past | "Please pick a future date" |

### Error Recovery

| Error | Recovery Pattern |
|-------|----------------|
| OTP not received | "Didn't get it?" → Resend (60s cooldown) + "Check spam folder" hint |
| OTP expired | Auto-detect, show resend CTA without user having to try again |
| Network failure on join | Toast + retry button |
| Publishing fails | Auto-save as draft, show error toast |
| Chat load failure | Retry button in chat header |
| Recommendation cold start | Fall back to popular gatherings in city |

### Cancellation Flows

| Action | Handling |
|--------|---------|
| Onboarding back navigation | Progress saved per step; input preserved |
| Leave gathering | Confirmation dialog: "Leave [Event Name]? The host will be notified." |
| Cancel hosting draft | "Save draft" option; draft accessible from Host tab |
| Close emoji check-in | Dismiss = skip, no negative signal sent |

### Back Navigation Rules
- Onboarding wizard: back = previous step, input preserved
- Hosting form: back shows "Save draft / Discard" dialog if any field is filled
- Gathering detail from feed: back returns to same scroll position in feed
- Group chat: back returns to My Events list
- All bottom sheets: swipe down or ✕ to dismiss

### Resume Interrupted Tasks
- **Incomplete onboarding:** on relaunch, return to last completed step, not Welcome screen
- **Hosting draft:** "You have an unfinished gathering" banner on Host tab
- **Emoji feedback pending:** push notification 2h after event end time; tap opens emoji sheet directly

---

## 6. User Flow & Screen Map

### Onboarding Flow

```
S01 Welcome
  └─► S02 Email Entry
        └─► S03 OTP Verification
              ├─ (wrong code) ──► retry inline
              ├─ (expired) ──────► resend inline
              └─► S04 Password Setup
                    └─► S05 Username
                          └─► S06 Email Confirmed ✓
                                └─► S07 Avatar & Display Name
                                      └─► S08 App Language
                                            └─► S09 City & School
                                                  └─► S10 Cultural Tags
                                                        ├─ (skip) ──────► S11 Complete
                                                        └─ (fill) ───────► S11 Complete
                                                                                └─► Main App
```

### Login Flow (returning users)

```
S01 Welcome
  └─ "Log in" ──► Login Screen (email + password)
                    ├─ (forgot password) ──► Reset flow (email link)
                    └─► Main App (Tab 1: Home)
```

### Main App Flow

```
TAB 1: HOME
S12 Home Feed
  └─► S13 Gathering Detail
        ├─ "Join" ──────────────────► BS01 Join Confirmation
        │                                 ├─ "Add to calendar" → Calendar
        │                                 └─ "Done" → S14 My Events (Upcoming)
        ├─ "Maybe" ─────────────────► Maybe state on card (inline toggle)
        └─ "Save" (bookmark) ───────► Saved to S25, inline toggle

TAB 2: MY EVENTS
S14 My Events List
  ├─ Upcoming segment
  │     └─► S13 Gathering Detail (read mode)
  │               └─► S16 Group Chat
  ├─ Past segment
  │     └─► BS02 Post-Event Feedback (emoji)
  │               └─► BS03 Save Connections (skippable)
  └─ Saved segment
        └─► S13 Gathering Detail

TAB 3: HOST
S19 Template Picker
  └─► S20 Customize Form
        ├─ "Save draft" ──────────────► Draft saved, back to Host tab
        └─► S21 Preview & Publish
              ├─ "Edit" ───────────────► Back to S20
              └─► "Publish" ────────────► S22 Published Confirmation
                                              └─► S13 (own gathering, host mode)

TAB 4: PROFILE
S23 Profile
  ├─► S24 Edit Cultural Tags
  ├─► S25 Saved Gatherings ──► S13 Gathering Detail
  └─► S26 Settings
```

### Feedback Loop (invisible to user)

```
BS02 Emoji submitted
  └─► [BACKGROUND] Feedback record created
        └─► [BACKGROUND] Recommendation engine re-weights tag affinities
              └─► S12 Home Feed (next session) — recommendations improved
```

### Screen Map Summary

```
┌─────────────────────────────────────────────────────────────┐
│  ONBOARDING (one-time, sequential)                          │
│  S01→S02→S03→S04→S05→S06→S07→S08→S09→S10→S11              │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────┐
│  MAIN APP                                                           │
│                                                                     │
│  ┌────────────┐  ┌──────────────────┐  ┌────────────┐  ┌────────┐  │
│  │ HOME (T1)  │  │  MY EVENTS (T2)  │  │  HOST (T3) │  │ PROF   │  │
│  │            │  │                  │  │            │  │ (T4)   │  │
│  │ S12 Feed   │  │ S14 Event List   │  │ S19 Picker │  │ S23    │  │
│  │ S13 Detail │  │ BS01 Join Conf.  │  │ S20 Form   │  │ S24    │  │
│  │            │  │ S16 Chat         │  │ S21 Preview│  │ S25    │  │
│  │            │  │ BS02 Feedback    │  │ S22 Done   │  │ S26    │  │
│  │            │  │ BS03 Connections │  │            │  │        │  │
│  └────────────┘  └──────────────────┘  └────────────┘  └────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

**Total: 26 screens + 3 bottom sheets**
**Onboarding depth: 11 screens (skip path: 9)**
**Maximum taps to first joined gathering (returning user): 4 taps**
