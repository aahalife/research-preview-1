import SwiftUI

struct WorkflowLibraryView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var selected: ReviewedWorkflow? = nil

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Pick up where you left off.").font(NudgeType.display(27))
                    Text("Questions and tasks you've prepared with Rumi. Reviewed means ready for you—not sent to anyone.")
                        .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                }.listRowBackground(Color.clear)
                if model.workflows.isEmpty {
                    ContentUnavailableView("No prepared work yet", systemImage: "doc.text", description: Text("Start from a medication, symptom, record question or conversation. Your saved drafts will stay here."))
                        .listRowBackground(Color.clear)
                }
                ForEach(model.workflows.sorted { $0.updatedAt > $1.updatedAt }) { workflow in
                    Button { selected = workflow } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(workflow.title).font(NudgeType.rounded(16, .semibold)).foregroundStyle(Theme.ink)
                            Text(workflow.status.rawValue).font(NudgeType.rounded(12)).foregroundStyle(Theme.warm)
                            if !workflow.recipient.isEmpty { Text("For \(workflow.recipient)").font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted) }
                        }.padding(.vertical, 6)
                    }.accessibilityIdentifier("workflow.saved.\(workflow.id)")
                }
            }
            .scrollContentBackground(.hidden).background(Theme.base).tint(Theme.warm)
            .navigationTitle("Prepared work").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .sheet(item: $selected) { value in
                WorkflowReviewView(originID: value.originID, title: value.title, detail: value.detail, context: value.context)
            }
        }
    }
}
