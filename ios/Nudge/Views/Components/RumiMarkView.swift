import SwiftUI

/// The quiet concentric companion mark from the platform-flow reference.
struct RumiMarkView: View {
    var size: CGFloat = 64
    var animated: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: !animated || reduceMotion || scenePhase != .active)) { timeline in
            let breath = animated && !reduceMotion ? sin(timeline.date.timeIntervalSinceReferenceDate * 1.2) * 0.025 : 0
            ZStack {
                Circle().fill(Theme.gold.opacity(0.07))
                Circle().fill(Theme.gold.opacity(0.12)).padding(size * 0.10)
                Circle().fill(Theme.gold.opacity(0.20)).padding(size * 0.20)
                Circle().fill(Theme.gold.opacity(0.32)).padding(size * 0.29)
                Circle().fill(Theme.gold).padding(size * 0.37)
            }
            .scaleEffect(1 + breath)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
