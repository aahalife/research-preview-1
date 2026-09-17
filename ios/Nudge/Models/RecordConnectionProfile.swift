import Foundation

/// Editable identity hints, never an authorization credential or patient-match decision.
nonisolated struct RecordConnectionProfile: Codable, Equatable {
    var firstName: String = ""
    var lastName: String = ""
    var dateOfBirth: String = ""
    var email: String = ""

    var isValid: Bool {
        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        guard let date = formatter.date(from: dateOfBirth), formatter.string(from: date) == dateOfBirth else { return false }
        return date <= Date.now
    }

    /// Synthetic fixtures only; not a real identity lookup.
    static func sample(_ pathway: String) -> RecordConnectionProfile {
        switch pathway {
        case "oncology": return .init(firstName: "Elena", lastName: "Rivera", dateOfBirth: "1978-04-12", email: "elena@example.com")
        case "procedure": return .init(firstName: "Sam", lastName: "Morgan", dateOfBirth: "1967-09-18", email: "sam@example.com")
        case "cardiometabolic": return .init(firstName: "Rosa", lastName: "Martinez", dateOfBirth: "1959-02-23", email: "rosa@example.com")
        default: return .init(firstName: "Marcus", lastName: "Johnson", dateOfBirth: "1974-06-15", email: "marcus@example.com")
        }
    }

    func matchesSample(_ pathway: String) -> Bool {
        let sample = Self.sample(pathway)
        return firstName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == sample.firstName.lowercased()
            && lastName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == sample.lastName.lowercased()
            && dateOfBirth == sample.dateOfBirth
    }
}
