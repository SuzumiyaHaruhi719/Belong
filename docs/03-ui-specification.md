# Belong — Complete Mobile UI Specification

Implementation-ready spec. All component states, copy, edge cases, and accessibility requirements defined.

---

## PART A: GLOBAL DESIGN PRINCIPLES

### 1. Core Design Principles

**Warmth before utility.** Every screen should feel like stepping into a friend's home, not a form. Functional elements (inputs, buttons, lists) use the warm palette and generous radius to prevent clinical coldness.

**One decision per moment.** No screen asks the user to make more than one meaningful choice at a time. When multiple choices exist, one is always recommended or pre-selected.

**Earned trust through identity safety.** Cultural identity is sensitive. The app never frames tags as required data — always as a gift the user gives to improve their own experience.

**Invisible system, visible community.** Backend processes (recommendation scoring, feedback storage) are never exposed. What the user sees is always people and gatherings, never algorithms or data.

**Low floor, high ceiling.** New users reach the home feed in under 2 minutes. Power users unlock depth over time — not on first launch.

---

### 2. Spacing & Visual Hierarchy Rules

**Base unit:** 8pt. All spacing is a multiple of 8 (8, 16, 24, 32, 40, 48).

**Screen margins:** 20pt left/right on all full-screen content. Exception: full-bleed images and edge-to-edge cards.

**Content zones (top to bottom):**
```
Navigation bar / progress indicator   — 44–56pt height
─────────────────────────────────────
Screen headline + subhead             — 56–80pt block
─────────────────────────────────────
Primary content area                  — flexible, scrollable
─────────────────────────────────────
Bottom action zone                    — 80–100pt (safe area aware)
```

**Type scale:**

| Role | Font | Size | Weight | Usage |
|------|------|------|--------|-------|
| Display | Fraunces | 32pt | Semibold | Splash, milestone screens only |
| H1 | Fraunces | 26pt | Semibold | Screen titles |
| H2 | Fraunces | 20pt | Medium | Section headers, card titles |
| Body | Plus Jakarta Sans | 16pt | Regular | Primary body copy |
| Secondary | Plus Jakarta Sans | 14pt | Regular | Metadata, helper text |
| Caption | Plus Jakarta Sans | 12pt | Regular | Timestamps, chip labels, fine print |

Minimum rendered text: **12pt** — never below this.

**Color usage rules:**

| Token | Hex | Usage |
|-------|-----|-------|
| Text Primary | `#2C2825` | All primary text |
| Text Secondary | `#6B5E57` | Secondary text, placeholder text |
| Primary | `#C47B5A` | Primary CTAs, active states, accent icons |
| Background | `#FAF3EB` | Screen background only |
| Surface | `#FEFCF9` | Card surfaces, inputs, bottom sheets |
| Accent / Gold | `#D4A03C` | Trust signals, host ratings, featured badges |
| Success | `#4A8A4A` | Confirmations, verified states |
| Error | `#C53030` | Validation errors, destructive actions |
| System (internal) | `#7B5FA0` | Never shown to user |

**Elevation / shadow:**
- Level 1 (cards): `shadow(color: #2C2825 @ 6% opacity, radius: 12, x: 0, y: 4)`
- Level 2 (bottom sheets, modals): `shadow(color: #2C2825 @ 12% opacity, radius: 24, x: 0, y: -8)`
- Level 3 (floating buttons): `shadow(color: #C47B5A @ 20% opacity, radius: 16, x: 0, y: 6)`

---

### 3. Component Consistency Rules

**Buttons:**

| Type | Fill | Text | Border | Height | Width |
|------|------|------|--------|--------|-------|
| Primary | `#C47B5A` | `#FEFCF9` | None | 56pt | Full-width in forms |
| Secondary | `#FEFCF9` | `#C47B5A` | 1pt `#C47B5A` | 56pt | Full-width |
| Tertiary/ghost | None | `#C47B5A` | Optional underline | 44pt min | — |
| Destructive | `#C53030` | `#FEFCF9` | — | 56pt | Full-width |
| Disabled | `#D4C4BB` | `#A89490` | None | 56pt | — |
| Loading | Same as primary | Spinner (white 20pt) | — | 56pt | — |

Corner radius on all buttons: **16pt**

**Inputs:**
- Height: 56pt
- Corner radius: 12pt
- Background: `#FEFCF9`
- Border: `1pt #E8DDD6` (resting) → `2pt #C47B5A` (focused) → `2pt #C53030` (error)
- Placeholder: `#A89490`
- Label: 12pt Plus Jakarta Sans, `#6B5E57`, 8pt above input
- Error message: 12pt, `#C53030`, 4pt below input, with warning icon
- Success: `#4A8A4A` checkmark icon trailing in field

**Cards (gathering cards):**
- Corner radius: 20pt
- Background: `#FEFCF9`
- Image: 16:9 ratio, top of card, top corners inherit radius
- Padding: 16pt all sides below image
- Shadow: Level 1
- Tap state: scale 0.98, 100ms

**Chips (cultural tags):**
- Height: 36pt / Horizontal padding: 16pt / Corner radius: 18pt (full pill)
- Resting: `#FEFCF9` bg, `1pt #E8DDD6` border, `#2C2825` text
- Selected: `#C47B5A` bg, no border, `#FEFCF9` text
- Font: 14pt Plus Jakarta Sans medium

**Bottom sheets:**
- Corner radius: top corners only, 24pt
- Drag handle: 36×4pt, `#D4C4BB`, centered, 12pt from top
- Background: `#FEFCF9`
- Shadow: Level 2
- Dismiss: swipe down or background tap

**Navigation bar:**
- Height: 44pt + status bar
- Background: `#FAF3EB`, no border
- Title: 17pt Plus Jakarta Sans semibold, centered
- Back button: chevron left + optional screen name, `#C47B5A`

**Tab bar:**
- Height: 49pt + safe area inset
- Background: `#FEFCF9`, Level 2 shadow upward
- Active: `#C47B5A` icon + label
- Inactive: `#A89490`
- Labels: 10pt Plus Jakarta Sans
- Tabs: Home, My Events, Host, Profile

---

### 4. Touch Target Guidance

