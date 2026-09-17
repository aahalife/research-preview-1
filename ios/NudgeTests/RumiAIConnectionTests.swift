import Foundation
import Testing
@testable import Nudge

@Suite(.serialized)
@MainActor struct RumiAIConnectionTests {
    @Test func secureEndpointsPreservePrefixAndRejectCredentialURLs() throws {
        let server = try RumiBackendSettings.secureURL("https://chat.example/private/chat")
        let id = UUID()
        let socket = try RumiWireProtocol.socketURL(server: server, identifier: "tenant_1", clientID: id)
        #expect(socket.scheme == "wss")
        #expect(socket.path == "/private/chat/ws/tenant_1-\(id.uuidString.lowercased())")
        for invalid in ["http://chat.example", "https://user:password@chat.example", "https://chat.example?token=secret", "https://chat.example#fragment", ""] {
            #expect(throws: RumiConnectionError.self) { try RumiBackendSettings.secureURL(invalid) }
        }
        #expect(throws: RumiConnectionError.self) { try RumiWireProtocol.socketURL(server: server, identifier: "../another", clientID: id) }
    }

    @Test func tokenExpiryIsCheckedWithoutClaimingAuthentication() throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        func token(expires: Double) throws -> String {
            let payload = try JSONEncoder().encode(["exp": expires]).base64EncodedString()
                .replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
            return "header.\(payload).signature"
        }
        #expect(RumiTokenProvider.hasUsableExpiry(try token(expires: now.timeIntervalSince1970 + 600), now: now))
        #expect(!RumiTokenProvider.hasUsableExpiry(try token(expires: now.timeIntervalSince1970 - 1), now: now))
        #expect(!RumiTokenProvider.hasUsableExpiry(try token(expires: now.timeIntervalSince1970 + 86_400), now: now))
        #expect(!RumiTokenProvider.hasUsableExpiry("tenant-api-key", now: now))
    }

    @Test func deltasAndCompletionMustBelongToSelectedServerTurn() throws {
        var accumulator = RumiTurnAccumulator()
        #expect(try accumulator.consume(.init(type: "data", message_id: "stale", text: "wrong")) == nil)
        _ = try accumulator.consume(.init(type: "control", value: "server_processing", message_id: "current"))
        #expect(try accumulator.consume(.init(type: "data", message_id: "stale", text: "wrong")) == nil)
        #expect(try accumulator.consume(.init(type: "data", message_id: "current", text: "Right")) == "Right")
        _ = try accumulator.consume(.init(type: "control", value: "server_paused", message_id: "stale"))
        #expect(!accumulator.isComplete)
        _ = try accumulator.consume(.init(type: "control", value: "server_paused", message_id: "current"))
        #expect(accumulator.isComplete && accumulator.text == "Right")
        #expect(throws: RumiConnectionError.self) { try RumiWireProtocol.decode("not json") }
    }

    @Test func modeWorkspacesRestoreDraftsAndNeverPersistHostSecrets() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let model = AppModel(storageDirectory: directory)
        model.companion.setDraft("Temporary-only question")
        let context = CareContext(id: "a", scenario: model.pathway.rawValue, title: "A", source: "Sample", detail: "Selected A", question: "Question A")
        model.companion.prepare(context: context)
        #expect(model.changeAIConnection(mode: .backend, hostSession: "synthetic-host-session"))
        #expect(model.companion.composerDraft.isEmpty && model.companion.pendingContext == nil)
        model.companion.setDraft("Backend-only draft")
        #expect(model.persistUserData())
        let encoded = try JSONEncoder().encode(#require(PersistenceService.load(pathway: model.pathway.rawValue, directory: directory)))
        #expect(!String(decoding: encoded, as: UTF8.self).contains("synthetic-host-session"))
        let restored = AppModel(storageDirectory: directory)
        #expect(restored.aiRouter.mode == .backend && !restored.aiRouter.hasHostSession)
        #expect(restored.companion.composerDraft == "Backend-only draft")
        #expect(restored.changeAIConnection(mode: .showcase))
        #expect(restored.companion.composerDraft == "Temporary-only question" && restored.companion.pendingContext == context)
        #expect(restored.changeAIConnection(mode: .backend))
        #expect(restored.companion.composerDraft == "Backend-only draft")
    }

    @Test func missingBackendDoesNotFallBackForChatOrVisitPrep() async throws {
        let spy = RecordingAITransport()
        let router = RumiAIRouter(showcase: spy)
        _ = try await router.prepareVisit(input: "Selected sample visit")
        #expect(spy.messages.last?.last?.content.contains("Selected sample visit") == true)
        router.configure(mode: .backend, settings: .init())
        await #expect(throws: RumiConnectionError.self) { try await router.prepareVisit(input: "Private backend draft") }
        await #expect(throws: RumiConnectionError.self) {
            try await router.stream(requestID: UUID(), system: "", messages: [.init(role: "user", content: "Question")], onDelta: { _ in })
        }
        #expect(spy.messages.count == 1)
    }

    @Test func credentialCannotSurviveShowcaseOrEndpointChange() {
        let router = RumiAIRouter()
        router.setHostSession("never-install-in-showcase")
        #expect(!router.hasHostSession)
        var settings = RumiBackendSettings(serverURL: "https://a.example", tokenBrokerURL: "https://a.example/getChatToken")
        router.configure(mode: .backend, settings: settings)
        router.setHostSession("synthetic")
        #expect(router.hasHostSession)
        settings.tokenBrokerURL = "https://b.example/getChatToken"
        router.configure(mode: .backend, settings: settings)
        #expect(!router.hasHostSession)
        router.setHostSession("synthetic")
        router.configure(mode: .showcase, settings: settings)
        #expect(!router.hasHostSession)
    }

    @Test func documentedTextOrderRefreshesSameSocketWithoutReplay() async throws {
        let socket = ScriptedRumiSocket(events: [
            "{\"type\":\"auth\",\"value\":\"session_expired\"}",
            "{\"type\":\"control\",\"value\":\"server_processing\",\"message_id\":\"turn-a\"}",
            "{\"type\":\"data\",\"message_id\":\"old\",\"text\":\"Ignore\"}",
            "{\"type\":\"data\",\"message_id\":\"turn-a\",\"text\":\"Selected reply\"}",
            "{\"type\":\"control\",\"value\":\"server_paused\",\"message_id\":\"turn-a\"}"
        ])
        let tokens = TestRumiTokens()
        let settings = RumiBackendSettings(serverURL: "https://chat.example/prefix", tokenBrokerURL: "https://host.example/getChatToken", allowsSyntheticTesting: true)
        let transport = RumiWebSocketTransport(settings: settings, tokens: tokens, clientID: UUID(), makeSocket: { socket })
        let result = try await transport.stream(requestID: UUID(), system: "Must not be a made-up system frame", messages: [.init(role: "assistant", content: "Old provider history"), .init(role: "user", content: "Only selected question")], onDelta: { _ in })
        #expect(result == "Selected reply")
        let sent = try socket.sent.map(RumiWireProtocol.decode)
        #expect(sent.map(\.type) == ["auth", "flag", "control", "text", "control", "auth"])
        #expect(sent[2].value == "client_speaking" && sent[4].value == "client_paused")
        #expect(sent[3].value == "Only selected question")
        #expect(tokens.count == 2 && socket.openCount == 1 && socket.closed)
    }

    @Test func authenticationFailureAndTruncationNeverComplete() async throws {
        for events in [["{\"type\":\"auth\",\"value\":\"auth_failed\"}"], ["{\"type\":\"control\",\"value\":\"server_processing\",\"message_id\":\"a\"}", "{\"type\":\"data\",\"message_id\":\"a\",\"text\":\"Partial\"}"]] {
            let socket = ScriptedRumiSocket(events: events)
            let transport = RumiWebSocketTransport(settings: .init(serverURL: "https://chat.example", tokenBrokerURL: "https://host.example/token", allowsSyntheticTesting: true), tokens: TestRumiTokens(), clientID: UUID(), makeSocket: { socket })
            await #expect(throws: RumiConnectionError.self) {
                try await transport.stream(requestID: UUID(), system: "", messages: [.init(role: "user", content: "Sample")], onDelta: { _ in })
            }
            #expect(socket.closed)
        }
    }

    @Test func modeChangeSuppressesLateOutputFromPriorTransport() async throws {
        let held = DelayedAITransport()
        let router = RumiAIRouter(showcase: held)
        var deltas = ""
        let operation = Task { try await router.stream(requestID: UUID(), system: "", messages: [.init(role: "user", content: "Sample")]) { deltas += $0 } }
        let limit = Date.now.addingTimeInterval(2)
        while held.continuation == nil && Date.now < limit { try await Task.sleep(for: .milliseconds(10)) }
        #expect(held.continuation != nil)
        router.configure(mode: .backend, settings: .init())
        held.delta?("Late text")
        held.continuation?.resume(returning: "Late reply")
        await #expect(throws: CancellationError.self) { try await operation.value }
        #expect(deltas.isEmpty)
    }

    @Test func cancellingBetweenControlAndTextDoesNotTransmitQuestion() async throws {
        let socket = HeldSendRumiSocket()
        let transport = RumiWebSocketTransport(settings: .init(serverURL: "https://chat.example", tokenBrokerURL: "https://host.example/token", allowsSyntheticTesting: true), tokens: TestRumiTokens(), clientID: UUID(), makeSocket: { socket })
        let operation = Task { try await transport.stream(requestID: UUID(), system: "", messages: [.init(role: "user", content: "Do not transmit")], onDelta: { _ in }) }
        let limit = Date.now.addingTimeInterval(2)
        while socket.waiter == nil && Date.now < limit { try await Task.sleep(for: .milliseconds(10)) }
        #expect(socket.waiter != nil)
        operation.cancel()
        socket.waiter?.resume()
        await #expect(throws: CancellationError.self) { try await operation.value }
        #expect(!socket.sent.contains(where: { $0.contains("Do not transmit") }))
        #expect(socket.closed)
    }

    @Test func voiceCannotAdoptAnExistingTextOperation() async throws {
        let transport = DelayedAITransport()
        let engine = CompanionEngine(transport: transport)
        let orb = OrbState()
        engine.send("Original text question", orb: orb)
        let limit = Date.now.addingTimeInterval(2)
        while transport.continuation == nil && Date.now < limit { try await Task.sleep(for: .milliseconds(10)) }
        #expect(transport.continuation != nil)
        let spokenReply = await engine.voiceReply(to: "Different spoken question", orb: orb)
        #expect(spokenReply.isEmpty && engine.isThinking)
        transport.continuation?.resume(returning: "Answer to text only")
        while engine.isThinking && Date.now < limit { try await Task.sleep(for: .milliseconds(10)) }
        #expect(engine.turns.last?.text == "Answer to text only")
        #expect(engine.turns.filter { $0.role == .user }.count == 1)
    }

    @Test func failedStorageDoesNotChangeModeOrDiscardDraft() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let model = AppModel(storageDirectory: directory)
        model.companion.setDraft("Keep this")
        #expect(!model.changeAIConnection(mode: .backend))
        #expect(model.aiRouter.mode == .showcase && model.companion.composerDraft == "Keep this")
        model.companion.reset()
    }
}

