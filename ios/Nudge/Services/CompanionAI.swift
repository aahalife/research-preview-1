import Foundation

nonisolated struct AIChatMessage: Codable, Equatable {
    let role: String
    let content: String
}

nonisolated enum CompanionAIError: Error {
    case badResponse(Int), empty, incomplete, malformed
}

/// OpenAI-compatible SSE parser. A truncated stream never becomes a completed action proposal.
nonisolated struct ChatStreamDecoder {
    private struct Chunk: Decodable {
        struct Choice: Decodable {
            struct Delta: Decodable { var content: String? }
            var delta: Delta?
            var finish_reason: String?
        }
        var choices: [Choice]?
        var error: ErrorPayload?
        struct ErrorPayload: Decodable { var message: String? }
    }
    private var eventLines: [String] = []
    private(set) var full: String = ""
    private(set) var isComplete: Bool = false
    private var stopped: Bool = false

    mutating func consume(_ line: String) throws -> String? {
        if line.isEmpty { return try dispatch() }
        if line.hasPrefix("data:") {
            let value = line.dropFirst(5)
            eventLines.append(String(value.first == " " ? value.dropFirst() : value))
        }
        return nil
    }

    private mutating func dispatch() throws -> String? {
        guard !eventLines.isEmpty else { return nil }
        let data = eventLines.joined(separator: "\n")
        eventLines = []
        if data == "[DONE]" { isComplete = true; return nil }
        guard let bytes = data.data(using: .utf8), let chunk = try? JSONDecoder().decode(Chunk.self, from: bytes) else { throw CompanionAIError.malformed }
        if chunk.error != nil { throw CompanionAIError.badResponse(502) }
        guard let choice = chunk.choices?.first else { return nil }
        if let reason = choice.finish_reason {
            guard reason == "stop" else { throw CompanionAIError.incomplete }
            stopped = true
        }
        if let delta = choice.delta?.content, !delta.isEmpty { full += delta; return delta }
        return nil
    }

    mutating func finish() throws -> String {
        _ = try dispatch()
        guard isComplete || stopped else { throw CompanionAIError.incomplete }
        guard !full.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw CompanionAIError.empty }
        return full
    }
}

final class CompanionAI: ChatTransport {
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func stream(requestID: UUID, system: String, messages: [AIChatMessage], onDelta: @escaping @MainActor (String) -> Void) async throws -> String {
        guard let url = URL(string: "\(AppConfig.toolkitURL)/v2/vercel/v1/chat/completions"), url.scheme == "https" else { throw CompanionAIError.malformed }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(requestID.uuidString, forHTTPHeaderField: "Idempotency-Key")
        request.setValue("Bearer \(AppConfig.toolkitKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 45
        let payload: [String: Any] = [
            "model": AppConfig.chatModel,
            "messages": [["role": "system", "content": system]] + messages.map { ["role": $0.role, "content": $0.content] },
            "stream": true, "temperature": 0.55, "max_tokens": 900
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw CompanionAIError.badResponse((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        guard http.value(forHTTPHeaderField: "Content-Type")?.contains("text/event-stream") == true else { throw CompanionAIError.malformed }
        var decoder = ChatStreamDecoder()
        // Preserve blank SSE separators explicitly; AsyncLineSequence can omit empty lines.
        var lineBytes: [UInt8] = []
        for try await byte in bytes {
            try Task.checkCancellation()
            if byte == 10 {
                if lineBytes.last == 13 { lineBytes.removeLast() }
                guard let line = String(bytes: lineBytes, encoding: .utf8) else { throw CompanionAIError.malformed }
                lineBytes.removeAll(keepingCapacity: true)
                if let delta = try decoder.consume(line) { onDelta(delta) }
                if decoder.isComplete { break }
            } else {
                lineBytes.append(byte)
                guard lineBytes.count < 262_144 else { throw CompanionAIError.malformed }
            }
        }
        if !lineBytes.isEmpty {
            guard let line = String(bytes: lineBytes, encoding: .utf8) else { throw CompanionAIError.malformed }
            if let delta = try decoder.consume(line) { onDelta(delta) }
        }
        try Task.checkCancellation()
        return try decoder.finish()
    }
}