| Element | Visual Size | Minimum Tap Area |
|---------|------------|-----------------|
| Icon buttons | 24pt | 44×44pt (use padding) |
| Primary buttons | 56pt height | 56pt height, full-width |
| Chips | 36pt height | 36pt height (cluster provides margin) |
| List rows | 56pt height | 56pt height |
| Bottom action buttons | 56pt height | 56pt height, 20pt from safe area edge |
| Emoji picker cells | 64×64pt | 64×64pt (primary action; make generous) |
| Cards | Full card | Entire card tappable |
| "Skip" links | Ghost text | 44pt tap height minimum |

---

### 5. Reducing Hesitation & User Confusion

**Decision fatigue prevention:**
- Never present more than 5 options without search or filter
- Pre-select the most common/safe option wherever possible
- In forms, show smart defaults from context (template pre-fills hosting form)

**Commitment anxiety reduction:**
- "Maybe" is always available alongside "Join" — positioned as equal, not lesser
- Joining is reversible (leave gathering always available)
- Cultural tags can always be edited later — state this on the tags screen
- Hosting shows draft save option — not irreversible until publish

**Trust building:**
- Show attendee count and host rating on every card before the detail screen
- Host avatar visible on gathering cards
- Cultural tag match indicators ("3 tags match your profile")

---

### 6. Progressive Disclosure

**Immediately visible:**
- Gathering title, image, date, location, cultural tags, attendee count
- Primary CTA
- Error messages when they occur
- "Skip" on optional steps
- Tab bar at all times in main app

**Revealed on tap/scroll/action:**
- Full gathering description (truncated to 3 lines on card, full on detail)
- Other attendees list (behind "[N] people going" tap)
- Password requirements (on input focus)
- Hosting form advanced fields (date/time picker as sheet)
- Filter options (behind filter button)
- Settings sub-options (behind each row)

---

## PART B: SCREEN SPECIFICATIONS

---

### S01 — Welcome Screen

**Goal:** Create immediate emotional resonance. Remove the sense of "another sign-up wall."

**User mindset on arrival:** Curious but skeptical. No established trust yet.

**Content hierarchy (top → bottom):**
1. Full-bleed illustration/photo (diverse group, warm, joyful) — 60% of screen height
2. Gradient overlay on bottom of image (cream, 120pt)
3. "Belong" wordmark — Fraunces 32pt, `#2C2825`
4. Tagline — 2 lines max
5. Social proof line — 14pt, `#6B5E57`
6. Primary button
7. Secondary ghost link

**Key components:** Full-bleed image, gradient overlay, wordmark, tagline, social proof badge, primary button, ghost link

**Primary CTA:** "Get started" → S02
**Secondary CTA:** "Log in" → Login screen

**Navigation:** No nav bar. Full-screen presentation. App root.

**System feedback:** None — purely static.

**Edge cases:**
- Already logged in → skip to S12 directly
- Abandoned onboarding → skip to last completed step

**Accessibility:**
- Image `accessibilityLabel`: "A group of students sharing a meal together"
- All text 4.5:1 contrast on cream background
- Both buttons accessible via VoiceOver in correct tab order

**Microcopy:**
- Tagline: "Find your people. Share your culture."
- Social proof: "Joined by 4,200+ students at 12 Boston universities"
- Primary button: "Get started"
- Secondary link: "Already have an account? Log in"

---

### S02 — Email Entry

**Goal:** Capture a valid .edu email with minimal friction. Set expectation that a code is coming.

**User mindset:** Willing to proceed but watching the effort level.

**Content hierarchy:**
1. Progress indicator (4 segments: Account, Profile, Location, Tags)
2. H1 screen title (Fraunces)
3. Subtitle/helper text
4. Email input (immediately focusable)
5. Inline helper text below field
6. Primary button (disabled until valid .edu)
7. Legal micro-line

**Key components:** Progress bar, H1, body text, single email input (`.emailAddress` keyboard, auto-lowercase, no autocorrect), inline validation, primary button, privacy policy link

**Primary CTA:** "Send verification code" → S03
**Secondary CTA:** None

**Navigation:** Back → S01

**System feedback:**
- Button disabled until valid .edu format
- Trailing green checkmark when valid
- On tap: spinner + "Sending…"
- On success: navigate to S03 + toast "Code sent to [email]"
- On already-registered: inline error with "Log in instead →" link

**Edge cases:**
- Non-.edu: inline error "Please use your university email (it ends in .edu)"
- Already registered: inline error + tappable "Log in" link
- Network failure: toast + button re-enables for retry
- Paste: validate on paste

**Accessibility:**
- `textContentType: .emailAddress` for autofill
- Error associated with input via `accessibilityHint`
- Return key labeled "Continue"

**Microcopy:**
- Screen title: "What's your university email?"
- Subtitle: "We'll send a quick verification code — takes 30 seconds."
- Placeholder: "yourname@university.edu"
- Field label: "University email"
- Helper (always visible): "Must end in .edu"
- Non-.edu error: "Please use your university email address"
- Already registered: "This email already has an account. Log in instead →"
- Button: "Send verification code" / loading: "Sending…"
- Legal: "By continuing, you agree to our Terms and Privacy Policy"

---

### S03 — OTP Verification

**Goal:** Confirm the user controls the entered email. Minimize drop-off from delivery delays.

**User mindset:** Mildly anxious. "Did it send? Is it in spam?" Perceived time pressure.

**Content hierarchy:**
1. Progress indicator (still on "Account")
2. Screen title
3. Destination confirmation (email shown in terracotta/bold)
4. 6-digit OTP input (large cells)
5. Countdown timer / resend CTA
6. "Wrong email?" link

**Key components:**
- 6-cell OTP input: each cell 52×64pt, 8pt spacing, `#FEFCF9` bg, `2pt #C47B5A` focused border
- `.numberPad` keyboard, `textContentType: .oneTimeCode`
- Auto-advance on digit entry, auto-submit on 6th digit
- Countdown timer (format: "Resend in 0:45")
- Resend link (active after countdown)
- "Wrong email? Go back" text link

**Primary CTA:** Auto-submit on 6th digit → S04 (or inline error)
**Secondary CTA:** "Resend code" / "Wrong email? Go back"

**Navigation:** Back → S02 (email field pre-filled)

**System feedback:**
- Correct: green border pulse on cells (200ms) → navigate to S04
- Wrong: horizontal shake (3 oscillations, 300ms), red border, error below, clear + refocus cell 1, haptic `.medium`
- Expired: timer → "Code expired", resend becomes active
- Resend: loading briefly → "New code sent" inline, timer restarts
- Success haptic: `.success`

