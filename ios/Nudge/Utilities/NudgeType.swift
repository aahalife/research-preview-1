import SwiftUI
import CoreText

/// Fields Display owns headings; rounded system type owns functional copy and data.
enum NudgeType {
    /// The supplied Fields display voice, reserved
    /// for the wordmark, screen titles and chapter-scale moments only.
    static func display(_ size: CGFloat) -> Font {
        .custom("FONTSPRINGDEMO-FieldsDisplayRegular", size: size, relativeTo: .largeTitle)
    }

    /// The serif voice — warmth and gravity. Headlines, story chapters,
    /// milestone copy, the companion's emphasized lines.
    static func serif(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        let name: String
        switch weight {
        case .bold, .heavy, .black: name = "FONTSPRINGDEMO-FieldsDisplayBold"
        case .semibold: name = "FONTSPRINGDEMO-FieldsDisplaySemiBoldRegular"
        case .medium: name = "FONTSPRINGDEMO-FieldsDisplayMediumRegular"
        default: name = "FONTSPRINGDEMO-FieldsDisplayRegular"
        }
        return .custom(name, size: size, relativeTo: .title2)
    }

    /// Serif italic — for a single warm aside, never long passages.
    static func serifItalic(_ size: CGFloat) -> Font {
        .custom("Fraunces-Italic", size: size)
    }

    /// The rounded voice — UI chrome, labels, conversation body, data.
    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// Numbers are always sans with monospaced digits.
    static func number(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded).monospacedDigit()
    }

    /// Small caps-style kicker labels.
    static func kicker() -> Font {
        .system(size: 11, weight: .semibold, design: .rounded)
    }
}

/// Registers the bundled Fraunces files at launch. If registration fails the
/// system serif quietly stands in — type never blocks the app.
enum NudgeFonts {
    static func registerAll() {
        let files = [
            "Fraunces-400", "Fraunces-500", "Fraunces-600", "Fraunces-700",
            "Fraunces-400-italic", "HermioneFREE",
        ]
        for weight in ["regular", "medium", "semibold", "bold", "extrabold", "black"] {
            if let url = Bundle.main.url(forResource: "fontspring-demo-fieldsdisplay-\(weight)", withExtension: "otf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
        for file in files {
            guard let url = Bundle.main.url(forResource: file, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
