import Foundation

nonisolated struct DemoRecordImport: Codable, Equatable {
    struct Item: Codable, Equatable, Identifiable {
        var id: String
        var category: String
        var title: String
        var detail: String
    }
    var profile: RecordConnectionProfile
    var scopes: [String]
    var items: [Item]
    var importedAt: Date
    var isPartial: Bool
    var isRevoked: Bool = false
    let provenance: String = "Local demonstration · not received from Fasten"
}