**Edge cases:**
- OTP expires before entry: server catches on submit, shows "Your code expired — we sent a new one", restarts timer
- 3 wrong attempts: auto-resend + message "Too many attempts — we'll send a new code"
- Spam folder: hint appears after 30s on screen "Can't find it? Check your spam folder"
- System autofill: `textContentType: .oneTimeCode` enables email autofill

**Accessibility:**
- Each cell: "Digit [N] of 6"
- Error shake + haptic
- Success haptic
- "Resend code" meets 44pt tap target

**Microcopy:**
- Screen title: "Check your email"
- Subtitle: "We sent a 6-digit code to [email address]"
- Countdown active: "Resend in 0:45"
- Countdown expired: "Didn't get it?"
- Resend: "Resend code"
- Wrong code: "That code didn't match — try again"
- Expired error: "That code expired — we've sent a new one"
- Wrong email link: "Wrong email? Go back"
- Spam hint (30s): "Check your spam folder if you don't see it"

---

### S04 — Password Setup

**Goal:** Collect a secure password without making it feel like a government form.

**User mindset:** Mild frustration potential. "Password rules again." Keep fast and clear.

**Content hierarchy:**
1. Progress indicator
2. Screen title + subtitle
3. Password input (show/hide toggle)
4. Live requirements checklist (4 rules)
5. Confirm password input (appears after all 4 rules pass — conditional)
6. Primary button

**Key components:**
- Secure text field, eye icon toggle (44×44pt tap area)
- Live rule checklist: gray circle → green checkmark per rule
  - "8 or more characters"
  - "One uppercase letter (A–Z)"
  - "One number (0–9)"
  - "One special character (!@#)"
- Confirm field: slide-down animation (spring, 300ms) when all 4 rules pass
- Button disabled until both fields valid + matching

**Primary CTA:** "Continue" → S05
**Secondary CTA:** None

**Navigation:** Back → S03. Both fields cleared on back (security).

**System feedback:**
- Rules: gray → green as user types
- Confirm appears with spring animation after all rules pass
- Mismatch: red border + error below confirm
- Match: green checkmark trailing in confirm
- Button enables only when both conditions met

**Edge cases:**
- Paste password: validate all rules on paste
- Back navigation: clear both fields for security
- Keyboard obscures confirm: screen scrolls up

**Accessibility:**
- Eye icon: `accessibilityLabel` toggles "Show password" / "Hide password"
- Rule items: `accessibilityValue` includes pass/fail state
- Confirm: `accessibilityHint` = "Re-enter your password to confirm"

**Microcopy:**
- Screen title: "Create your password"
- Subtitle: "You'll use this to log in."
- Field label: "Password" / "Confirm password"
- Rules header: "Your password needs:"
- Mismatch error: "Passwords don't match"
- Button: "Continue"

---

### S05 — Username

**Goal:** Set a unique username (login handle). Fast, creative, low stakes.

**Content hierarchy:**
1. Progress indicator
2. Screen title + subtitle
3. Username input with real-time availability indicator
4. Character limit + format hint
5. Primary button

**Key components:**
- Single text input (no spaces, auto-lowercase suggestion, max 20 chars)
- Trailing indicator: spinner (checking) → green checkmark (available) → red X (taken)
- Character counter: "[n] / 20" as caption
- Button disabled until valid + available

**Primary CTA:** "Continue" → S06
**Navigation:** Back → S04

**System feedback:**
- Availability check fires 600ms after last keystroke (debounced)
- Available: green checkmark + caption
- Taken: red indicator + caption
- Checking: spinner

**Edge cases:**
- Reserved words (admin, belong, support): treated as taken
- Under 3 characters: inline error
- Network fails availability check: allow proceed, catch on submission

**Accessibility:**
- `textContentType: .username`
- Availability state announced by VoiceOver on change
- Character counter as `accessibilityValue`

**Microcopy:**
- Screen title: "Choose a username"
- Subtitle: "This is how others will find you on Belong."
- Placeholder: "e.g. jinsoo_k"
- Format hint: "Letters, numbers, and underscores only"
- Available: "That username is available ✓"
- Taken: "That username is already taken"
- Invalid chars: "Only letters, numbers, and underscores"
- Too short: "At least 3 characters"
- Counter: "[n] / 20"
- Button: "Continue"

---

### S06 — Email Confirmed

**Goal:** Celebrate account creation milestone. Reset emotional energy before profile setup.

**User mindset:** Relieved. "The hard part is done?" Receptive to positive reinforcement.

**Content hierarchy:**
1. Centered success animation (green circle + checkmark, pulse 1.5s then idle)
2. Milestone H1 title (Fraunces, large)
3. What's-next body text (1–2 sentences)
4. Primary CTA

**Key components:** Success animation (Lottie or SwiftUI), H1 title, body, primary button, optional confetti (respects `prefers-reduced-motion`). No back button.

**Primary CTA:** "Set up your profile →" → S07
**Navigation:** No back. NavigationStack replaces S01–S05 back stack. Haptic: `.success` on appear.

**Edge cases:** Re-reaching this screen via deep link edge case: show same content, CTA → S07

**Accessibility:**
- Animation `accessibilityLabel`: "Account verified successfully"
- `reduceMotion`: replace with static checkmark
- Screen announced via accessibility notification on appear

**Microcopy:**
- Title: "You're in."
- Body: "Your university email is verified. Now let's make your profile so others can find you."
- Button: "Set up my profile →"

---

### S07 — Avatar & Display Name

**Goal:** Give the user a visual identity. Should feel like personalizing, not form-filling.

**User mindset:** Engaged. Identity-building is intrinsically motivating.

**Content hierarchy:**
1. Progress indicator (now on "Profile" segment)
2. Screen title + subtitle
3. Avatar selection: large preview (80×80pt) + grid of 8–10 defaults
4. "Upload photo" option at end of grid
5. Display name input
6. Helper text
7. Primary button

**Key components:**
- Large current avatar preview circle: 80×80pt, `2pt #C47B5A` ring
- Avatar grid: 52×52pt circles, 12pt spacing, 3 per row
- Selected state: `3pt #C47B5A` ring
- "Upload photo" cell: camera icon, dashed border
- Display name input (max 30 chars)
- Default avatar pre-selected on load (user always has valid state)

