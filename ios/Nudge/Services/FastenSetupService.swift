import Foundation

/// Reads non-patient setup metadata without sending the active Demo profile or any secrets.
nonisolated struct FastenSetupService: Sendable {
    let baseURL: URL

    func load() async throws -> FastenSetupStatus {
        let url = baseURL.appendingPathComponent("integrations/fasten/test/status")
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpShouldSetCookies = false
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        guard let http = response as? HTTPURLResponse, http.statusCode == 200,
              response.url?.host == baseURL.host,
              response.url?.scheme == "https",
              http.value(forHTTPHeaderField: "Content-Type")?.lowercased().contains("application/json") == true,
              data.count < 32_768 else { throw URLError(.badServerResponse) }
        let result = try JSONDecoder().decode(FastenSetupStatus.self, from: data)
        guard result.hasValidEndpoints(for: baseURL) else { throw URLError(.badServerResponse) }
        return result
    }
}
