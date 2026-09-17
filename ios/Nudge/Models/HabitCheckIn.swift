import Foundation

nonisolated struct HabitCheckIn: Codable, Equatable, Identifiable {
    enum Outcome: String, Codable, CaseIterable {
        case kept = "Did my step"
        case fallback = "Did the smaller version"
        case blocked = "Something got in the way"
        case skipped = "Not today"
    }
    var id: UUID = UUID()
    var habitID: UUID
    var at: Date = .now
    var outcome: Outcome
    var note: String = ""
    var planAtCheckIn: HabitSupportPlan?
}