**Primary CTA:** "Continue" → S08
**Secondary CTA:** "Upload photo" → system image picker sheet

**System feedback:**
- Avatar tap: selected avatar springs to preview (scale 1.0→1.1→1.0, 250ms)
- Upload fails: toast "We couldn't upload that image — try a different one"
- Empty display name on "Continue": inline error

**Accessibility:**
- Each avatar: `accessibilityLabel` = "Avatar [N]: [description]"
- Selected: "Selected" in label
- Upload button: `accessibilityLabel` = "Upload a custom profile photo"

**Microcopy:**
- Screen title: "How do you want to appear?"
- Avatar section label: "Choose an avatar"
- Upload cell: "Upload photo"
- Display name label: "Display name"
- Placeholder: "e.g. Jinsoo Kim"
- Helper: "This is the name others will see. You can change it anytime."
- Empty error: "Please add a display name"
- Upload error: "We couldn't upload that image — try a different one"
- Button: "Continue"

---

### S08 — App Language

**Goal:** Set preferred interface language. Quick, low emotional weight.

**Content hierarchy:**
1. Progress indicator
2. Screen title + subtitle
3. Scrollable language list (each 60pt row)
4. Primary button

**Key components:**
- Each row: language name in that language + English translation (e.g., "中文 (Chinese)")
- Selected row: `#C47B5A` trailing checkmark, `#FFF5EE` row background
- Default pre-selected from device locale

**Primary CTA:** "Continue" → S09
**Navigation:** Back → S07

**System feedback:** Tap row → checkmark moves with 150ms fade-in. Language change reflects immediately in subsequent screens.

**Edge cases:** Device locale not in supported languages → default English

**Microcopy:**
- Screen title: "What language do you prefer?"
- Subtitle: "You can always change this in Settings."
- Languages: English, 中文 (Chinese), 한국어 (Korean), Español (Spanish), हिन्दी (Hindi), Tagalog, Português (Portuguese), العربية (Arabic), Français (French), 日本語 (Japanese)
- Button: "Continue"

---

### S09 — City & School

**Goal:** Anchor the user to a local community. Makes recommendations immediately useful.

**User mindset:** Cooperative. "Makes sense that they need to know where I am."

**Content hierarchy:**
1. Progress indicator ("Location" segment)
2. Screen title + subtitle
3. City selection (search/dropdown)
4. School selection (appears after city selected — progressive disclosure)
5. Helper context text
6. Primary button

**Key components:**
- City input: searchable dropdown, 56pt height; opens as bottom sheet with search + scrollable list
- School input: same component, filtered to selected city; disabled + grayed until city chosen
- "My school isn't listed" link at bottom of school list
- Button disabled until both filled

**Primary CTA:** "Continue" → S10
**Secondary CTA:** "My school isn't listed" → converts to free-text input

**System feedback:**
- City selected: school field unlocks with slide-in (spring, 250ms)
- Selection confirmed: trailing checkmark on field
- Manual school entry: info message appears

**Edge cases:**
- City with one school: auto-select school, skip picker
- No city match: "We don't cover that city yet — try a nearby city"

**Microcopy:**
- Screen title: "Where are you studying?"
- Subtitle: "We'll show you gatherings in your area."
- City label: "Your city" / Placeholder: "Search for your city…"
- School label: "Your school" / Locked placeholder: "Select your city first" / Unlocked: "Search for your school…"
- School helper: "We'll use this to connect you with students from your campus."
- No city match: "We don't cover that city yet — try a nearby city"
- School not listed: "My school isn't listed"
- Manual school info: "Thanks! We'll add your school soon."
- Button: "Continue"

---

### S10 — Cultural Tags

**Goal:** Let the user optionally declare cultural background, languages, and interests. Skip path must be as dignified as the fill path.

**User mindset:** Mixed. Some eager to self-identify; others guarded about ethnicity data. Screen framing is everything.

**Content hierarchy:**
1. Progress indicator ("Tags" segment)
2. Screen title (reassuring, not clinical)
3. Single benefit-framing sentence
4. Section 1: Cultural background chips
5. Section 2: Languages chips
6. Section 3: Interests & vibe chips
7. "Skip for now" button (secondary style, full-width)
8. "Find my people →" primary button (full-width)
9. Fine print: "You can always update these in your profile."

**Key components:**
- 3-section chip group layout (wrapping flow)
- Section label: 14pt Plus Jakarta Sans semibold, `#6B5E57`
- Selection counter per section: "[n] selected" caption
- Chips: multi-select, terracotta on select
- Chip tap: scale 1.0→0.95→1.0 spring (150ms)
- Both buttons always enabled (tags always optional)

**Primary CTA:** "Find my people →" → S11
**Secondary CTA:** "Skip for now" → S11 (identical outcome, no penalty)

**Navigation:** Back → S09. Selections preserved on back.

**Edge cases:**
- 0 chips selected + primary tapped: goes to S11 normally, no blocking
- Skip and primary are functionally identical — treat identically in navigation

**Accessibility:**
- Each chip: `accessibilityTraits` = `.button`, `accessibilityValue` = "Selected"/"Not selected"
- Both buttons full-width, 56pt height

**Chip lists:**
- Background: Korean, Filipino, Chinese, Indian, Nigerian, Brazilian, Vietnamese, Mexican, Jamaican, Japanese, Lebanese, Peruvian, Ethiopian, Pakistani
- Languages: Mandarin, 한국어, Hindi, Tagalog, Português, Español, العربية, Français, 日本語, Wolof, Amharic
- Interests: Food & Cooking, Study Sessions, Chill & Hangout, Music, Sports, Art & Culture, Nightlife, Language Exchange, Film & TV, Hiking & Outdoors, Board Games, Tech & Coding

**Microcopy:**
- Screen title: "Tell us a little about yourself"
- Subtitle: "We'll use this to find gatherings that feel like home. Everything here is optional."
- Section 1: "Your cultural background"
- Section 2: "Languages you speak"
- Section 3: "What you're into"
- Counter: "[n] selected"
- Fine print: "You can always update these in your profile."
- Skip button: "Skip for now"
- Primary button: "Find my people →"

---

### S11 — Onboarding Complete

**Goal:** Celebrate completion. Create anticipation for the main app. This should feel like arrival, not task completion.

**User mindset:** Ready to explore. "Setup" feeling should be completely gone.

