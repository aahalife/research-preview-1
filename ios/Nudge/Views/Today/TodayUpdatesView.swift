import SwiftUI

/// One attention area; secondary updates stay accessible without repeating them across hubs.
struct TodayUpdatesView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let items = model.needsYou
        OrganicSurface(radius: 26) {
            VStack(alignment: .leading, spacing: 8) {
                if let first = items.first { updateRow(first) }
                if items.count > 1 {
                    DisclosureGroup("\(items.count - 1) more updates") {
                        ForEach(Array(items.dropFirst())) { item in updateRow(item) }
                    }
                    .font(NudgeType.rounded(12.5, .medium))
                    .foregroundStyle(Theme.inkMuted)
                    .padding(.top, 4)
                }
            }
            .padding(16)
        }
    }

    private func updateRow(_ item: NeedsYouItem) -> some View {
        Button { model.openCare(item.destination) } label: {
            HStack(spacing: 12) {
                Image(systemName: item.kind.glyph)
                    .foregroundStyle(Theme.sky)
                    .frame(width: 28)
                Text(item.title)
                    .font(NudgeType.rounded(14, .medium))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.inkMuted)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(NudgeButtonStyle())
    }
}
