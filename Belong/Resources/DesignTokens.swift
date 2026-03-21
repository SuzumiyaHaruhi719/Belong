import SwiftUI

// MARK: - Design Tokens
// Single source of truth for all visual constants.
// Derived from docs/03-ui-specification.md + docs/01-app-specification.md.

// MARK: Colors

enum BelongColor {
    // Primary brand
    static let primary = Color(hex: "C47B5A")          // Terracotta
    static let primaryDark = Color(hex: "A8623F")       // Pressed state
    static let primaryLight = Color(hex: "D4956F")      // Lighter variant

    // Backgrounds
    static let background = Color(hex: "FAF3EB")        // Warm Cream
    static let surface = Color.white                     // Cards, inputs
    static let surfaceAlt = Color(hex: "FEFCF9")        // Slightly warm white
    static let surfaceSecondary = Color(hex: "FFF5EE")   // Soft Peach — selected chips

    // Text
    static let textPrimary = Color(hex: "2C2825")       // Dark Brown
    static let textSecondary = Color(hex: "6B6462")      // Warm Gray
    static let textTertiary = Color(hex: "9C9694")       // Lighter gray
    static let textOnPrimary = Color.white

    // Accents
    static let accent = Color(hex: "FFF5EE")            // Soft Peach
    static let sage = Color(hex: "A8B5A0")              // Muted Sage
    static let sageDark = Color(hex: "8A9E80")
    static let gold = Color(hex: "D4A03C")              // Accent gold
    static let purple = Color(hex: "7B5FA0")            // System indicator
    static let info = Color(hex: "5B8FB9")              // Info blue, @mentions, links

    // Tags
    static let tagChipBackground = Color(hex: "F2D9CF") // Blush pink
    static let tagChipText = Color(hex: "8B5E3C")       // Deep terracotta

    // Semantic
    static let success = Color(hex: "4CAF50")
    static let successLight = Color(hex: "E8F5E9")
    static let error = Color(hex: "D32F2F")
    static let errorLight = Color(hex: "FFEBEE")
    static let warning = Color(hex: "FF9800")
    static let warningLight = Color(hex: "FFF3E0")

    // System
    static let border = Color(hex: "E8E0D8")
    static let borderFocused = Color(hex: "C47B5A")
    static let divider = Color(hex: "F0E8E0")
    static let overlay = Color(hex: "2C2825").opacity(0.5)
    static let disabled = Color(hex: "D5CFC9")
    static let disabledText = Color(hex: "A8A29E")

    // Skeleton / Loading
    static let skeleton = Color(hex: "EDE5DC")
    static let skeletonHighlight = Color(hex: "F5EDE4")
}

// MARK: - Typography
// Fraunces for display/headings (serif fallback), system for body.

enum BelongFont {
    static func display(_ size: CGFloat = 32) -> Font { .system(size: size, weight: .bold, design: .serif) }
    static func h1(_ size: CGFloat = 26) -> Font { .system(size: size, weight: .semibold, design: .serif) }
    static func h2(_ size: CGFloat = 20) -> Font { .system(size: size, weight: .medium, design: .serif) }
    static func h3(_ size: CGFloat = 18) -> Font { .system(size: size, weight: .medium, design: .serif) }

    static func body(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .regular) }
    static func bodyMedium(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .medium) }
    static func bodySemiBold(_ size: CGFloat = 16) -> Font { .system(size: size, weight: .semibold) }
    static func secondary(_ size: CGFloat = 14) -> Font { .system(size: size, weight: .regular) }
    static func secondaryMedium(_ size: CGFloat = 14) -> Font { .system(size: size, weight: .medium) }
    static func caption(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .regular) }
    static func captionMedium(_ size: CGFloat = 12) -> Font { .system(size: size, weight: .medium) }
    static func button() -> Font { .system(size: 16, weight: .semibold) }
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
    static let level1 = (color: Color.black.opacity(0.06), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
    static let level2 = (color: Color.black.opacity(0.10), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(4))
    static let level3 = (color: Color.black.opacity(0.12), radius: CGFloat(24), x: CGFloat(0), y: CGFloat(-4))
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
