import Foundation

/// Review-only external proposals. No client-side approval is represented as delivery.
nonisolated struct ReviewedWorkflow: Codable, Equatable, Identifiable {
    enum Status: String, Codable {
        case draft = "Draft"
        case ready = "Reviewed · not sent"
        case declined = "Declined"
    }
    var id: UUID = UUID()
    var originID: UUID
    var title: String
    var detail: String
    var recipient: String = ""
    var status: Status = .draft
    var updatedAt: Date = .now
    var reviewedAt: Date? = nil

    mutating func edit(detail: String, recipient: String) {
        self.detail = detail
        self.recipient = recipient
        status = .draft
        reviewedAt = nil
        updatedAt = .now
    }
    mutating func approve() {
        guard !detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !recipient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        status = .ready
        reviewedAt = .now
    }
}
