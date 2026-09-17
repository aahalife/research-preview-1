import SwiftUI

/// Prepared work is inspectable, editable and durable; review never implies execution.
struct WorkflowReviewView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    let originID: UUID
    let title: String
    let detail: String
    var context: CareContext? = nil
    @State private var draft: ReviewedWorkflow? = nil
    @State private var owningScenario: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Less to arrange.\nStill your decision.").font(NudgeType.display(28))
                    Text(title).font(NudgeType.rounded(17, .semibold))
                    Text("A place to turn the concern into clear, reviewable work.")
                        .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                }.listRowBackground(Color.clear)
                if let current = draft {
                    if let basis = current.context {
                        Section("What this started from") { CareContextView(context: basis) }
                            .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
                    }
                    Section("Your next step") {
                        Label("Prepared for your review", systemImage: "doc.text")
                        Text("Check the wording, fill in what is missing, and choose the intended recipient. Nothing is sent by reviewing.")
                            .font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
                    }
                    Section("Intended recipient") {
                        TextField("Who is this intended for?", text: Binding(get: { draft?.recipient ?? "" }, set: { value in
                            if var valueDraft = draft { valueDraft.edit(detail: valueDraft.detail, recipient: value); draft = valueDraft }
                        })).accessibilityIdentifier("workflow.recipient")
                    }
                    Section("Exact draft · edit freely") {
                        TextEditor(text: Binding(get: { draft?.detail ?? "" }, set: { value in
                            if var valueDraft = draft { valueDraft.edit(detail: value, recipient: valueDraft.recipient); draft = valueDraft }
                        })).frame(minHeight: 170).accessibilityIdentifier("workflow.detail")
                    }
                    Section("Where things stand") {
                        Label(current.status.rawValue, systemImage: current.status == .ready ? "checkmark.circle" : "pencil")
                            .foregroundStyle(Theme.warm).accessibilityIdentifier("workflow.status")
                        if let date = current.reviewedAt {
                            Text("Reviewed \(date.formatted(date: .abbreviated, time: .shortened)) · edits require another review.")
                                .font(.caption).foregroundStyle(Theme.inkMuted)
                        }
                        Text("External delivery isn't connected. No provider receipt, booking or fee has been created.")
                            .font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
                        Button("Save reviewed draft") {
                            draft?.approve()
                            saveAndClose(resolve: true)
                        }.disabled(!canReview(current)).accessibilityIdentifier("workflow.review")
                        Button("Save for later") { saveAndClose(resolve: false) }.frame(minHeight: 44)
                        Button("Decline", role: .destructive) {
                            draft?.status = .declined
                            draft?.reviewedAt = nil
                            if let draft { model.saveWorkflow(draft) }
                            guard !model.storageError else { return }
                            model.companion.declineRich(turnID: originID)
                            dismiss()
                        }.frame(minHeight: 44)
                    }
                    if model.storageError {
                        Section {
                            Text("This draft couldn't be saved. Keep this screen open and try again.").foregroundStyle(Theme.attention)
                            Button("Retry saving") { if let draft { model.saveWorkflow(draft) } }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden).background(Theme.base).tint(Theme.warm)
            .navigationTitle("Review the work").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { saveAndClose(resolve: false) } } }
            .onAppear {
                guard draft == nil else { return }
                owningScenario = model.pathway.rawValue
                draft = model.workflowDraft(originID: originID, title: title, detail: detail, context: context)
            }
            .task(id: draft) {
                do {
                    try await Task.sleep(for: .milliseconds(400))
                    try Task.checkCancellation()
                    flushDraft()
                } catch { }
            }
            .onChange(of: scenePhase) { _, phase in if phase != .active { flushDraft() } }
            .onDisappear { flushDraft() }
        }
    }

    private func canReview(_ current: ReviewedWorkflow) -> Bool {
        let hasContent = !current.recipient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !current.detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        guard let taskID = current.agentTaskID else { return hasContent }
        guard let task = model.agentTasks.first(where: { $0.id == taskID }) else { return false }
        return hasContent && model.agentServices.first(where: { $0.id == task.agentID })?.active == true
    }

    private func flushDraft() {
        guard owningScenario == model.pathway.rawValue, let draft else { return }
        model.saveWorkflow(draft)
    }

    private func saveAndClose(resolve: Bool) {
        guard owningScenario == model.pathway.rawValue else { dismiss(); return }
        guard let draft else { dismiss(); return }
        model.saveWorkflow(draft)
        guard !model.storageError else { return }
        if resolve && draft.status == .ready { model.companion.resolveRich(turnID: originID) }
        dismiss()
    }
}
