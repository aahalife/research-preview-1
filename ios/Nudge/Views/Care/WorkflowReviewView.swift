import SwiftUI

struct WorkflowReviewView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let originID: UUID
    let title: String
    let detail: String
    @State private var draft: ReviewedWorkflow? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("You have the last word.").font(NudgeType.display(28))
                    Text(title).font(NudgeType.rounded(17, .semibold))
                    Text("Review the recipient and the exact draft. This build can save it, but cannot send it or perform the action.")
                        .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                }.listRowBackground(Color.clear)
                if let current = draft {
                    Section("Recipient") {
                        TextField("Who is this intended for?", text: Binding(get: { draft?.recipient ?? "" }, set: { value in if var current = draft { current.edit(detail: current.detail, recipient: value); draft = current } }))
                            .accessibilityIdentifier("workflow.recipient")
                    }
                    Section("Exact draft · edit freely") {
                        TextEditor(text: Binding(get: { draft?.detail ?? "" }, set: { value in if var current = draft { current.edit(detail: value, recipient: current.recipient); draft = current } })).frame(minHeight: 170)
                    }
                    Section {
                        Text(current.status.rawValue).foregroundStyle(Theme.warm)
                        Text("No external action. No fees charged. No provider receipt.").font(.caption).foregroundStyle(Theme.inkMuted)
                        Button("Save reviewed draft") {
                            draft?.approve()
                            if let draft { model.saveWorkflow(draft) }
                            if !model.storageError { model.companion.resolveRich(turnID: originID); dismiss() }
                        }.disabled(current.recipient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || current.detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        Button("Save for later") { if let draft { model.saveWorkflow(draft) }; if !model.storageError { dismiss() } }
                        Button("Decline", role: .destructive) {
                            draft?.status = .declined
                            if let draft { model.saveWorkflow(draft) }
                            model.companion.declineRich(turnID: originID)
                            dismiss()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden).background(Theme.base).tint(Theme.warm)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .onAppear { draft = model.workflows.first { $0.originID == originID } ?? .init(originID: originID, title: title, detail: detail) }
        }
    }
}
