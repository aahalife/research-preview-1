import SwiftUI

/// Connection controls, separate from clinical consent and the chosen demonstration patient.
struct AIConnectionView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: RumiAIMode = .showcase
    @State private var serverURL: String = ""
    @State private var brokerURL: String = ""
    @State private var hostSession: String = ""
    @State private var allowsTesting: Bool = false
    @State private var showConfirm: Bool = false
    @State private var error: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("One Rumi. Your choice of connection.")
                        .font(NudgeType.display(30)).accessibilityIdentifier("ai.connection.title")
                    Text("Switch the AI behind conversation, contextual help and visit questions. Your current care journey stays in place.")
                        .font(NudgeType.rounded(15)).foregroundStyle(Theme.inkMuted)
                    ForEach(RumiAIMode.allCases) { mode in
                        Button { selection = mode; error = nil } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: selection == mode ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selection == mode ? Theme.warm : Theme.inkMuted)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(mode.title).font(NudgeType.serif(22))
                                    Text(mode == .showcase ? "Rork Chat & Agents · ready for the sample-care showcase. Explanations and suggestions remain yours to review." : "Your dedicated WebSocket service. Requires a deployed test server, host access and a compatible message contract.")
                                        .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                                }
                                Spacer(minLength: 0)
                            }.padding(18).frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.surface, in: .rect(cornerRadius: 22))
                                .overlay { RoundedRectangle(cornerRadius: 22).stroke(selection == mode ? Theme.warm : .clear, lineWidth: 1.5) }
                        }.buttonStyle(.plain).accessibilityIdentifier("ai.mode.\(mode.rawValue)")
                            .accessibilityAddTraits(selection == mode ? .isSelected : [])
                    }
                    if selection == .backend { backendFields }
                    VStack(alignment: .leading, spacing: 8) {
                        Label(model.aiRouter.mode.title, systemImage: "point.3.connected.trianglepath.dotted")
                            .font(NudgeType.rounded(14, .semibold)).accessibilityIdentifier("ai.connection.active")
                        Text(model.aiRouter.status).font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
                        Text("Conversations and unsent questions stay with their AI mode. Switching stops active replies; it never moves chat history or silently falls back. Saved care drafts remain local, not sent.")
                            .font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
                    }.padding(18).background(Theme.raised, in: .rect(cornerRadius: 20))
                    if let error { Text(error).font(NudgeType.rounded(14)).foregroundStyle(Theme.attention).accessibilityIdentifier("ai.connection.error") }
                    Button("Apply connection") { showConfirm = true }
                        .buttonStyle(.borderedProminent).controlSize(.large).tint(Theme.buttonFill)
                        .frame(minHeight: 44).accessibilityIdentifier("ai.connection.apply")
                    if model.aiRouter.hasHostSession {
                        Button("Disconnect host session", role: .destructive) {
                            model.companion.endSession(orb: model.orb)
                            model.aiRouter.suspend()
                            hostSession = ""
                        }.frame(minHeight: 44)
                    }
                    if !archivedKeys.isEmpty {
                        DisclosureGroup("Saved backend conversations") {
                            ForEach(archivedKeys, id: \.self) { key in
                                NavigationLink(value: key) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(model.aiWorkspaces[key]?.savedAt?.formatted(date: .abbreviated, time: .shortened) ?? "Earlier backend conversation")
                                        Text("Read-only · not shared with the current connection").font(.caption).foregroundStyle(Theme.inkMuted)
                                    }.frame(minHeight: 44)
                                }
                            }
                        }.font(NudgeType.rounded(14))
                    }
                    Text("Both choices are sample-data modes in this build. Backend selection is not patient sign-in, a medical-record connection, or permission to execute care actions.")
                        .font(NudgeType.rounded(12)).foregroundStyle(Theme.inkMuted)
                }.padding(.horizontal, 20).padding(.vertical, 16)
            }
            .background(Theme.base).foregroundStyle(Theme.ink)
            .navigationTitle("AI connection").navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { key in
                if let workspace = model.aiWorkspaces[key] { SavedAIConversationView(workspace: workspace) }
            }
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() }.accessibilityIdentifier("ai.connection.close") } }
            .onAppear {
                selection = model.aiRouter.mode
                serverURL = model.aiRouter.settings.serverURL
                brokerURL = model.aiRouter.settings.tokenBrokerURL
                allowsTesting = model.aiRouter.settings.allowsSyntheticTesting
            }
            .onDisappear { hostSession = "" }
            .onChange(of: scenePhase) { _, phase in if phase == .background { hostSession = "" } }
            .alert("Apply this AI connection?", isPresented: $showConfirm) {
                Button("Apply") { apply() }.accessibilityIdentifier("ai.connection.confirm")
                Button("Keep current", role: .cancel) { }
            } message: {
                Text("Any active reply will stop. Your current conversation is saved separately. No message is sent by switching. Changing server details or host credentials starts a new backend conversation.")
            }
        }
    }

    private var archivedKeys: [String] {
        model.aiWorkspaces.keys.filter { key in
            key.hasPrefix("backend-") && key != model.aiRouter.workspaceKey
                && (!(model.aiWorkspaces[key]?.turns.isEmpty ?? true) || !(model.aiWorkspaces[key]?.draft.isEmpty ?? true))
        }.sorted { (model.aiWorkspaces[$0]?.savedAt ?? .distantPast) > (model.aiWorkspaces[$1]?.savedAt ?? .distantPast) }
    }

    private var backendFields: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Backend setup").font(NudgeType.serif(24))
            Text("The server may need its AWS/VPC deployment and approved network access first. This switch cannot create that access.")
                .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
            field("Chat server base URL", placeholder: "https://chat.your-domain.com", text: $serverURL)
            field("Host token-broker URL", placeholder: "https://host.your-domain.com/getChatToken", text: $brokerURL)
            Text("Host session access token").font(NudgeType.rounded(14, .medium))
            SecureField("Test user session only · not the tenant API key", text: $hostSession)
                .textInputAutocapitalization(.never).autocorrectionDisabled().textContentType(nil)
                .padding(14).background(Theme.raised, in: .rect(cornerRadius: 12))
            Text("Developer setup only. The host session and short-lived chat JWT stay in memory, are never saved in transcripts, and clear when the app backgrounds or you leave backend mode. Production sign-in is still to be connected.")
                .font(NudgeType.rounded(12)).foregroundStyle(Theme.inkMuted)
            Toggle("This backend is isolated for synthetic testing, with no live clinical tools", isOn: $allowsTesting)
                .font(NudgeType.rounded(14)).tint(Theme.warm)
            Text("Text adapter awaiting deployment verification. Native WebSocket voice is not enabled; temporary voice services will not be used in this mode.")
                .font(NudgeType.rounded(12)).foregroundStyle(Theme.inkMuted)
        }.padding(18).background(Theme.surface, in: .rect(cornerRadius: 22))
    }

    private func field(_ title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title).font(NudgeType.rounded(14, .medium))
            TextField(placeholder, text: text).keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
                .font(NudgeType.rounded(14)).padding(14).background(Theme.raised, in: .rect(cornerRadius: 12))
        }
    }

    private func apply() {
        var settings = model.aiRouter.settings
        if selection == .backend {
            settings.serverURL = serverURL.trimmingCharacters(in: .whitespacesAndNewlines)
            settings.tokenBrokerURL = brokerURL.trimmingCharacters(in: .whitespacesAndNewlines)
            settings.allowsSyntheticTesting = allowsTesting
            // Empty configuration can be selected for setup, but never used for a network request.
            if !settings.serverURL.isEmpty || !settings.tokenBrokerURL.isEmpty {
                do { _ = try settings.endpoints() }
                catch { self.error = RumiConnectionError.configuration.errorDescription; return }
            }
            if settings != model.aiRouter.settings || !hostSession.isEmpty { settings.id = UUID() }
        }
        guard model.changeAIConnection(mode: selection, settings: settings, hostSession: hostSession.isEmpty ? nil : hostSession) else {
            error = "The connection wasn't changed because your current work couldn't be saved. Try again after resolving the storage issue."
            return
        }
        hostSession = ""
        error = nil
    }
}
