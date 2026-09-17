import Foundation

/// Compatibility profile derived from chat-portal-internals.pdf, not a verified deployment schema.
/// Keep envelope assumptions here so a current server trace can update them without touching UI.
nonisolated enum RumiWireProtocol {
    struct Configuration: Decodable, Equatable {
        let identifier: String
        let chat_type: String
        var isValid: Bool {
            !identifier.isEmpty && identifier.count <= 128 && identifier.unicodeScalars.allSatisfy {
                CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-").contains($0)
            } && ["TEXT", "VOICE"].contains(chat_type)
        }
    }

    struct Event: Decodable {
        let type: String
        var value: String?
        var message_id: String?
        var text: String?
    }

    static func frame(type: String, value: String) throws -> String {
        try encode(["type": type, "value": value])
    }

    static func textFlag(_ enabled: Bool) throws -> String {
        try encode(["type": "flag", "text": enabled ? "1" : "0"])
    }

    private static func encode(_ value: [String: String]) throws -> String {
        let data = try JSONEncoder().encode(value)
        guard let text = String(data: data, encoding: .utf8) else { throw RumiConnectionError.protocolMismatch }
        return text
    }

    static func socketURL(server: URL, identifier: String, clientID: UUID) throws -> URL {
        guard Configuration(identifier: identifier, chat_type: "TEXT").isValid,
              var parts = URLComponents(url: server.appendingPathComponent("ws").appendingPathComponent("\(identifier)-\(clientID.uuidString.lowercased())"), resolvingAgainstBaseURL: false) else { throw RumiConnectionError.configurationResponse }
        parts.scheme = "wss"
        guard let result = parts.url else { throw RumiConnectionError.configurationResponse }
        return result
    }

    static func decode(_ text: String) throws -> Event {
        guard text.utf8.count <= 262_144, let data = text.data(using: .utf8),
              let event = try? JSONDecoder().decode(Event.self, from: data) else { throw RumiConnectionError.protocolMismatch }
        return event
    }
}

/// Accepts deltas only for the server-selected turn and requires its terminal control frame.
nonisolated struct RumiTurnAccumulator {
    private(set) var messageID: String? = nil
    private(set) var text: String = ""
    private(set) var isComplete: Bool = false

    mutating func consume(_ event: RumiWireProtocol.Event) throws -> String? {
        guard !isComplete else { return nil }
        if event.type == "control", event.value == "server_processing" {
            guard messageID == nil, let id = event.message_id, !id.isEmpty, id.count <= 256 else { return nil }
            messageID = id
        } else if event.type == "data" {
            guard let id = messageID, event.message_id == id, let delta = event.text else { return nil }
            guard text.utf8.count + delta.utf8.count <= 262_144 else { throw RumiConnectionError.protocolMismatch }
            text += delta
            return delta
        } else if event.type == "control", event.value == "server_paused" {
            guard let id = messageID, event.message_id == id else { return nil }
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw RumiConnectionError.incomplete }
            isComplete = true
        } else if event.type == "error" { throw RumiConnectionError.protocolMismatch }
        return nil
    }
}