@MainActor private final class RecordingAITransport: ChatTransport {
    var messages: [[AIChatMessage]] = []
    func stream(requestID: UUID, system: String, messages: [AIChatMessage], onDelta: @escaping @MainActor (String) -> Void) async throws -> String { self.messages.append(messages); return "A question to review" }
}

@MainActor private final class DelayedAITransport: ChatTransport {
    var continuation: CheckedContinuation<String, any Error>?
    var delta: (@MainActor (String) -> Void)?
    func stream(requestID: UUID, system: String, messages: [AIChatMessage], onDelta: @escaping @MainActor (String) -> Void) async throws -> String {
        delta = onDelta
        return try await withCheckedThrowingContinuation { continuation = $0 }
    }
}

@MainActor private final class TestRumiTokens: RumiTokenProviding {
    var count = 0
    func token() async throws -> String { count += 1; return "synthetic-chat-token-\(count)" }
    func configuration(token: String) async throws -> RumiWireProtocol.Configuration { .init(identifier: "test-tenant", chat_type: "TEXT") }
}

@MainActor private final class HeldSendRumiSocket: RumiSocketConnecting {
    var sent: [String] = []
    var waiter: CheckedContinuation<Void, Never>?
    var closed = false
    func open(url: URL) async throws { }
    func send(_ text: String) async throws {
        sent.append(text)
        if text.contains("client_speaking") { await withCheckedContinuation { waiter = $0 } }
    }
    func receive() async throws -> String { throw RumiConnectionError.disconnected }
    func close() { closed = true }
}

@MainActor private final class ScriptedRumiSocket: RumiSocketConnecting {
    var events: [String]
    var sent: [String] = []
    var openCount = 0
    var closed = false
    init(events: [String]) { self.events = events }
    func open(url: URL) async throws { openCount += 1 }
    func send(_ text: String) async throws { #expect(openCount == 1); sent.append(text) }
    func receive() async throws -> String { guard !events.isEmpty else { throw RumiConnectionError.disconnected }; return events.removeFirst() }
    func close() { closed = true }
}
