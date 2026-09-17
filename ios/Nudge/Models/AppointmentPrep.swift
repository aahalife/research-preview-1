import Foundation

/// Patient-authored preparation scoped to one persisted appointment; review is invalidated by edits.
nonisolated struct AppointmentPrep: Codable, Equatable {
    var appointmentID: UUID
    var goal: String = ""
    var changes: String = ""
    var medicationConcerns: String = ""
    var questions: String = ""
    var practicalNeeds: String = ""
    var step: Int = 0
    var updatedAt: Date = .now
    var reviewedAt: Date? = nil
    var reviewedText: String? = nil

    var hasContent: Bool {
        [goal, changes, medicationConcerns, questions, practicalNeeds].contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    func brief(visit: String) -> String {
        "Rumi · patient-prepared visit brief\n\(visit)\nDemo context · not sent to a provider\n\n" +
        [("What matters most", goal), ("What changed", changes), ("Medication questions", medicationConcerns),
         ("Questions to discuss", questions), ("Practical needs", practicalNeeds)]
            .map { "\($0.0)\n\($0.1.isEmpty ? "Not added" : $0.1)" }.joined(separator: "\n\n")
    }
    mutating func invalidateReview() { reviewedAt = nil; reviewedText = nil; updatedAt = .now }
}