**Content hierarchy:**
1. Large celebration illustration (diverse group, warm, illustrated) — top 50%
2. Personalized H1 title (Fraunces, uses display name)
3. Location-aware teaser body text
4. Primary CTA (large, enthusiastic)

**Key components:** Illustration, personalized H1, location-aware body, primary button. No back button.

**Primary CTA:** "See what's happening in [city] →" → Main app TabView (S12)
**Navigation:** NavigationStack root replaced with TabView. Back stack cleared entirely. Haptic: `.success`. Optional confetti (respects `prefers-reduced-motion`).

**Edge cases:**
- No tags (skipped): "See what's happening in [City]"
- Has tags: "We found [N] gatherings that match your vibe in [City]. Let's go."

**Microcopy:**
- Title (with name): "Welcome to Belong, [Display Name]."
- Title (fallback): "You're all set."
- Body (with tags + location): "We found [N] gatherings that match your vibe in [City]. Let's go."
- Body (generic): "There's a lot happening in [City]. Come see."
- Button: "See what's happening →"

---

### S12 — Home Feed

**Goal:** Deliver immediate, relevant value. User should see something they want to attend within 5 seconds.

**User mindset:** Curious, potentially skeptical. Low patience, high expectation.

**Content hierarchy:**
1. Nav bar: "Belong" wordmark (left) + notification bell (right)
2. Location chip: "[City] ▾" (tappable, pill style)
3. "Top pick for you" section label
4. Hero top pick card (full-width minus margins, 220pt image height)
5. Horizontal filter chips row (scrollable, sticky on scroll)
6. "Recommended for you" section label
7. Vertical gathering card feed
8. "Browse all gatherings →" text CTA at feed bottom

**Gathering card spec:**
- Width: full-width minus 40pt (20pt each side)
- Image: 16:9, top of card
- Badge overlay (top-left): cultural tag chip(s), terracotta
- Below image (16pt padding): title (H2 Fraunces), host line (20pt avatar + name + rating), date/time, location, attendee count
- Bookmark icon (top-right of image): 44×44pt

**Hero card additions over standard card:**
- Image height: 200pt
- "Top pick" badge (gold pill, top-left)
- Trust signal row: "X people from [School] are going"

**Primary CTA:** Tap any card → S13
**Secondary CTA:** Tap bookmark → inline save (no navigation)

**System feedback:**
- Skeleton loaders on initial load + pull-to-refresh (3 ghost cards)
- Bookmark: fills terracotta, spring animation, haptic `.light`
- Filter: feed updates inline, fade transition 200ms
- Pull-to-refresh: standard spinner

**Edge cases:**
- No recommendations (new user): show "Popular near [City]" with different section label
- No gatherings in city: full-screen empty state
- Notification bell: badge count when unread

**Accessibility:**
- Card `accessibilityLabel`: "[Title], [Date], [Location], [N] people going"
- Bookmark: "Save [title]" / "Unsave [title]"
- Filter chips: toggle buttons with selected state

**Microcopy:**
- Location pill: "[City] ▾"
- Top pick section: "Top pick for you"
- Hero trust signal: "[N] people from [School] are going"
- Filter chips: "All", "Food", "Language Exchange", "Study", "Music", "Sports", "Art", "Chill"
- Recs section: "Recommended for you"
- Card date format: "Sat, Apr 12 · 6:00 PM"
- Attendee count: "[N] going"
- Feed bottom: "Browse all gatherings →"
- Empty state title: "Nothing here yet"
- Empty state body: "Gatherings in [City] are just getting started. Check back soon."
- Empty CTA: "Explore other cities"

---

### S13 — Gathering Detail

**Goal:** Give the user everything needed to decide: join, maybe, save, or skip. Reduce uncertainty and social anxiety.

**User mindset:** Interested but evaluating. "Is this worth going to? Will I fit in?"

**Content hierarchy:**
1. Full-bleed hero image (240pt, no nav bar overlay)
2. Floating back button (top-left, over image, circular white bg)
3. Floating bookmark icon (top-right, over image)
4. [Below image, scrollable]:
   - Cultural tag chips (small, non-interactive)
   - Gathering title (H1, Fraunces)
   - Host row (avatar + name + star rating, tappable)
   - Date/time row (calendar icon)
   - Location row (map pin icon, tappable → Maps)
   - Attendee faces row (5 avatars + "[N] people going", tappable)
   - Trust signal (if applicable)
   - Divider
   - Full description
5. Fixed bottom action bar (floats above content, safe-area aware):
   - "Join" (primary, larger)
   - "Maybe" (secondary, smaller)

**Primary CTA:** "Join" → loading → BS01 Join Confirmation
**Secondary CTA:** "Maybe" (inline toggle) / bookmark icon

**Navigation:** Push from S12 or S14. Back returns to origin scroll position.

**System feedback:**
- Join: loading spinner (disabled during call, 300ms max)
- Join success: brief pulse "Joined ✓" → BS01 slides up
- Already joined: "Joined ✓" green disabled button + "Leave" ghost link
- Maybe: button fills gold/warm tint, label "Interested"

**Edge cases:**
- Gathering full: "Join" disabled, "Full — join waitlist?" shown
- Past gathering: action bar shows "This gathering has passed"
- Host viewing own gathering: "Edit" + "Cancel gathering" in action bar
- Location TBD: row shows "Location TBD" (no Maps tap)

**Accessibility:**
- Image: `accessibilityLabel` = "[Title] cover image"
- Host row: "Hosted by [name], rated [X] stars"
- Attendee faces: "[N] people are going to this gathering"
- Location: "Location: [address], tap to open in Maps"

**Microcopy:**
- Host row: "Hosted by [Name] · ⭐ [4.8]"
- Date/time: "Saturday, April 12 at 6:00 PM"
- Attendee: "[N] people going · [N] from [School]"
- Description header: "About this gathering"
- Join: "Join" / Joined: "Joined ✓" / Leave: "Leave gathering"
- Maybe: "Maybe" / Active: "Interested"
- Full: "This gathering is full" / Waitlist: "Join the waitlist"
- Past: "This gathering has ended"

---

### S14 — My Events List

**Goal:** Central hub for the user's joined, upcoming, and past events.

**User mindset:** Task-oriented. "What's coming up?" or "I need to check something."

**Content hierarchy:**
1. Nav bar: "My Events"
2. Segmented control: "Upcoming" | "Past" | "Saved"
3. Content of selected segment

