import Foundation

@MainActor protocol RumiTokenProviding {
    func token() async throws -> String
    func configuration(token: String) async throws -> RumiWireProtocol.Configuration
}

/// Native equivalent of the iframe's give-token/set-token exchange. The host alone mints JWTs.
/// Broker profile: authenticated GET returning {"token":"<short-lived JWT>"}; verify against deployment.
final class RumiTokenProvider: RumiTokenProviding {
    private let settings: RumiBackendSettings
    private let hostSession: String
    init(settings: RumiBackendSettings, hostSession: String) {
        self.settings = settings
        self.hostSession = hostSession
    }

    func token() async throws -> String {
        guard !hostSession.isEmpty, !hostSession.contains(where: { $0.isWhitespace }), hostSession.utf8.count <= 16_384 else { throw RumiConnectionError.hostSignIn }
        let endpoint = try settings.endpoints().broker
        let data = try await get(endpoint, bearer: hostSession)
        guard let token = try? JSONDecoder().decode(TokenResponse.self, from: data).token,
              Self.hasUsableExpiry(token) else { throw RumiConnectionError.token }
        return token
    }

    func configuration(token: String) async throws -> RumiWireProtocol.Configuration {
        let endpoint = try settings.endpoints().server.appendingPathComponent("getConfig")
        let data = try await get(endpoint, bearer: token)
        guard let value = try? JSONDecoder().decode(RumiWireProtocol.Configuration.self, from: data), value.isValid else { throw RumiConnectionError.configurationResponse }
        return value
    }

    /// Expiry checking is a usability guard, NOT signature verification or patient authorization.
    nonisolated static func hasUsableExpiry(_ token: String, now: Date = .now) -> Bool {
        let parts = token.split(separator: ".", omittingEmptySubsequences: false)
        guard token.utf8.count <= 16_384, parts.count == 3, parts.allSatisfy({ !$0.isEmpty }),
              token.unicodeScalars.allSatisfy({ CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-.").contains($0) }) else { return false }
        var payload = String(parts[1]).replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        payload += String(repeating: "=", count: (4 - payload.count % 4) % 4)
        guard let data = Data(base64Encoded: payload), let claims = try? JSONDecoder().decode(Expiry.self, from: data) else { return false }
        let remaining = claims.exp - now.timeIntervalSince1970
        return remaining > 15 && remaining <= 660
    }

    private func get(_ url: URL, bearer: String) async throws -> Data {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        configuration.urlCredentialStorage = nil
        configuration.urlCache = nil
        let session = URLSession(configuration: configuration, delegate: RumiSessionDelegate(), delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse else { throw RumiConnectionError.configurationResponse }
        guard http.statusCode != 401 && http.statusCode != 403 else { throw RumiConnectionError.authentication }
        guard http.statusCode == 200, http.url == url,
              http.value(forHTTPHeaderField: "Content-Type")?.lowercased().contains("application/json") == true else { throw RumiConnectionError.configurationResponse }
        var result = Data()
        for try await byte in bytes {
            try Task.checkCancellation()
            guard result.count < 65_536 else { throw RumiConnectionError.configurationResponse }
            result.append(byte)
        }
        return result
    }
}

nonisolated private struct TokenResponse: Decodable { let token: String }
nonisolated private struct Expiry: Decodable { let exp: Double }
