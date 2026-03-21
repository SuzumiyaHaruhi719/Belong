import SwiftUI

// MARK: - Design Tokens
// Single source of truth for all visual constants.
// Derived from docs/03-ui-specification.md.

enum BelongColor {
    // Primary brand
    static let primary = Color(hex: "C47B5A")          // Terracotta
    static let primaryDark = Color(hex: "A8623F")       // Pressed state
    static let primaryLight = Color(hex: "D4956F")      // Lighter variant

    // Backgrounds
    static let background = Color(hex: "FAF3EB")        // Warm Cream
    static let surface = Color.white                      // Cards, inputs
    static let surfaceSecondary = Color(hex: "FFF5EE")   // Soft Peach — selected chips

    // Text
    static let textPrimary = Color(hex: "2C2825")        // Dark Brown
    static let textSecondary = Color(hex: "6B6462")      // Warm Gray
    static let textTertiary = Color(hex: "9C9694")        // Captions
    static let textOnPrimary = Color.white

    // Accents
    static let accent = Color(hex: "FFF5EE")             // Soft Peach
    static let sage = Color(hex: "A8B5A0")               // Muted Sage
    static let sageDark = Color(hex: "8A9E80")

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

    // Skeleton
    static let skeleton = Color(hex: "EDE5DC")
    static let skeletonHighlight = Color(hex: "F5EDE4")
}

// MARK: - Typography
// Fraunces for display/headings, system font (San Francisco) for body.
// NOTE: To use Fraunces, add the .ttf files to the project and Info.plist.
// Until then, we use .serif design for display and .default for body,
// which gives a warm, distinguishable hierarchy with zero config.

enum BelongFont {
    // Display / headings — serif design (fallback for Fraunces)
    static func display(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .serif) }
    static func h1(_ size: CGFloat = 26) -> Font { .system(size: size, weight: .semibold, design: .serif) }
    static func h2(_ size: CGFloat = 20) -> Font { .system(size: size, weight: .medium, design: .serif) }

    // Body — system default (San Francisco)
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
    static let lg: CGFloat = 20   // Screen horizontal margin
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let xxxxl: CGFloat = 48
}

// MARK: - Layout constants

enum Layout {
    static let screenPadding: CGFloat = 20
    static let buttonHeight: CGFloat = 56
    static let inputHeight: CGFloat = 56
    static let chipHeight: CGFloat = 36
    static let tabBarHeight: CGFloat = 49
    static let navBarHeight: CGFloat = 44

    // Corner radii
    static let radiusSm: CGFloat = 8
    static let radiusMd: CGFloat = 12
    static let radiusLg: CGFloat = 16
    static let radiusXl: CGFloat = 20
    static let radiusRound: CGFloat = 9999

    // Touch target
    static let touchTargetMin: CGFloat = 44
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