**Key components:**
- Segmented control (3 segments, `#C47B5A` active tint)
- Upcoming: cards with "Chat" secondary button
- Past: cards with emoji feedback state ("Rate" CTA if feedback not given)
- Saved: bookmarked cards
- Empty states per segment

**Primary CTA:** Tap card → S13
**Secondary CTA (Upcoming):** "Chat" button → S16

**System feedback:**
- "Rate" badge: small terracotta dot/pill on past event cards
- "Today" badge (gold) on cards for same-day events
- "Starting soon" badge (gold) if event < 1 hour away
- Pull-to-refresh on each segment

**Microcopy:**
- Nav title: "My Events"
- Segments: "Upcoming", "Past", "Saved"
- Upcoming empty: "No upcoming gatherings yet" + "Browse gatherings →"
- Past empty: "Attend a gathering to see your history here."
- Saved empty: "Tap the bookmark on any gathering to save it here."
- Chat button: "Chat"
- Rate badge: "Rate"
- Today badge: "Today"
- Starting soon badge: "Starting soon"

---

### BS01 — Join Confirmation (Bottom Sheet)

**Goal:** Confirm the join action and reduce post-join anxiety. Celebrate the decision.

**User mindset:** Just committed. Needs immediate reassurance — not more questions.

**Content hierarchy (in sheet):**
1. Drag handle
2. Success animation (brief, auto-play)
3. Title (celebratory)
4. Event summary (title, date, time)
5. Attendee social proof
6. "Add to calendar" button (secondary style)
7. "Done" ghost link

**Sheet height:** ~380pt (half-height)

**Primary CTA:** "Add to calendar" → calendar permission → event created → dismiss
**Secondary CTA:** "Done" → dismiss, return to S13

**System feedback:**
- Calendar added: "Added to [Calendar Name] ✓" inline, dismiss after 1.5s
- Permission denied: gentle nudge + Settings deep link, "Done" always available

**Accessibility:**
- Sheet announced as modal
- Animation `accessibilityLabel`: "Joined successfully"
- Calendar button: "Add [title] to your calendar"

**Microcopy:**
- Title: "You're going! 🎉"
- Subtitle: "[Title] · [Date] at [Time]"
- Social proof: "[Name], [Name], and [N] others are going"
- Calendar button: "Add to my calendar"
- Calendar added: "Added to your calendar ✓"
- Calendar denied: "Allow calendar access in Settings to get reminders"
- Done: "Done"

---

### S16 — Group Chat

**Goal:** Connect attendees before the event. Surface logistics (where exactly to meet, what to bring).

**User mindset:** Curious, mildly nervous. "Who else is going?"

**Content hierarchy:**
1. Nav bar: event title (truncated) + back + attendee count icon
2. Pinned host message banner (collapsible, if exists)
3. Message feed (chronological, newest at bottom)
4. Text composer + send button (safe-area aware)

**Key components:**
- Pinned banner: terracotta left border, collapsible
- Outgoing bubbles: `#C47B5A` fill, right-aligned
- Incoming bubbles: `#FEFCF9`, left-aligned, with avatar + name (first message per sender)
- Timestamp dividers: date headers, centered, caption style
- Composer: 56pt height, 16pt corner radius, multi-line up to 4 lines
- Send button: enabled when non-empty, `#C47B5A`
- New message indicator: "↓ New messages" floating badge if scrolled up

**Primary CTA:** Send message
**Secondary CTA:** Tap attendee count → attendee list sheet

**Navigation:** Push from S14. Back → S14.

**System feedback:**
- Optimistic UI (message appears immediately)
- Failed message: red "!" with retry
- Keyboard: list scrolls to bottom automatically

**Edge cases:**
- 0 messages: "Be the first to say hello" empty state
- Host viewing: "You're the host — pin a message to welcome your guests" prompt
- Gathering cancelled: "This gathering was cancelled. Chat is no longer active."
- Very long messages: wrap, max 70% screen width

**Microcopy:**
- Nav subtitle: "[N] people going"
- Pinned prefix: "📌 From the host:"
- Empty title: "No messages yet"
- Empty body: "Be the first to say hello — everyone here is going to [Event Name]."
- Composer placeholder: "Message the group…"
- Failed: "Couldn't send — tap to retry"
- Cancelled: "This gathering has been cancelled."
- New messages: "↓ [N] new messages"

---

### BS02 — Post-Event Feedback (Bottom Sheet)

**Goal:** Capture emoji rating with one tap. Must feel like a moment, not a survey.

**User mindset:** Low energy, post-event. Any friction = skip.

**Content hierarchy (in sheet):**
1. Drag handle
2. Warm prompt question (Fraunces)
3. Event title + host name (context, small)
4. Emoji row: 5 emojis, each 64×64pt
5. Emoji label (appears on selection)
6. Skip link

**Sheet height:** ~300pt

**Emojis (left to right):** 😕 🙂 😊 🎉 🤝
**Labels:** "Not great", "It was okay", "Pretty good", "Amazing!", "Made a connection!"

**Primary CTA:** Tap emoji → selection + auto-transition to BS03 after 800ms
**Secondary CTA:** "Skip" → dismiss, no data sent

**System feedback:**
- Emoji tap: selected scales 1.0→1.3 (spring 200ms), others fade to 0.5 opacity
- Haptic: `.medium` on selection
- After 800ms: transition to BS03 (or dismiss if no attendees)

**Edge cases:**
- Feedback already given: sheet doesn't appear; card shows selected emoji (grayed)
- No attendees: skip BS03, dismiss directly

**Accessibility:**
- Each emoji: `accessibilityLabel` = label text
- Selection announced by VoiceOver
- Skip: 44pt tap target

**Microcopy:**
- Prompt: "How was [Event Name]?"
- Context: "Hosted by [Host Name]"
- Skip: "Skip for now"

---

### BS03 — Save Connections (Bottom Sheet)

**Goal:** Prompt the user to save connections made at the event. Fast and optional.

**User mindset:** Post-feedback warmth. Receptive but not wanting more friction.

**Content hierarchy (in sheet):**
1. Drag handle
2. Title
3. Subtitle
4. Attendee list (up to 5 rows visible, scrollable)
   - Each row: 40pt avatar + display name + school + "Connect" button
5. "Done ([N] connected)" button (appears after any connection made)
6. "Skip" ghost link

