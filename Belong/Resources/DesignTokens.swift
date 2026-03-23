import SwiftUI

// MARK: - Design Tokens
// Single source of truth for all visual constants.
// Design direction: "Warm Clay" — organic, grounded, culturally rich.
// Inspired by Partiful's playfulness + Luma's polish + earthy warmth.
// Key differentiator: serif headings + warm clay palette + generous white space.

// MARK: Colors

enum BelongColor {
    // Primary brand — deeper, richer terracotta
    static let primary = Color(hex: "B5694A")          // Clay Terracotta (slightly deeper)
    static let primaryDark = Color(hex: "964E33")       // Pressed state
    static let primaryLight = Color(hex: "D4956F")      // Lighter variant
    static let primaryMuted = Color(hex: "E8C4B0")      // Subtle tint for backgrounds

    // Backgrounds — warmer, more distinct
    static let background = Color(hex: "F8F0E7")        // Warm Parchment (warmer than before)
    static let surface = Color(hex: "FFFFFF")            // Clean white cards
    static let surfaceAlt = Color(hex: "FDF8F3")         // Warm off-white
    static let surfaceSecondary = Color(hex: "FAEDE3")   // Peach wash — selected chips
    static let surfaceElevated = Color(hex: "FFFFFF")    // Elevated cards

    // Text — stronger contrast
    static let textPrimary = Color(hex: "1A1714")       // Near-black brown (stronger)
    static let textSecondary = Color(hex: "5C5550")      // Warm medium gray
    static let textTertiary = Color(hex: "9A938D")       // Lighter warm gray
    static let textOnPrimary = Color(hex: "FFFAF6")      // Warm white on primary

    // Accents — richer palette
    static let accent = Color(hex: "FAEDE3")            // Soft Peach
    static let sage = Color(hex: "7FA07A")              // Richer Sage (more saturated)
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
// Fraunces for display/headings (serif fallback), system for body.

enum BelongFont {
    // Display: Serif for warmth + character. Distinctive heading identity.
    static func display(_ size: CGFloat = 34) -> Font { .system(size: size, weight: .bold, design: .serif) }
    static func h1(_ size: CGFloat = 28) -> Font { .system(size: size, weight: .bold, design: .serif) }
    static func h2(_ size: CGFloat = 22) -> Font { .system(size: size, weight: .semibold, design: .serif) }
    static func h3(_ size: CGFloat = 18) -> Font { .system(size: size, weight: .semibold, design: .serif) }

    // Body: Clean sans-serif with slightly more weight differentiation
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
}

// MARK: - Layout constants

enum Layout {
    static let screenPadding: CGFloat = 20
    static let buttonHeight: CGFloat = 48    // Spec says 48pt for this version
    static let inputHeight: CGFloat = 48
    static let chipHeight: CGFloat = 32
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

enum BelongShadow {
    // Softer, warmer shadows — less harsh than pure black
    static let level1 = (color: Color(hex: "1A1714").opacity(0.05), radius: CGFloat(6), x: CGFloat(0), y: CGFloat(2))
    static let level2 = (color: Color(hex: "1A1714").opacity(0.08), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
    static let level3 = (color: Color(hex: "1A1714").opacity(0.12), radius: CGFloat(20), x: CGFloat(0), y: CGFloat(-3))
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
