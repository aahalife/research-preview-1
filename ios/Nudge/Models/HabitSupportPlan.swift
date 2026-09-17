import Foundation

/// Deliberately chosen supports, not inferred personality or clinical advice.
nonisolated struct HabitSupportPlan: Codable, Equatable {
    var reason: String = ""
    var cue: String = ""
    var barrier: String = ""
    var fallback: String = ""
    var confidence: Int = 3
    var pace: String = "Small steps"
    var paused: Bool = false
    var updatedAt: Date = .now
}