**Sheet height:** Variable, max 75% screen height

**Primary CTA:** "Connect" per individual (independent actions)
**Secondary CTA:** "Skip" → dismiss

**System feedback:**
- Connect tap: "Connect" → "Connected ✓" (green), haptic `.light`
- Network failure: revert to "Connect", inline retry
- After any connect: "Done ([N] connected)" appears at bottom

**Edge cases:**
- Only user attended: BS03 skipped entirely
- All attendees already connected: show all "Connected ✓", skip to "Done"

**Microcopy:**
- Title: "People you met at [Event Name]"
- Subtitle: "Save them as connections for future gatherings."
- Connect: "Connect" / Connected: "Connected ✓"
- Done: "Done ([N] connected)"
- Skip: "Skip"

---

### S19 — Template Picker

**Goal:** Lower the psychological barrier to hosting. Make the starting point feel achievable, not blank.

**User mindset:** Motivated but potentially intimidated. "What kind of gathering can I actually do?"

**Content hierarchy:**
1. Nav bar: "Host a gathering" + X to cancel
2. Screen title + subtitle
3. 2-column template card grid (scrollable)

**Template card spec:** 160×180pt, 20pt corner radius, 48pt icon, name (H3), 1-line description
**Card tap:** scale spring animation (150ms) → navigate to S20

**Templates:**

| Name | Description |
|------|-------------|
| Potluck Dinner | Everyone brings a dish from home |
| Language Exchange | Practice languages together in a casual setting |
| Movie Night | Watch something together, share snacks |
| Study Group | Focused studying with good company |
| Cultural Festival | Celebrate a cultural event or holiday |
| Game Night | Board games, card games, good vibes |

**Primary CTA:** Tap template → S20
**Secondary CTA:** X → dismiss to Host tab

**Navigation:** Full-screen sheet from Host tab. X dismisses.

**Microcopy:**
- Nav title: "Host a gathering"
- Screen title: "What kind of gathering?"
- Subtitle: "Choose a template to get started — you can customize everything."

---

### S20 — Customize Form

**Goal:** Flesh out gathering details. Smart defaults from template reduce blank-field anxiety. Should not feel like a form.

**User mindset:** Creative, purposeful. "This is becoming real." Some anxiety about whether anyone will come.

**Content hierarchy:**
1. Nav bar: "< Templates" + "Save draft" (right)
2. Section: Details — title field, description field
3. Section: When — date/time field
4. Section: Where — location field
5. Section: Settings — max attendees stepper, cultural tags
6. Sticky "Preview →" button (bottom, keyboard-aware)

**Key components:**
- All inputs: standard input spec (56pt, 12pt radius)
- Description: multi-line, auto-grows up to 8 lines
- Date/time: field tap → system DatePicker as bottom sheet
- Location: text input + Apple Maps autocomplete dropdown
- Max attendees stepper: minus (44pt) | number display | plus (44pt), range 2–50
- Tag chips: same as S10, pre-selected from template
- Sticky button moves up with keyboard

**Primary CTA:** "Preview my gathering →" → S21 (if all required fields valid)
**Secondary CTA:** "Save draft" (nav bar) → save + return to Host tab

**Navigation:** Push from S19. Back with confirm dialog if any field edited.

**System feedback:**
- Required field empty on preview: scroll to first empty, red border + shake
- Past date: inline error on date field
- Draft saved: toast "Draft saved — you can continue anytime"
- Max attendees at min: minus disabled; at max: plus disabled

**Edge cases:**
- Back without saving: "Save your changes?" → "Save draft" / "Discard changes" / "Keep editing"
- Location not in autocomplete: allow free-text
- Title duplicate: allowed (no uniqueness required)

**Required fields:** title, date/time, location

**Microcopy:**
- Nav title: "Customize your gathering"
- Save draft button: "Save draft"
- Sections: "Details", "When", "Where", "Settings"
- Title label: "Gathering name"
- Description label: "Description"
- Description placeholder: "Tell people what to expect, what to bring, and the vibe."
- Date label: "Date & time" / Placeholder: "Set a date and time"
- Location label: "Location" / Placeholder: "Search for a venue or address"
- Max attendees label: "Max attendees" / Helper: "How many people can come? (2–50)"
- Tags label: "Cultural tags" / Helper: "Help the right people find this gathering."
- Empty field error: "This field is required"
- Past date error: "Please choose a future date and time"
- Preview button: "Preview my gathering →"
- Draft saved toast: "Draft saved — you can continue anytime"
- Back dialog title: "Save your changes?"
- Back options: "Save draft", "Discard changes", "Keep editing"

---

### S21 — Preview & Publish

**Goal:** Show the user exactly what others will see. Build confidence before publishing.

**User mindset:** Excited but second-guessing. "Does this look good enough?"

**Content hierarchy:**
1. Nav bar: "< Edit" + "Preview" title
2. Informational banner: "This is how your gathering will appear to others"
3. Rendered gathering card (exact same component as S12/S13)
4. Details summary list (text review of all fields)
5. "Publish gathering" primary button
6. "Edit" secondary button

**Primary CTA:** "Publish gathering" → loading → S22
**Secondary CTA:** "Edit" → back to S20

**System feedback:**
- Tap publish: "Publishing…" with spinner, disabled
- Success: navigate to S22
- Failure: toast error "Couldn't publish — your draft is saved. Try again." Button re-enables.

**Edge cases:**
- No gathering image: placeholder illustration from template category
- Race condition (date now past): error "This date has passed — please edit your gathering"

**Microcopy:**
- Nav title: "Preview"
- Banner: "This is how your gathering will look to others"
- Details header: "Gathering details"
- Publish button: "Publish gathering" / Loading: "Publishing…"
- Edit button: "Edit"
- Publish failure: "Couldn't publish — your draft is saved. Try again."
- Past date: "This date has passed — update the date before publishing"

---

### S22 — Published Confirmation

**Goal:** Celebrate the hosting milestone. Reassure against "what if nobody comes?" anxiety.

**User mindset:** Proud but anxious. Combat the empty-gathering fear before it surfaces.

**Content hierarchy:**
1. Success illustration
2. H1 title (Fraunces)
3. Body text: what happens next (3 bullets)
4. Share button (secondary)
5. "View my gathering" primary button
6. "Back to home" ghost link

**Primary CTA:** "View my gathering" → S13 (host mode)
**Secondary CTA:** "Share your gathering" → system share sheet

