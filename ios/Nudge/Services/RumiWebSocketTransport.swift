import Foundation

/// Text-only compatibility adapter. No tenant key, gateway fallback, tool execution or automatic replay.
final class RumiWebSocketTransport: ChatTransport {
    private let settings: RumiBackendSettings
    private let tokens: any RumiTokenProviding
    private let makeSocket: @MainActor () -> any RumiSocketConnecting
    private let clientID: UUID
    private let status: @MainActor (String) -> Void

    init(settings: RumiBackendSettings, tokens: any RumiTokenProviding, clientID: UUID,
         makeSocket: @escaping @MainActor () -> any RumiSocketConnecting = { RumiSocketConnection() },
         status: @escaping @MainActor (String) -> Void = { _ in }) {
        self.settings = settings; self.tokens = tokens; self.clientID = clientID
        self.makeSocket = makeSocket; self.status = status
    }

    func stream(requestID: UUID, system: String, messages: [AIChatMessage], onDelta: @escaping @MainActor (String) -> Void) async throws -> String {
        guard settings.allowsSyntheticTesting else { throw RumiConnectionError.testPermission }
        let server = try settings.endpoints().server
        guard let input = messages.last(where: { $0.role == "user" })?.content,
              !input.isEmpty, input.utf8.count <= 65_536 else { throw RumiConnectionError.protocolMismatch }
        // The server owns system policy and conversation memory. Never replay gateway history or invent a system frame.
        status("Requesting a chat token…")
        let token = try await tokens.token()
        try Task.checkCancellation()
        let config = try await tokens.configuration(token: token)
        try Task.checkCancellation()
        guard config.isValid else { throw RumiConnectionError.configurationResponse }
        let socket = makeSocket()
        defer { socket.close() }
        return try await withTaskCancellationHandler {
            status("Opening secure WebSocket…")
            try await socket.open(url: RumiWireProtocol.socketURL(server: server, identifier: config.identifier, clientID: clientID))
            try Task.checkCancellation()
            var timedOut = false
            let deadline = Task {
                do {
                    try await Task.sleep(for: .seconds(60))
                    timedOut = true
                    socket.close()
                } catch { }
            }
            defer { deadline.cancel() }
            do {
                status("Socket open · authenticating")
                try Task.checkCancellation()
                try await socket.send(RumiWireProtocol.frame(type: "auth", value: token))
                // The PDF specifies ordered auth then modality/turn frames, but no success ACK name.
                try Task.checkCancellation()
                try await socket.send(RumiWireProtocol.textFlag(true))
                try Task.checkCancellation()
                try await socket.send(RumiWireProtocol.frame(type: "control", value: "client_speaking"))
                try Task.checkCancellation()
                try await socket.send(RumiWireProtocol.frame(type: "text", value: input))
                try Task.checkCancellation()
                try await socket.send(RumiWireProtocol.frame(type: "control", value: "client_paused"))
                status("Message transmitted · awaiting server reply")
                var accumulator = RumiTurnAccumulator()
                var refreshCount = 0
                while !accumulator.isComplete {
                    try Task.checkCancellation()
                    let event = try RumiWireProtocol.decode(await socket.receive())
                    if event.type == "auth" {
                        if event.value == "auth_failed" { throw RumiConnectionError.authentication }
                        if event.value == "session_expired" {
                            guard refreshCount == 0 else { throw RumiConnectionError.authentication }
                            refreshCount += 1
                            status("Renewing chat access…")
                            let refreshed = try await tokens.token()
                            try Task.checkCancellation()
                            let refreshedConfig = try await tokens.configuration(token: refreshed)
                            try Task.checkCancellation()
                            guard refreshedConfig.identifier == config.identifier else { throw RumiConnectionError.authentication }
                            try Task.checkCancellation()
                            try await socket.send(RumiWireProtocol.frame(type: "auth", value: refreshed))
                            // Refresh only; never resend a text turn whose outcome is unknown.
                        }
                        continue
                    }
                    if let delta = try accumulator.consume(event) {
                        status("Receiving Rumi's reply…")
                        onDelta(delta)
                    }
                }
                try Task.checkCancellation()
                status("Reply received · socket closed")
                return accumulator.text
            } catch {
                if timedOut { throw RumiConnectionError.timeout }
                if Task.isCancelled { throw CancellationError() }
                if let known = error as? RumiConnectionError { throw known }
                throw RumiConnectionError.disconnected
            }
        } onCancel: { Task { @MainActor in socket.close() } }
    }
}
