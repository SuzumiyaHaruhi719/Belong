# Belong -- UI/UX Reference Guide
## Real-World Product References for a Cultural Community App

Compiled from research across shipping products. Focused on patterns applicable to Belong's warm, organic, culturally-rich design direction.

---

## 1. Community/Social Apps with Warm, Organic Design

### Partiful (Event Invitations)
- **Visual identity**: Gradient-forward design with soft, blurred backdrop effects. Layered geometric shapes and blobs in pastel tones. "Frosted glass" glassmorphism via backdrop filters and transparency.
- **Typography**: Custom branded typefaces ("Partiful Display Medium/Bold" + "TWK Lausanne Pan") -- a display serif paired with a neutral sans-serif. Friendly yet sophisticated tone.
- **Color**: White backgrounds with soft gradients, cyan/electric blue (#09f) accents, warm orange (#ffae00). Heavy transparency layers creating depth.
- **Event cards**: Clean grid layouts, rounded corners (12-20px radius), soft shadows, generous whitespace. Floating decorative elements (geometric shapes, abstract illustrations) positioned throughout without overwhelming content.
- **What makes it distinctive**: The design feels like a celebration invitation, not a ticketing system. Emphasis on social joy. The gradient overlays, floating decorations, and deliberate whitespace position events as social moments rather than logistics.
- **Adapt for Belong**: The celebration-first attitude. Gathering cards should feel like invitations, not database entries. Consider subtle decorative flourishes (cultural motifs instead of abstract shapes). The playful personality in an otherwise clean layout.
- **Avoid**: The glassmorphism can read as trendy rather than warm. Belong's parchment/clay palette is warmer and more grounded.

### Geneva (Community Groups + Chat)
- **Core positioning**: "The online place to find your offline people" -- emphasis on local, in-person connections over digital-native interaction.
- **Typography**: "Fff Acidgrotesk" for headings (bold, contemporary), "Suisseintl" for body text (clean, international), "Roboto Mono" for technical elements. Creates a clean, modern but community-focused aesthetic.
- **Color palette**: Highlight yellow (#D7FF1D, energetic accent), Geneva Blue (#92CEFF, brand), Feather Gray (#DEDFEB, neutral backgrounds). High contrast black text on light backgrounds.
- **Key UI patterns**: Animated "sticker" icons with spring physics. Custom cursor states. Floating CTA containers with rounded corners and hover animations. Real groups displayed with actual names and member preview images (social proof).
- **What makes it distinctive**: Discovery-first rather than chat-first. "Find a group in your area" as primary UX, positioning as social discovery tool rather than communication infrastructure. Emphasizes authentic community formation.
- **Adapt for Belong**: The discovery-first mindset. Belong's gatherings tab should surface things to join, not just list events. The real-group social proof pattern (showing actual member faces and counts). The sticker/spring physics for interactive elements.
- **Avoid**: The neon yellow accent doesn't match Belong's warm palette. Geneva's aesthetic is more tech-forward than culturally warm.

### Luma (Event Platform)
- **Visual identity**: Modern, gradient-forward. Hero text uses a vibrant multi-stop gradient (blue #099ef1 through purple #6863f8 to pink #d84ffa to orange #ff891f). Aggressive, confident design language.
- **Typography**: Large, prominent headings (4rem desktop, 2.5rem mobile). Medium weight emphasis. Tight letter spacing (-1px) for visual impact. High line-height (1.03-1.1) for display text.
- **Layout**: Two-column asymmetrical on desktop with phone mockup offset (-40px to -50px margin) creating dynamic negative space. Mobile shifts to centered stacked. Backdrop blur in navigation.
- **What makes it distinctive**: Professional polish that doesn't feel corporate. Smooth transitions, generous padding (3rem base), confident gradient text. The "Start Here" framing makes event creation feel aspirational.
- **Adapt for Belong**: The generous padding and spacing philosophy. The confident, aspirational tone for creation flows ("Host a Gathering" should feel empowering). The tight letter-spacing on display headings.
- **Avoid**: Luma's gradients are tech/startup-coded. Belong should use warm solid colors and earth tones instead of rainbow gradients.

### Airbnb (Belonging + Community)
- **Visual identity**: The gold standard for warm, welcoming digital design. Custom "Airbnb Cereal VF" variable font family. Generous line-height (1.4+). Warm rausch pink (#FF385C) as primary accent. Cream backgrounds (#F7F7F7).
- **Spacing system**: Macro spacing (16px-80px) and micro spacing (2px-32px). Consistent border-radius (8px-24px). Five elevation levels with layered opacity shadows. 20:19 aspect ratios for listing images.
- **Card design**: Modular cards with soft shadows, rounded corners, high-quality imagery. Social proof (ratings, reviews) integrated naturally.
- **Search/filter**: Persistent search bar with gradient background transitions. Location + date + guest count bundled. Expandable search that scales across breakpoints.
- **Motion**: Spring-based animations (451-762ms) creating organic, natural feeling transitions.
- **What makes it distinctive**: Everything communicates "you belong here." Large imagery with gentle filters, generous whitespace reducing cognitive load, smooth micro-interactions. The entire visual language says warmth and welcome.
- **Adapt for Belong**: This is the north star for Belong's warm aesthetic. The spring-based motion (natural, organic feel). The generous whitespace philosophy. The way imagery is given room to breathe. The 20:19 aspect ratio for gathering cards. The layered shadow system. The "warm white" instead of "clinical white" approach.
- **Avoid**: Airbnb's pink accent reads as "accommodation" -- Belong's terracotta is more culturally grounded.

### Strava (Community + Activity Feed)
- **Feed philosophy**: Activity-based feed where "the way you post is by being active." All authentic content, no junk posts. Signature orange brand color.
- **Social interactions**: Kudos system (simple, low-friction recognition). Comments on activities. Clubs for group organization. Challenges with leaderboards.
- **Profile design**: Performance metrics and historical tracking. Training calendar. Personal records. Modular card-based layouts for activities with collapsible sections for detail.
- **What makes it distinctive**: Social features grow organically from the core activity. Recognition (kudos) is simpler than likes. Community (clubs) is organized around shared activity, not arbitrary grouping.
- **Adapt for Belong**: The kudos-style low-friction social interaction. The clubs-as-communities pattern for gatherings. The activity feed where content comes from real participation, not forced posting.
- **Avoid**: Strava's data-heavy, metric-forward approach is too utilitarian for Belong's warmer, more social positioning.

### BeReal (Authenticity-First Social)
- **Visual identity**: Dark-first design. Primary black (#000) background. Accent colors: cyan (#0ca), blue (#05f), orange (#ff5117).
- **Typography**: Inter (400-900) + Figtree (400-700) + Fragment Mono. Large headings (48px desktop, 32px mobile).
- **Design philosophy**: Authenticity through simplicity. Clean, minimal navigation. High contrast. Generous whitespace. User-generated content given priority through fixed positioning.
- **What makes it distinctive**: Anti-polished positioning. Content > chrome. The entire design serves authenticity rather than curation.
- **Adapt for Belong**: The authenticity-first philosophy. Gathering photos should feel real and warm, not stock-photo polished. The content-over-chrome principle where the UI disappears behind the community content.
- **Avoid**: BeReal's dark-mode-first and stark aesthetic is too cold for Belong. The app's ephemeral nature doesn't match Belong's community-building goals.

---

## 2. Onboarding Flows

### Best-in-Class Patterns from Shipping Products

**Duolingo -- Quiz-Style Progressive Disclosure**
- Starts with language selection (single big question per screen)
- Asks "Why are you learning?" (motivation profiling)
- Immediate micro-lesson before account creation (value before commitment)
- Progress bar always visible
- Delayed sign-up: asks for account AFTER the user has invested time
- Each step feels like a game, not a form

**Slack -- Complexity Hiding**
- Reduces initial setup to absolute minimum
- Channel discovery happens after entry, not during onboarding
- "Finding Your First Conversation" is contextual, not front-loaded
- Progressive feature revelation as user engages

**Pinterest -- Interest Selection**
- Visual grid of interest categories (not text lists)
- Image-heavy selection cards
- "Pick 5 topics" minimum threshold
- Immediate personalized feed after selection
- Selection feels like customization, not interrogation

**Clubhouse -- Social Discovery Onboarding**
- Contact import for social graph bootstrap
- Topic/interest selection cards
- Immediate recommendations based on selections
- "Finding Your First Conversation" challenge illustrates the difficulty of cold-starting community

### Patterns to Adapt for Belong's 11-Step Onboarding
1. **Single question per screen** (Duolingo) -- Belong already does this well
2. **Visual interest selection** (Pinterest) -- Cultural tags should be image/icon cards, not just text chips
3. **Progress bar** -- Always visible, warm-colored, shows how far along
4. **Delayed heavy commitment** -- Email/OTP early, but personality-expressing steps (avatar, cultural tags) should feel rewarding, not mandatory
5. **"Skip for now" parity** -- The skip button should feel equally valid as the proceed button (not second-class)
6. **Value preview** -- Before completing onboarding, show a preview of what the personalized feed will look like

### What to Avoid in Onboarding
- **Too many steps visible at once** (creates anxiety)
- **Form-like layouts** (text input after text input)
- **Mandatory fields that feel arbitrary** (why do you need my school before showing me anything?)
- **Generic welcome screens** with stock illustrations
- **No indication of progress** or how many steps remain

---

## 3. Event/Gathering Card Patterns

### Top Patterns from Shipping Products

**Partiful Cards**
- Image-forward with generous corner radius (12-20px)
- Soft shadows, not hard borders
- Decorative floating elements around cards
- Host avatar integrated into card
- RSVP count as social proof

**Luma Cards**
- Clean, editorial feel
- Date prominently displayed in a distinct typographic treatment
- Backdrop blur on overlaid text
- Asymmetric layouts creating visual interest

**Eventbrite Cards**
- Image overlay with text for destination/category cards
- Gradient overlays (blue-to-pink, green) on hero images
- Multiple entry points: category, geography, time-based
- "It-Lists" curated collections with gradient headers
- Clear distinction between organic and promoted/sponsored events

**Meetup Cards**
- Event photos with titles, date/time, organizer name
- Attendee photo thumbnails in a row (social proof)
- Attendance counts and fee info prominent
- Illustrative category icons (tree, pizza, ball, computer)

### Optimal Gathering Card Pattern for Belong
- **Hero image** with 20:19 or 4:3 aspect ratio, rounded corners (16-20px)
- **Cultural motif overlay** or subtle pattern border (not generic gradient)
- **Host avatar** integrated into card (bottom-left overlap or inline)
- **Attendee face stack** (3-4 overlapping avatars + "+12 going")
- **Cultural tag chips** visible on card (max 2-3, terracotta-toned)
- **Date/time** in a distinct typographic treatment (serif or bold, not buried in body text)
- **Location** with a subtle icon, secondary prominence
- **Soft warm shadow** using BelongShadow.level1 (warm brown-tinted, not pure black)

### What to Avoid
- Generic Material Design cards with hard borders
- Cards that look like database rows
- Too much information crammed in (pick 4-5 key pieces)
- Stock photo placeholder images
- Cards without social proof (no attendees visible)

---

## 4. Feed Layout Patterns

### Pinterest -- Masonry Grid
- 4px base spacing unit (matches Belong's approach)
- Dynamic card heights based on image aspect ratio
- Two-column masonry on mobile
- Spring-based motion with fast/medium/slow variants
- Search guides with color-coded category pills
- Semantic colors: error (red), warning (orange), success (green), info (blue), recommendation (purple)

### Instagram -- Single-Column Feed
- Feed width: 470px (standard)
- Border radius: 4px (cards), 6px (inputs), 8px (dialogs), 12px (modals)
- Button heights: 40px (large), 36px (medium)
- Hover overlay: 5% black (light mode)
- System fonts for maximum performance
- 60px tab height, 50px bottom toolbar

### Threads -- Text-Forward Feed
- Single-column layout optimized for readability (max 620px)
- Card-based architecture with 8px corner radius
- 74px header height, 60px post footer
- Chat bubbles: 18px border radius
- Side navigation: 260px expanded, 68px collapsed
- Facebook Design System (FDS) underpinning

### Recommended Feed Strategy for Belong
- **Posts feed**: Single-column, card-based (Instagram-like but warmer)
- **Gatherings feed**: Consider 2-column grid for discovery (Pinterest-influenced) OR single-column for immersive cards
- **Mixed content**: Posts and gatherings could interleave with visual distinction (gatherings have date badges, posts have like counts)
- **Pull-to-refresh**: Use a warm animation (cultural motif spinning, not generic spinner)
- **Skeleton loading**: Use BelongColor.skeleton (#E8DFD5) with warm highlight (#F2EBE2) -- already defined

### What to Avoid
- Infinite scroll without section breaks (causes fatigue)
- Every card looking identical (vary visual weight)
- Timeline-only ordering (mix in recommended/trending)
- Full-bleed images without padding (feels aggressive)

---

## 5. Profile Screen Patterns

### Strava Profiles
- Activity metrics prominently displayed
- Calendar/history visualization
- Personal records and achievements
- Modular card sections with collapsible detail
- Club memberships visible

### Instagram Profiles
- Avatar + name + bio at top
- Grid of posts below (3-column square thumbnails)
- Story highlights as scrollable circles
- Follow/follower counts as social proof
- Tab switching between posts/reels/tagged

### Threads Profiles
- Simpler than Instagram
- Text-forward (bio text more prominent than avatar)
- Recent posts inline (not grid)
- Follow button prominent

### Recommended Profile Pattern for Belong
- **Hero section**: Background image/gradient (using cultural theme colors) + large avatar (80-100pt) + name in serif (BelongFont.h1) + username in secondary
- **Cultural identity**: Cultural tag chips displayed prominently below bio (not hidden in settings)
- **Social proof row**: Followers | Following | Gatherings hosted/attended (tappable for detail)
- **Content tabs**: Gatherings | Posts | About (segmented control, not separate pages)
- **Gathering cards** in profile should be compact (horizontal scroll or 2-column)
- **Empty profile** should encourage: "Share your first cultural experience" with warm illustration
- **Follow/Connect button**: Primary terracotta when not following, outlined when following, with smooth state transition

### What to Avoid
- Dating-app style profile cards (swipe-based)
- Overly metric-heavy profiles (this isn't LinkedIn)
- Hiding cultural identity behind navigation
- Generic avatar placeholders (use culturally warm defaults)

---

## 6. Empty State Design Patterns

### NN/g Guidelines (Nielsen Norman Group)
Three core principles for empty states:
1. **Communicate system status**: Never leave containers totally blank. Clearly state whether content is loading, an error occurred, or no data exists.
2. **Provide learning cues (pull revelations)**: Use empty states for contextual help. Example: "Star your favorites to list them here" (DataDog). In-context learning is more memorable than tutorials.
3. **Provide direct pathways**: Include actionable buttons/links. Example: Loggly's empty state offers two paths -- "add log sources" or "explore with demo data."

### Anti-Patterns to Avoid
- Completely blank spaces with no explanation
- Misleading loading messages (showing "No records" then populating seconds later)
- Instructions without actionable steps
- Failing to explain what content could appear

### Warm Empty State Strategy for Belong

**Gatherings (empty feed)**
- Illustration: Warm, hand-drawn style showing diverse people gathering
- Headline (serif): "Your next adventure awaits"
- Body: "Discover cultural gatherings near you, or host your own"
- CTA: "Explore Gatherings" (primary) + "Host a Gathering" (secondary)

**Posts (empty feed)**
- Headline: "A blank canvas"
- Body: "Follow people and topics to fill your feed with cultural stories"
- CTA: "Find People" + "Browse Topics"

**Chat (no conversations)**
- Headline: "Start a conversation"
- Body: "Connect with people from your gatherings"
- CTA: "Browse Gatherings" (leads to social connection)

**Saved Items (empty)**
- Headline: "Nothing saved yet"
- Body: "Tap the bookmark icon on gatherings and posts to save them here"
- No CTA needed (instructional)

**Search (no results)**
- Headline: "No matches found"
- Body: "Try different keywords or browse by category"
- Show category chips as alternative paths

### Design Principles for Belong Empty States
- Use warm, culturally-diverse illustrations (not generic tech-style SVGs)
- Headline in serif (BelongFont.h2), body in sans (BelongFont.body)
- Terracotta primary CTA, outlined secondary
- Never leave a screen truly empty -- always provide a path forward
- Tone: encouraging and warm, never clinical ("Your next adventure" not "No data found")

---

## 7. Typography Systems

### Belong's Current System (Validated)
Belong uses **serif for display/headings + system sans-serif for body**. This is a strong, validated pattern.

### Fraunces (Belong's Reference Serif)
From the Fraunces GitHub repository:
- **Design philosophy**: "Old Style" soft-serif inspired by early 20th-century typefaces (Windsor, Souvenir, Cooper Series). Embraces deliberate irregularities and warmth. Nicknamed "wonky fonts" for intentional character quirks that feel handcrafted.
- **Four variable axes**:
  - `opsz` (Optical Size, 9-144pt): Adjusts contrast, x-height, spacing. Wonky features auto-disable at 18px and below for readability.
  - `wght` (Weight, 100-900): Thin through Black.
  - `SOFT` (Softness, 0-100): Unlocks softer, rounded letterforms.
  - `WONK` (Wonky, 0-1): Toggles between idiosyncratic characters and normalized forms.
- **Best for**: Display contexts where personality and warmth matter. Smaller optical sizes prioritize legibility for body text.

### Real-World Typography Precedents
- **Airbnb**: Custom "Airbnb Cereal VF" variable font. Generous line-height (1.4+). Warmth through font weight and spacing choices.
- **Discord**: Poppins (400-700) + Press Start 2P for playful accents. Language-specific adjustments (CJK line-height: 1.0).
- **Geneva**: Acidgrotesk (display) + Suisseintl (body) + Roboto Mono (technical). Contemporary community feel.
- **Partiful**: Custom display + TWK Lausanne Pan. Branded feel that's friendly yet sophisticated.
- **BeReal**: Inter (400-900) + Figtree (400-700). Large headings (48px desktop).

### Type Scale Recommendations (USWDS validated)
- **Body copy minimum**: 16px (font-size token 5+)
- **Headings line-height**: 1.0-1.35
- **Body line-height**: minimum 1.5
- **Line length**: 45-90 characters
- **Heading spacing**: 1.5x more whitespace above than below (closer to the text they introduce)
- **Serif for readability**: Serif works for extended content; sans-serif for UI controls and quick-scan elements

### Recommendation for Belong
The current system is sound. Key enhancements:
1. Consider loading actual Fraunces variable font (not just system serif) for more personality
2. Use Fraunces SOFT axis at 30-50 for headings (warm but not too decorative)
3. Use Fraunces WONK=1 for large display text (34pt+), WONK=0 for smaller headings
4. Maintain system sans-serif for body (performance + readability)
5. Add letter-spacing: -0.5px to -1px for display sizes (Luma precedent)

---

## 8. Color Palettes for Warm/Cultural/Community Apps

### Belong's Current Palette (Already Strong)
```
Primary Clay Terracotta: #B5694A
Pressed state:           #964E33
Lighter variant:         #D4956F
Muted background tint:   #E8C4B0
Background (Parchment):  #F8F0E7
Surface (White):         #FFFFFF
Surface Alt (Warm):      #FDF8F3
Peach wash:              #FAEDE3
Text Primary:            #1A1714
Text Secondary:          #5C5550
Sage Green:              #7FA07A
Gold:                    #C4922E
Tag chip BG:             #F0D4C8
Tag chip text:           #7A4F30
```

### Validated Reference Palettes

**Happy Hues Palette 11 (Warm Earthy)**
- Background: #f9f4ef (warm cream)
- Text: #020826 (deep navy -- stronger contrast than typical brown)
- Paragraph: #716040 (warm brown)
- Button: #8c7851 (muted gold-brown)
- Secondary: #eaddcf (soft beige)
- Accent: #f25042 (warm coral-red)
- This palette validates Belong's warm cream + earth tone direction.

**Airbnb's Warm System**
- Rausch pink: #FF385C (primary accent)
- Cream backgrounds: #F7F7F7
- Warm brown shadows
- Spring-based motion adds perceived warmth to interactions

### Warm Color Palette Principles (Refactoring UI)
- **Grey doesn't need to be neutral**: Add warm undertones to greys for organic feel
- **HSL over hex for control**: Easier to maintain consistent warmth across the palette
- **10+ shades per color family**: Comprehensive palettes need gradations for real UI work
- **Start with generous whitespace**: Warm colors need breathing room
- **Fewer borders, more shadows**: Substitute hard lines with warm-tinted soft shadows and background color changes

### Recommendations for Belong
1. Belong's palette is already well-differentiated from competitors (none use terracotta as primary)
2. Consider adding a **secondary accent** for variety: a warm coral (#E07B5F) or desert gold (#D4A03C) for secondary CTAs
3. Warm-tint all greys (already done: #5C5550, #9A938D have warm undertones)
4. Shadows should use warm brown base (#1A1714) not pure black (already done in BelongShadow)
5. The parchment background (#F8F0E7) is warmer than Airbnb's #F7F7F7 -- this is a strength

---

## 9. Tab Bar / Navigation Patterns

### Reference Points

**Instagram**: 60px tab height. Five tabs. Center "create" icon. 50px bottom toolbar. Clean icon-only with subtle active state.

**Threads**: 60px tab height. Side navigation (260px expanded, 68px collapsed). Bottom tab bar on mobile.

**Discord**: Custom tab bar with server list (left rail). Bottom tabs for mobile: Home, Friends, Search, Notifications, Profile.

**Pinterest**: 4px base spacing. Category-colored search guides. Five main tabs.

**Strava**: Activity-focused. Record button (center FAB). Social feed + clubs + profile tabs.

### Tab Bar Best Practices
- **5 tabs maximum** (Belong already uses 5: Gatherings, Posts, Create, Chat, Profile)
- **Center action button** (Create) can be elevated/distinct but shouldn't break the visual rhythm
- **Labels matter**: Icon-only tab bars have higher error rates. Short labels (1 word) under icons.
- **Badge design**: Numbered badges for unread (Chat). Dot-only badges for new content (Posts, Gatherings).
- **Active state**: Filled icon + label color change. Use BelongColor.primary (#B5694A) for active, BelongColor.textTertiary (#9A938D) for inactive.

### Recommended Tab Bar for Belong
- **Height**: 49pt (already defined in Layout.tabBarHeight)
- **Style**: Warm surface background (#FFFFFF or #FDF8F3) with subtle top border (#E2D9D0)
- **Icons**: SF Symbols with custom weight. Filled when active, outlined when inactive.
- **Create tab**: Could be a slightly larger icon (not a floating circle -- too aggressive for Belong's organic feel). Consider a warm-toned accent background behind the create icon only.
- **Labels**: 10pt medium weight (BelongFont.tabLabel). Active in terracotta, inactive in warm grey.
- **Badge**: Red dot (no number) for gatherings/posts. Numbered badge for unread chat messages.
- **Consider**: Subtle haptic feedback on tab switch. Warm micro-animation on active state change.

### What to Avoid
- Floating action buttons that cover content
- Tab bars that hide on scroll (disorienting)
- Icons without labels (accessibility issue)
- More than 5 tabs (cognitive overload)
- Tab bar that looks identical to iOS default (no brand identity)

---

## 10. Chat UI Patterns

### Reference Points

**Telegram Innovations**
- **Topics in groups**: Individual sub-chats within a group, each with its own shared media and notification settings. Functions like separate spaces within one group.
- **Interactive emoji**: Full-screen animated effects in 1:1 chats. Emoji doubling as reactions.
- **Message features**: Swipe-left-to-reply animation. Polls and pinned messages within topics.
- **Design refinements**: iOS dark theme improvements with better color balance. Android adjustable text sizing affecting all chat elements including link previews and reply headers.

**Discord Patterns**
- Voice + text channel separation
- Always-on availability: "Hop in when you're free, no need to call"
- Status visibility: See who's around
- Persistent spaces that remain active
- Game/activity status integration

**WhatsApp Patterns**
- Simple chat bubbles with emoji reactions (heart)
- Feature cards: Calling, Messaging, Groups, Channels, Status, Security
- Sticker replies
- Status/story integration

**Threads Chat Bubbles**
- 18px border radius on bubbles
- Single-column conversation view
- Text-forward approach

### Beyond iMessage: Patterns Worth Considering for Belong

**1. Cultural Reactions**
Instead of standard emoji reactions, consider culturally-specific reaction sets:
- Food/cuisine emoji (relevant to cultural gatherings)
- Celebration emoji (culturally diverse: confetti, fireworks, etc.)
- Custom sticker packs per cultural community

**2. Gathering-Linked Chat**
- Auto-create group chat when a gathering is formed
- Chat context shows the gathering card at the top
- "This chat is about [Gathering Name]" header
- Post-gathering: chat persists but gathering card shows past event

**3. Ice-Breaker Messaging**
Belong already has this concept (one ice-breaker message to non-mutual-follows):
- Visual differentiation for ice-breaker messages (subtle border or background tint)
- "You haven't connected yet" context banner
- Easy path from ice-breaker to follow/connect

**4. Conversation List Design**
- Avatar + name + last message preview + timestamp (standard)
- Unread count badge (numbered, not just dot)
- Gathering-linked chats show gathering icon instead of group avatar
- Online/active indicator (green dot on avatar)
- Swipe actions: Mute, Archive, Pin

**5. Message Bubble Design for Belong**
- Own messages: Terracotta tint background (#FAEDE3 or lighter)
- Other messages: White/surface (#FFFFFF) with subtle warm border
- Corner radius: 16-18px (matching BelongShadow radius pattern)
- Tail: Subtle, not aggressive (or none -- modern apps are dropping tails)
- Timestamps: Grouped by time block, not per-message
- Read receipts: Subtle check marks (warm grey, not blue)

### What to Avoid
- Exact iMessage bubble cloning (no personality)
- Blue send-button on warm terracotta app (color clash)
- Heavy chrome around message input (keep it minimal)
- Notifications that don't distinguish DM from group from gathering chat
- Chat UI that feels disconnected from the rest of the app's warm aesthetic

---

## Cross-Cutting Design Principles

### From Refactoring UI (Validated Production Wisdom)
1. **Start with too much whitespace, then reduce** -- generous spacing creates premium feel
2. **Reduce borders, use shadows and background colors instead** -- Belong's warm shadows already do this
3. **Grey can have warm undertones** -- not neutral, slightly brown-tinted
4. **HSL for color control** -- easier to maintain warmth across palette variations
5. **10+ shades per color family** -- for real interface needs
6. **De-emphasize strategically** -- not everything needs to be prominent
7. **Shadows convey depth** -- use Belong's warm-tinted shadow system

### From Things App (Craft-Focused Design)
- **Every animation should be purposeful** -- guide, don't distract
- **Interface should never get in the way** -- like a clean piece of paper
- **Fun and delightful** -- emotional engagement beyond pure function
- **"Real people using it for real life"** -- every pixel matters

### From Bear App (Warm Productivity)
- **Content over chrome** -- UI disappears behind what matters
- **Earth-tone theming** -- avoids clinical greys
- **Organic illustration elements** -- creates inviting, non-sterile environment
- **Customization within aesthetic guardrails** -- personalization that maintains coherence

### Belong-Specific Principles
1. **Warm Clay aesthetic** -- every element should feel grounded and organic
2. **Celebration-first** -- gatherings are celebrations, not calendar items
3. **Cultural identity visible** -- tags, interests, backgrounds surface early and often
4. **Serif + sans pairing** -- serif for personality (headings), sans for function (body)
5. **Social proof everywhere** -- faces, counts, activity indicators build community feeling
6. **Spring-based motion** -- organic, natural transitions (not linear or mechanical)
7. **Parchment, not clinical** -- warm backgrounds, warm shadows, warm borders
8. **Discovery over management** -- help people find community, not manage data

---

## Quick Reference: Key Metrics from Shipping Products

| Element | Instagram | Threads | Airbnb | Pinterest | Belong (Current) |
|---------|-----------|---------|--------|-----------|-------------------|
| Tab height | 60px | 60px | N/A | N/A | 49px |
| Card radius | 4-12px | 8px | 8-24px | N/A | 12-20px |
| Button height | 40px | N/A | N/A | N/A | 48px |
| Body font size | 14-16px | 16px | 16px | 16px | 16px |
| Heading line-height | N/A | N/A | 1.4+ | N/A | ~1.2 (system) |
| Base spacing | N/A | 12-24px | 16px | 4px | 16px (8pt grid) |
| Shadow approach | Subtle, grey | Minimal | Warm, layered | Minimal | Warm brown-tinted |
| Active accent | #0095F6 (blue) | #1877F2 (blue) | #FF385C (pink) | #774fc4 (purple) | #B5694A (terracotta) |
