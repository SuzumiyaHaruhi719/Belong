import SwiftUI

// MARK: - Design Tokens
// Single source of truth for all visual constants.
// Design direction: "Warm Clay" — organic, grounded, culturally rich.
// References: Partiful's celebration-first ethos + Airbnb's warm hospitality
//   + Luma's editorial polish. No generic Material/iOS defaults.
// Key differentiator: serif headings, warm clay palette, layered warm
//   shadows, intentional motion, generous white space.

// MARK: Colors

enum BelongColor {
    // Primary brand — deeper, richer terracotta
    static let primary = Color(hex: "B5694A")          // Clay Terracotta
    static let primaryDark = Color(hex: "964E33")       // Pressed / hover state
    static let primaryLight = Color(hex: "D4956F")      // Lighter variant
    static let primaryMuted = Color(hex: "E8C4B0")      // Subtle tint for backgrounds
    static let primarySubtle = Color(hex: "F5E6DC")     // Very subtle wash (hover bg)

    // Backgrounds — warmer, more distinct
    static let background = Color(hex: "F8F0E7")        // Warm Parchment
    static let surface = Color(hex: "FFFFFF")            // Clean white cards
    static let surfaceAlt = Color(hex: "FDF8F3")         // Warm off-white
    static let surfaceSecondary = Color(hex: "FAEDE3")   // Peach wash — selected chips
    static let surfaceElevated = Color(hex: "FFFFFF")    // Elevated cards
    static let surfacePressed = Color(hex: "F3E8DC")     // Pressed card state

    // Text — stronger contrast
    static let textPrimary = Color(hex: "1A1714")       // Near-black brown (7.8:1 on surface)
    static let textSecondary = Color(hex: "5C5550")      // Warm medium gray (4.6:1)
    static let textTertiary = Color(hex: "9A938D")       // Lighter warm gray
    static let textOnPrimary = Color(hex: "FFFAF6")      // Warm white on primary

    // Accents — richer palette
    static let accent = Color(hex: "FAEDE3")            // Soft Peach
    static let sage = Color(hex: "7FA07A")              // Richer Sage
    static let sageDark = Color(hex: "5E8558")
    static let sageLight = Color(hex: "E8F0E6")         // Sage tint
    static let gold = Color(hex: "C4922E")              // Deeper gold
    static let goldLight = Color(hex: "FDF3E0")         // Gold tint
    static let purple = Color(hex: "6B4F8A")            // Deeper purple
    static let info = Color(hex: "4A7FA5")              // Deeper blue

    // Tags — more cohesive
    static let tagChipBackground = Color(hex: "F0D4C8") // Blush clay
    static let tagChipText = Color(hex: "7A4F30")       // Deep clay

    // Semantic — warmer tones
    static let success = Color(hex: "3D8B40")
    static let successLight = Color(hex: "E5F2E6")
    static let error = Color(hex: "C62828")
    static let errorLight = Color(hex: "FCE8E8")
    static let warning = Color(hex: "E68A00")
    static let warningLight = Color(hex: "FFF0D9")

    // System
    static let border = Color(hex: "E2D9D0")           // Warmer border
    static let borderFocused = Color(hex: "B5694A")
    static let divider = Color(hex: "EDE5DB")
    static let overlay = Color(hex: "1A1714").opacity(0.45)
    static let disabled = Color(hex: "D0C9C2")
    static let disabledText = Color(hex: "A39C96")

    // Skeleton / Loading
    static let skeleton = Color(hex: "E8DFD5")
    static let skeletonHighlight = Color(hex: "F2EBE2")
}

// MARK: - Typography
// Headings: system serif (New York on iOS — warm, editorial)
// Body: system sans (SF Pro — crisp, readable)
// The serif/sans pairing creates the distinctive "editorial warmth" identity.

enum BelongFont {
    // Display: Serif for warmth + character. Tight tracking for editorial feel.
    static func display(_ size: CGFloat = 34) -> Font { .system(size: size, weight: .bold, design: .serif) }
    static func h1(_ size: CGFloat = 28) -> Font { .system(size: size, weight: .bold, design: .serif) }
    static func h2(_ size: CGFloat = 22) -> Font { .system(size: size, weight: .semibold, design: .serif) }
    static func h3(_ size: CGFloat = 18) -> Font { .system(size: size, weight: .semibold, design: .serif) }

    // Body: Clean sans-serif
    static func body(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .regular) }
    static func bodyMedium(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .medium) }
    static func bodySemiBold(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .semibold) }
    static func secondary(_ size: CGFloat = 14) -> Font { .system(size: size, weight: .regular) }
    static func secondaryMedium(_ size: CGFloat = 14) -> Font { .system(size: size, weight: .medium) }
    static func caption(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .regular) }
    static func captionMedium(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .medium) }
    static func overline(_ size: CGFloat = 11) -> Font { .system(size: size, weight: .semibold) }
    static func button() -> Font { .system(size: 16, weight: .semibold) }
    static func buttonSmall() -> Font { .system(size: 14, weight: .semibold) }
    static func tabLabel() -> Font { .system(size: 10, weight: .medium) }

    // Mono: For stats / numbers — adds typographic texture
    static func stat(_ size: CGFloat = 22) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
}

// MARK: - Spacing (8pt grid)

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let xxxxl: CGFloat = 48
    static let section: CGFloat = 56       // Between major page sections
}

// MARK: - Layout constants

enum Layout {
    static let screenPadding: CGFloat = 20
    static let buttonHeight: CGFloat = 50    // Slightly taller for presence
    static let buttonHeightCompact: CGFloat = 40
    static let inputHeight: CGFloat = 48
    static let chipHeight: CGFloat = 34      // Slightly taller for comfort
    static let tabBarHeight: CGFloat = 49
    static let navBarHeight: CGFloat = 44

    // Corner radii
    static let radiusSm: CGFloat = 8
    static let radiusMd: CGFloat = 12
    static let radiusLg: CGFloat = 16
    static let radiusXl: CGFloat = 20
    static let radiusChip: CGFloat = 20     // Full pill
    static let radiusRound: CGFloat = 9999

    // Touch target
    static let touchTargetMin: CGFloat = 44

    // Card image
    static let cardImageHeight: CGFloat = 200
    static let heroImageHeight: CGFloat = 240
}

// MARK: - Shadows
// Layered warm shadows: tinted toward the clay palette rather than pure black.
// Two-layer approach (ambient + key) creates depth that feels physical, not flat.

enum BelongShadow {
    // Subtle rest state — cards, inputs
    static let level1 = (color: Color(hex: "B5694A").opacity(0.06), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(3))
    // Elevated — hovered cards, modals
    static let level2 = (color: Color(hex: "B5694A").opacity(0.10), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(6))
    // Floating — sheets, popovers
    static let level3 = (color: Color(hex: "1A1714").opacity(0.12), radius: CGFloat(24), x: CGFloat(0), y: CGFloat(-4))
}

// MARK: - Motion
// Intentional motion tokens. Everything 200–350ms for responsiveness.
// Spring curves for organic feel. No linear — ever.

enum BelongMotion {
    static let quick: Animation = .easeOut(duration: 0.15)
    static let standard: Animation = .easeInOut(duration: 0.25)
    static let expressive: Animation = .spring(response: 0.45, dampingFraction: 0.75)
    static let celebration: Animation = .spring(response: 0.55, dampingFraction: 0.6)
    static let staggerDelay: Double = 0.05  // Per-item offset in lists
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
