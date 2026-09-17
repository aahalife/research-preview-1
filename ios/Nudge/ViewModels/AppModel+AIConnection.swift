import Foundation

extension AppModel {
    func captureAIWorkspace() {
        aiWorkspaces[aiRouter.workspaceKey] = .init(clientID: aiRouter.clientID, turns: companion.turns,
                                                   draft: companion.composerDraft, context: companion.pendingContext, savedAt: .now)
    }

    func restoreAIWorkspace(from saved: SanoUserData) {
        aiWorkspaces = saved.aiWorkspaces ?? [:]
        if aiWorkspaces["showcase"] == nil {
            aiWorkspaces["showcase"] = .init(turns: saved.conversation ?? [], draft: saved.composerDraft ?? "", context: saved.pendingCareContext)
        }
        aiRouter.configure(mode: saved.aiMode ?? .showcase, settings: saved.aiBackend ?? .init())
        loadSelectedAIWorkspace()
    }

    private func loadSelectedAIWorkspace() {
        let workspace = aiWorkspaces[aiRouter.workspaceKey] ?? .init()
        aiRouter.clientID = workspace.clientID
        companion.restore(turns: workspace.turns, draft: workspace.draft,
                          context: workspace.context?.scenario == pathway.rawValue ? workspace.context : nil)
    }

    /// Stop, save the outgoing workspace, switch, then commit. A failed save keeps the previous selection.
    @discardableResult
    func changeAIConnection(mode: RumiAIMode, settings: RumiBackendSettings? = nil, hostSession: String? = nil) -> Bool {
        companion.endSession(orb: orb)
        aiRouter.cancelAll()
        guard persistUserData() else { return false }
        let priorMode = aiRouter.mode
        let priorSettings = aiRouter.settings
        aiRouter.configure(mode: mode, settings: settings ?? priorSettings)
        loadSelectedAIWorkspace()
        if persistUserData() {
            if mode == .backend, let hostSession { aiRouter.setHostSession(hostSession) }
            Haptics.tick()
            return true
        }
        aiRouter.configure(mode: priorMode, settings: priorSettings)
        loadSelectedAIWorkspace()
        return false
    }
}
