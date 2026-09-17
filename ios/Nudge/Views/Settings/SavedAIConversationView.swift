import SwiftUI

/// Read-only archive; changing backend credentials never replays an earlier account's history.
struct SavedAIConversationView: View {
    let workspace: RumiChatWorkspace
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Saved backend conversation").font(NudgeType.display(28))
                Text("Read-only, on this device. These words will not be sent through your current connection.")
                    .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                ForEach(workspace.turns) { turn in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(turn.role == .user ? "You" : "Rumi backend").font(NudgeType.rounded(12, .semibold))
                        Text(turn.text).font(NudgeType.rounded(16)).textSelection(.enabled)
                        if turn.delivery != .complete && turn.role == .companion {
                            Text("Incomplete reply").font(.caption).foregroundStyle(Theme.attention)
                        }
                        if let context = turn.context { CareContextView(context: context) }
                    }.padding(16).frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.surface, in: .rect(cornerRadius: 18))
                }
                if !workspace.draft.isEmpty {
                    Text("Unsent question").font(NudgeType.serif(22))
                    Text(workspace.draft).font(NudgeType.rounded(16)).textSelection(.enabled)
                    if let context = workspace.context { CareContextView(context: context) }
                }
            }.padding(.horizontal, 20).padding(.vertical, 16)
        }.background(Theme.base).foregroundStyle(Theme.ink).navigationTitle("Saved conversation").navigationBarTitleDisplayMode(.inline)
    }
}
