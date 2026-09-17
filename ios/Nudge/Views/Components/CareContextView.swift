import SwiftUI

/// Context stays secondary to the task; the patient can inspect the actual snapshot.
struct CareContextView: View {
    let context: CareContext
    var remove: (() -> Void)? = nil
    @State private var expanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "doc.text").foregroundStyle(Theme.warm).padding(.top, 4)
                VStack(alignment: .leading, spacing: 3) {
                    Text(remove == nil ? "Context for this step" : "With your question")
                        .font(NudgeType.rounded(11)).foregroundStyle(Theme.inkMuted)
                    Text(context.title).font(NudgeType.rounded(14, .semibold))
                        .accessibilityIdentifier("chat.context.title")
                }
                Spacer(minLength: 0)
                if let remove {
                    Button(action: remove) { Image(systemName: "xmark").frame(width: 44, height: 44) }
                        .accessibilityLabel("Remove attached context").accessibilityIdentifier("chat.context.remove")
                }
            }
            Button { expanded = true } label: {
                HStack { Text("View source and details"); Spacer(); Image(systemName: "chevron.right") }.frame(minHeight: 44)
            }.font(NudgeType.rounded(12)).accessibilityIdentifier("chat.context.details")
        }
        .padding(14).foregroundStyle(Theme.ink)
        .background(Theme.accentSoft, in: .rect(cornerRadius: 18))
        .sheet(isPresented: $expanded) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(context.title).font(NudgeType.display(28))
                        Text(context.source).font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                        Text(context.detail).font(NudgeType.rounded(16)).textSelection(.enabled)
                    }.frame(maxWidth: .infinity, alignment: .leading).padding(20)
                }
                .navigationTitle("Selected context").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { expanded = false } } }
            }.presentationDetents([.large])
        }
    }
}