**Navigation:** Back stack cleared for hosting flow. No back button. Tab bar still accessible.

**System feedback:** Haptic `.success` on appear. Share → system sheet (doesn't navigate away).

**Microcopy:**
- Title: "Your gathering is live!"
- Body intro: "People are already discovering it on Belong. A few things to know:"
- Bullet 1: "Post a welcome message in the group chat to greet attendees."
- Bullet 2: "You'll get a notification when people join."
- Bullet 3: "You can edit or cancel the gathering from your profile."
- Share button: "Share your gathering"
- View button: "View my gathering"
- Back link: "Back to home"

---

### S23 — Profile

**Goal:** Identity hub. Show how the user appears to others. Control center for tags and settings.

**User mindset:** Reflective. "How do I look to others?" or "I want to update something."

**Content hierarchy:**
1. Nav bar: "Profile" + settings gear (right)
2. Avatar (80×80pt) with edit overlay (camera icon, bottom-right)
3. Display name (H1, Fraunces)
4. School + city (body, `#6B5E57`)
5. Stats row: "[N] attended · [N] hosted · [N] connections"
6. Cultural tags section (chip display, read-only + "Edit" link)
7. Saved gatherings row (tappable, shows count)
8. Connections section (if any, avatar faces row)

**Primary CTA:** "Edit profile" / tap avatar → profile edit flow
**Secondary CTA:** Settings gear → S26

**Navigation:** Tab 4 root. Tab bar always visible.

**Edge cases:**
- New user (0 gatherings): placeholder text under each section
- No connections: connections section hidden entirely

**Microcopy:**
- Nav title: "Profile"
- Stats: "[N] attended", "[N] hosted", "[N] connections"
- Tags header: "Your cultural tags"
- Edit tags link: "Edit"
- Tags empty: "Add your cultural background, languages, and interests. [Add tags →]"
- Saved row: "Saved gatherings ([N])"
- Connections row: "[N] connections"

---

### S24 — Edit Cultural Tags

**Goal:** Update cultural identity tags at any time. No onboarding pressure.

**Key differences from S10:**
- "Save" button in nav bar (right, disabled until change made)
- No "Skip for now"
- "Clear all" ghost text link at bottom
- Current selections pre-populated from profile

**Primary CTA:** "Save" (nav bar) → save, pop to S23
**Secondary CTA:** "Clear all" → confirmation dialog

**System feedback:**
- Save: "Tags updated ✓" toast, pop to S23
- Clear all dialog: "Clear all tags? Your recommendations will reset." → "Clear all" (red) / "Cancel"
- No changes made: "Save" stays disabled, back requires no confirmation

**Microcopy:**
- Nav title: "Cultural tags"
- Save: "Save" / Saved toast: "Tags updated ✓"
- Clear all: "Clear all tags"
- Clear dialog title: "Clear all tags?"
- Clear dialog body: "Your recommendations will be reset and you'll see general gatherings until new tags are set."
- Dialog: "Clear all" (destructive) / "Cancel"
- Discard dialog: "Discard changes?" → "Discard" / "Keep editing"

---

### S25 — Saved Gatherings

**Goal:** Quick access to bookmarked events.

**User mindset:** Purposeful. "I saved something earlier — let me find it."

**Content hierarchy:** Nav bar "Saved" + list of saved gathering cards

**Primary CTA:** Tap card → S13
**Secondary CTA:** Swipe left → "Remove" delete action

**System feedback:**
- Swipe delete: card slides out, list reflows
- Undo toast: "Removed from saved. Undo" (3s)

**Edge cases:**
- Cancelled gathering: "Cancelled" badge on card, still viewable
- Past gathering: "Ended" badge

**Microcopy:**
- Nav title: "Saved"
- Empty title: "Nothing saved yet"
- Empty body: "Tap the bookmark on any gathering to save it here."
- Empty CTA: "Browse gatherings"
- Delete action: "Remove"
- Undo: "Removed from saved. Undo"

---

### S26 — Settings

**Goal:** Account management and preferences. Quiet back room — rarely visited, but organized.

**User mindset:** Purposeful. Looking for something specific.

**Content hierarchy:**
1. Nav bar: "Settings" + back
2. Account section: Email (read-only), Change password, Notifications
3. Preferences section: App language, City
4. About section: Terms, Privacy, App version
5. Account actions: Log out (terracotta), Delete account (red)

**Key components:** Grouped list sections, read-only rows (trailing value), toggle rows, destructive rows

**Destructive actions:**
- Log out: confirmation dialog → clear session → S01
- Delete account: multi-step confirmation — destructive, permanent

**Microcopy:**
- Nav title: "Settings"
- Account section: "Email", "Change password", "Notifications"
- Preferences section: "App language", "Your city"
- About section: "Terms of Service", "Privacy Policy", "App version [1.0.0]"
- Actions section: "Log out" (terracotta text), "Delete account" (red text)
- Log out dialog: "Log out of Belong?" → "Log out" (terracotta) / "Cancel"
- Delete dialog: "This will permanently delete your account and all your data. This cannot be undone." → "Delete my account" (red) / "Cancel"

---

## PART C: EDGE CASE CATALOG

| Scenario | Screen | Behavior |
|----------|--------|---------|
| User already logged in on app launch | S01 | Skip to S12 |
| Incomplete onboarding, app relaunched | Any | Resume at last completed step |
| .edu email already registered | S02 | Inline error + "Log in" link |
| OTP expires | S03 | Auto-detect, auto-resend, restart timer |
| 3 wrong OTP attempts | S03 | Auto-resend, clear field |
| No gatherings in city | S12 | Full-screen empty state |
| Gathering is full | S13 | Join disabled, waitlist option |
| User is the host viewing their event | S13 | "Edit" + "Cancel" instead of Join/Maybe |
| Gathering was cancelled | S13, S25 | "Cancelled" badge on card |
| Date passes while on form | S20, S21 | Catch on publish |
| No attendees at event | BS03 | Skip BS03 entirely |
| Feedback already given | S14 | Emoji shown on card, no re-prompt |
| Hosting draft exists | Host tab | "Continue draft" banner on tab |
| Calendar permission denied | BS01 | Gentle nudge, "Done" always available |
| Network failure on join | S13 | Toast error, button re-enables |
| Network failure on publish | S21 | Toast error, draft preserved |
