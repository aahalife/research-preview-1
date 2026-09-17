import SwiftUI

extension Color {
    /// Creates a color from a 0xRRGGBB hex value.
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }

    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { trait in
            UIColor(Color(hex: trait.userInterfaceStyle == .dark ? dark : light))
        })
    }
}

/// Brand swatches sampled from the supplied delivery; semantic text variants preserve contrast.
enum Theme {
    static let mint = Color(hex: 0x4CC9AB)
    static let blush = Color(hex: 0xF5BCB5)
    static let butter = Color(hex: 0xFFE27C)
    static let forest = Color(hex: 0x00211A)
    static let base = Color(light: 0xF8F8F5, dark: 0x0B211C)
    static let surface = Color(light: 0xFFFFFD, dark: 0x16332B)
    static let raised = Color(light: 0xE9F2EB, dark: 0x214438)
    static let ink = Color(light: 0x00211A, dark: 0xF4F6EF)
    static let inkMuted = Color(light: 0x52655D, dark: 0xB7CCC1)
    static let edge = Color(light: 0xDCE6DE, dark: 0x3C5B4E)
    static let shadow = Color(light: 0x6A9682, dark: 0x000000)
    static let dockTint = Color(light: 0xEBF9F1, dark: 0x345F50).opacity(0.25)
    static let warm = Color(light: 0x176650, dark: 0x70D9BA)
    static let life = Color(light: 0x26664D, dark: 0x92D4AE)
    static let sky = Color(light: 0x346C67, dark: 0xA3DAD2)
    static let gold = Color(light: 0x876516, dark: 0xFFE27C)
    static let rose = Color(light: 0x9B544D, dark: 0xF5BCB5)
    static let attention = Color(light: 0x994B2C, dark: 0xF2B18D)
    static let accentSoft = Color(light: 0xD9F1E7, dark: 0x224E3F)
    static let buttonFill = Color(light: 0x00211A, dark: 0x4CC9AB)
    static let onAccent = Color(light: 0xFFFFFF, dark: 0x00211A)

    static func companion(_ scheme: ColorScheme) -> [Color] { [mint, butter, blush] }
    static func orbHalo(_ scheme: ColorScheme) -> [Color] { [mint.opacity(0.22), blush.opacity(0.08), .clear] }
    static func gradientPalette(scheme: ColorScheme, hour: Int) -> (Color, Color, Color) {
        scheme == .dark
            ? (Color(hex: 0x194737), Color(hex: 0x172E27), Color(hex: 0x0B211C))
            : (Color(hex: 0xE1F4EC), Color(hex: 0xFBF4E4), Color(hex: 0xF8F8F5))
    }
    static func conversationPalette(_ scheme: ColorScheme) -> (Color, Color, Color) {
        scheme == .dark
            ? (Color(hex: 0x27654F), Color(hex: 0x443C2A), Color(hex: 0x0B211C))
            : (Color(hex: 0xC7EEE0), Color(hex: 0xF8DAD0), Color(hex: 0xFFF0B8))
    }
}
