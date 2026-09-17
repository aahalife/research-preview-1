import SwiftUI

extension Color {
    /// Creates a color from a 0xRRGGBB hex value.
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }

    /// Creates a dynamic color that resolves per appearance.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
    }
}

/// Warm paper, amber controls and earthy supporting colors in both appearances.
enum Theme {
    static let base = Color(light: 0xFAF7F1, dark: 0x1C1915)
    static let surface = Color(light: 0xFFFDFA, dark: 0x29241E)
    static let raised = Color(light: 0xF4EBDB, dark: 0x352D23)
    static let ink = Color(light: 0x30281F, dark: 0xF6EEE1)
    static let inkMuted = Color(light: 0x766958, dark: 0xC2B39E)
    static let edge = Color(light: 0xE8DFD1, dark: 0x4B4032)
    static let shadow = Color(light: 0xAA8555, dark: 0x000000)
    static let dockTint = Color(light: 0xFFFAED, dark: 0x493A26).opacity(0.25)

    static let warm = Color(light: 0x98621C, dark: 0xE2AD60)
    static let life = Color(light: 0x68734C, dark: 0xB2C28D)
    static let sky = Color(light: 0x61796F, dark: 0xACC6B8)
    static let gold = Color(light: 0xA36A1E, dark: 0xE9B76E)
    static let rose = Color(light: 0xAC6D56, dark: 0xD9A18A)
    static let attention = Color(light: 0xA35325, dark: 0xEAB17E)
    static let accentSoft = Color(light: 0xF2E1C2, dark: 0x463520)
    static let buttonFill = Color(light: 0x99611C, dark: 0xE2AD60)
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x251B10)

    static func companion(_ scheme: ColorScheme) -> [Color] {
        scheme == .dark
            ? [Color(hex: 0xE8B86B), Color(hex: 0xBC7B43), Color(hex: 0xBFC193)]
            : [Color(hex: 0xE5BA72), Color(hex: 0xC78D4D), Color(hex: 0xEBD6AF)]
    }

    static func orbHalo(_ scheme: ColorScheme) -> [Color] {
        [gold.opacity(scheme == .dark ? 0.2 : 0.14), warm.opacity(0.06), .clear]
    }

    /// Small variations in a paper-like wash, not a competing full-screen scene.
    static func gradientPalette(scheme: ColorScheme, hour: Int) -> (Color, Color, Color) {
        if scheme == .dark {
            return (Color(hex: 0x30271B), Color(hex: 0x221E18), Color(hex: 0x1C1915))
        }
        switch hour {
        case 5..<12: return (Color(hex: 0xF5E8D0), Color(hex: 0xFBF8F1), Color(hex: 0xFAF7F1))
        case 12..<17: return (Color(hex: 0xF4EAD8), Color(hex: 0xFCFAF6), Color(hex: 0xFAF7F1))
        default: return (Color(hex: 0xF0E1CA), Color(hex: 0xFBF7EF), Color(hex: 0xF7F4ED))
        }
    }

    static func conversationPalette(_ scheme: ColorScheme) -> (Color, Color, Color) {
        scheme == .dark
            ? (Color(hex: 0x392B1B), Color(hex: 0x29251C), Color(hex: 0x1C1915))
            : (Color(hex: 0xF2E2C6), Color(hex: 0xF8F0E2), Color(hex: 0xFAF7F1))
    }
}
