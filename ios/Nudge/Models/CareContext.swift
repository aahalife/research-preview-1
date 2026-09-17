import Foundation

/// An inspectable snapshot of the exact item the patient chose to discuss.
nonisolated struct CareContext: Codable, Equatable, Identifiable {
    let id: String
    let scenario: String
    let title: String
    let source: String
    let detail: String
    let question: String

    var promptData: String {
        "Selected item: \(title)\nSource: \(source)\nSnapshot: \(detail)"
    }
}
