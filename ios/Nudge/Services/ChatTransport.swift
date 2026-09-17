import Foundation

/// UI-independent transport seam. A future WebSocket adapter must implement the agreed server contract here.
@MainActor protocol ChatTransport {
    func stream(requestID: UUID, system: String, messages: [AIChatMessage], onDelta: @escaping @MainActor (String) -> Void) async throws -> String
}

extension ChatTransport {
    func stream(system: String, messages: [AIChatMessage], onDelta: @escaping @MainActor (String) -> Void) async throws -> String {
        try await stream(requestID: UUID(), system: system, messages: messages, onDelta: onDelta)
    }
}
