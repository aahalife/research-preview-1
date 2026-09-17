import SwiftUI

/// Three-tier disclosure: the reading → the next step → ask. Every clinical
/// statement carries a provenance chip.
struct SeriesExplainSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let series: LabSeries

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Capsule().fill(Theme.inkMuted.opacity(0.3)).frame(width: 36, height: 4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)

                Text(series.name + ", in plain words")
                    .font(NudgeType.serif(24))
                    .foregroundStyle(Theme.ink)

                tier(kicker: "The reading", color: Theme.sky, text: series.explainReading)
                tier(kicker: "What to do next", color: Theme.life, text: series.explainNextStep)

                VStack(alignment: .leading, spacing: 10) {
                    Kicker(text: "Ask", color: Theme.warm)
                    Text(series.explainAsk)
                        .font(NudgeType.rounded(15))
                        .foregroundStyle(Theme.ink.opacity(0.85))
                        .lineSpacing(3)
                    Button {
                        dismiss()
                        model.openConversation(context: model.context(for: series))
                    } label: {
                        Text("Talk it through")
                            .font(NudgeType.rounded(14, .semibold))
                            .foregroundStyle(Theme.base)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 11)
                            .background(Theme.ink, in: .capsule)
                    }
                    .buttonStyle(NudgeButtonStyle())
                }

                ProvenanceChip(text: "Sample explanation · \(series.provenance)")
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func tier(kicker: String, color: Color, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Kicker(text: kicker, color: color)
            Text(text)
                .font(NudgeType.rounded(15))
                .foregroundStyle(Theme.ink.opacity(0.85))
                .lineSpacing(3)
        }
    }
}

/// Generic record explain sheet for non-series rows.
struct ExplainSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let item: RecordItem

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Capsule().fill(Theme.inkMuted.opacity(0.3)).frame(width: 36, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)

            Text(item.title)
                .font(NudgeType.serif(24))
                .foregroundStyle(Theme.ink)

            Text(explanation)
                .font(NudgeType.rounded(15.5))
                .foregroundStyle(Theme.ink.opacity(0.85))
                .lineSpacing(4)

            Button {
                dismiss()
                model.openConversation(context: model.context(for: item))
            } label: {
                Text("Ask Rumi about this record")
                    .font(NudgeType.rounded(14, .semibold))
                    .foregroundStyle(Theme.base)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 11)
                    .background(Theme.ink, in: .capsule)
            }
            .buttonStyle(NudgeButtonStyle())

            ProvenanceChip(text: "From \(item.source) · \(item.date.formatted(.dateTime.month(.wide).year()))")

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var explanation: String {
        switch item.category {
        case .labs:
            return "This sample entry records a lab result. Its date, units and source matter. Rumi can help you frame a question about the supplied information; this entry alone is not a diagnosis."
        case .medications:
            return "This is a sample medication entry, not confirmation of what you currently take. Check the source and any conflicting information. You can ask Rumi to help draft a question; no live interaction or pharmacy check has occurred."
        case .conditions:
            return "This sample condition belongs to the listed source and date. It is not a new diagnosis from Rumi. Ask about unfamiliar terms or information you want to clarify with your care team."
        case .immunizations:
            return "This sample entry records an immunization. It may not be a complete vaccination history. Rumi can help you prepare a question about what is recorded; your clinician should confirm what is due."
        case .procedures:
            return "A procedure entry from the sample history. Review its date and available detail; an entry title is not the full procedure report."
        case .notes:
            return "This entry points to a sample clinical note. Rumi can explain only the text supplied here, not an unseen full note. Keep the original author's words separate from an AI explanation."
        case .documents:
            return "A sample document entry. Available title and details can be discussed; no absent scan or attachment has been read by AI."
        }
    }
}
