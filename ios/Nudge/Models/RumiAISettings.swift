import Foundation

/// AI routing is independent of patient identity and never enables clinical integrations.
nonisolated enum RumiAIMode: String, Codable, CaseIterable, Identifiable {
    case showcase
    case backend
    var id: String { rawValue }
    var title: String { self == .showcase ? "Temporary AI" : "Rumi backend" }
}

/// Non-secret, scenario-scoped connection configuration. Credentials are never encoded here.
nonisolated struct RumiBackendSettings: Codable, Equatable {
    var id: UUID = UUID()
    var serverURL: String = ""
    var tokenBrokerURL: String = ""
    var allowsSyntheticTesting: Bool = false

    func endpoints() throws -> (server: URL, broker: URL) {
        (try Self.secureURL(serverURL), try Self.secureURL(tokenBrokerURL))
    }

    static func secureURL(_ text: String) throws -> URL {
        guard !text.isEmpty, text == text.trimmingCharacters(in: .whitespacesAndNewlines),
              let parts = URLComponents(string: text), parts.scheme == "https",
              let host = parts.host, !host.isEmpty, parts.user == nil, parts.password == nil,
              parts.query == nil, parts.fragment == nil, let url = parts.url else { throw RumiConnectionError.configuration }
        return url
    }
}

/// Each provider and backend configuration owns its own local transcript and server client identifier.
nonisolated struct RumiChatWorkspace: Codable {
    var clientID: UUID = UUID()
    var turns: [ConversationTurn] = []
    var draft: String = ""
    var context: CareContext? = nil
    var savedAt: Date? = nil
}

nonisolated enum RumiConnectionError: Error, LocalizedError {
    case configuration, testPermission, hostSignIn, token, configurationResponse, authentication
    case protocolMismatch, incomplete, timeout, disconnected, busy

    var errorDescription: String? {
        switch self {
        case .configuration: "Add the HTTPS server and token-broker addresses in AI connection settings."
        case .testPermission: "Confirm that this is an isolated test backend with no live clinical tools before sharing sample information."
        case .hostSignIn: "A host session is needed. Add a test session access token in AI connection settings; never use the tenant API key."
        case .token: "The host could not provide a usable short-lived chat token. Sign in to the host again."
        case .configurationResponse: "The server configuration did not match the supported chat contract. No care information was sent."
        case .authentication: "The Rumi server rejected chat authentication. Renew the host session and try again."
        case .protocolMismatch: "The server's message format needs an adapter update. No external action was confirmed."
        case .incomplete: "The server did not finish this reply. It may still have processed your message; retry only if you want to send it again."
        case .timeout: "The Rumi server took too long to respond. Check its deployment or private-network access. Nothing was rerouted."
        case .disconnected: "The Rumi connection closed. Your words are kept; nothing was rerouted to temporary AI."
        case .busy: "A reply is already in progress. Stop it before sending another message."
        }
    }
}
