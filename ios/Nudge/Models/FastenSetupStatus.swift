import Foundation

/// Server configuration evidence only; never represents a patient's connection or import.
nonisolated struct FastenSetupStatus: Decodable, Equatable {
    let mode: String
    let credentialsConfigured: Bool
    let organization: String
    let privateKeyVerified: Bool
    let webhookSecretConfigured: Bool
    let redirectConfigured: Bool
    let returnURL: URL
    let webhookURL: URL
    let authorizationEnabled: Bool
    let importEnabled: Bool

    var organizationSummary: String {
        switch organization {
        case "active": "Fasten recognized the public test credential."
        case "inactive": "Fasten reports this test organization is inactive."
        case "rejected": "Fasten did not accept the public test credential."
        case "unavailable": "Fasten could not be checked just now. Try again."
        default: "Add test credentials to check the Fasten organization."
        }
    }

    func hasValidEndpoints(for baseURL: URL) -> Bool {
        guard mode == "test", baseURL.scheme == "https", !authorizationEnabled, !importEnabled else { return false }
        for url in [returnURL, webhookURL] {
            guard url.scheme == "https", url.host == baseURL.host, url.port == baseURL.port else { return false }
            guard url.user == nil, url.password == nil, url.query == nil, url.fragment == nil else { return false }
        }
        guard returnURL.path == "/integrations/fasten/test/return" else { return false }
        return webhookURL.path == "/integrations/fasten/test/webhook"
    }
}
