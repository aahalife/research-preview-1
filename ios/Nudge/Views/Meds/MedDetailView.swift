import SwiftUI

/// Full med depth: dose history, watchlist tuned to conditions, guidance,
/// refill intelligence with barrier-first fixes.
struct MedDetailView: View {
    @Environment(AppModel.self) private var model
    let medication: Medication

    @State private var showPDC: Bool = false
    @State private var showRefillDraft: Bool = false
    @State private var refillOrigin: UUID = UUID()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name)
                        .font(NudgeType.serif(28))
                        .foregroundStyle(Theme.ink)
                    Text("\(medication.dose) · \(medication.purposeLine)")
                        .font(NudgeType.rounded(13.5))
                        .foregroundStyle(Theme.inkMuted)
                }
                .padding(.top, 8)

                // Refill intelligence — barrier-first, never a guilt trip.
                if medication.supplyDaysRemaining <= 7 && model.pathway == .metabolic {
                    OrganicSurface(radius: 30) {
                        VStack(alignment: .leading, spacing: 9) {
                            Kicker(text: "Heads-up", color: Theme.attention)
                            Text("Make room for a refill question")
                                .font(NudgeType.serif(18))
                                .foregroundStyle(Theme.ink)
                            Text("The sample list shows \(medication.supplyDaysRemaining) days of supply. Confirm what you have before planning a refill; pharmacy availability isn't connected.")
                                .font(NudgeType.rounded(13.5))
                                .foregroundStyle(Theme.inkMuted)
                                .fixedSize(horizontal: false, vertical: true)
                            Button {
                                model.openConversation(context: model.context(for: medication))
                            } label: {
                                Text("Help me frame the question")
                                    .font(NudgeType.rounded(13.5, .semibold))
                                    .foregroundStyle(Theme.base)
                                    .padding(.horizontal, 17)
                                    .padding(.vertical, 9)
                                    .background(Theme.ink, in: .capsule)
                            }
                            .buttonStyle(NudgeButtonStyle())
                            Button("Draft a request myself") { showRefillDraft = true }
                                .font(NudgeType.rounded(13)).frame(minHeight: 44)
                                .accessibilityIdentifier("medication.refillDraft")
                        }
                        .padding(17)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    TideView(level: medication.tideLevel, height: 90)
                    HStack {
                        Text("Your tide, last 30 days")
                            .font(NudgeType.rounded(12))
                            .foregroundStyle(Theme.inkMuted)
                        Spacer()
                        Button {
                            withAnimation(NudgeSpring.ui) { showPDC.toggle() }
                        } label: {
                            Text(showPDC ? pdcLine : "For the data-curious")
                                .font(NudgeType.rounded(11.5, .medium))
                                .foregroundStyle(Theme.inkMuted)
                                .underline(!showPDC)
                        }
                        .buttonStyle(NudgeButtonStyle())
                    }
                }

                detailSection(kicker: "Good to know", color: Theme.sky, items: medication.guidance)
                detailSection(kicker: "Concerns to discuss", color: Theme.warm, items: medication.watchlist)
                detailSection(kicker: "Dose history", color: Theme.life, items: medication.history)

                logSection
                NavigationLink(value: CareDestination.savings(medication.id)) {
                    Label("Explore cost-support examples", systemImage: "tag")
                        .font(NudgeType.rounded(14)).frame(minHeight: 44)
                }.accessibilityIdentifier("medication.savings")

                ProvenanceChip(text: "Sample medication history · not a live pharmacy record or interaction check")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showRefillDraft) {
            WorkflowReviewView(originID: refillOrigin, title: "Refill question · \(medication.name)",
                               detail: "I'd like to discuss a refill for \(medication.name), listed as \(medication.dose). I still need to confirm my remaining supply and the next step with my care team.",
                               context: model.context(for: medication))
        }
    }

    private var pdcLine: String {
        let pdc = Int((medication.tideLevel * 100).rounded())
        return "Sample coverage \(pdc)% · not confirmed doses"
    }

    /// Symptoms logged in this med's orbit — and the door to add one.
    private var logSection: some View {
        OrganicSurface(radius: 28) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Kicker(text: "How it's been feeling", color: Theme.rose)
                    Spacer()
                    Button {
                        Haptics.tick()
                        model.quickLogMedID = medication.id
                        model.showQuickLog = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .medium))
                            Text("Log near this med")
                                .font(NudgeType.rounded(11.5, .medium))
                        }
                        .foregroundStyle(Theme.warm)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.warm.opacity(0.11), in: .capsule)
                    }
                    .buttonStyle(NudgeButtonStyle())
                }

                let related = model.logs(near: medication.id)
                if related.isEmpty {
                    Text("Nothing logged here yet. Anything you notice around doses — cramps, dizziness, anything — lands here and sharpens the pattern.")
                        .font(NudgeType.rounded(13))
                        .foregroundStyle(Theme.inkMuted)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(related) { log in
                        HStack(spacing: 9) {
                            Circle()
                                .fill(Theme.rose.opacity(0.6))
                                .frame(width: 5, height: 5)
                            Text(log.kind)
                                .font(NudgeType.rounded(13.5, .medium))
                                .foregroundStyle(Theme.ink)
                            if let region = log.bodyRegion {
                                Text(region.lowercased())
                                    .font(NudgeType.rounded(11.5))
                                    .foregroundStyle(Theme.inkMuted)
                            }
                            Spacer()
                            Text(log.at.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                                .font(NudgeType.rounded(11))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .padding(17)
        }
    }

    private func detailSection(kicker: String, color: Color, items: [String]) -> some View {
        OrganicSurface(radius: 28) {
            VStack(alignment: .leading, spacing: 10) {
                Kicker(text: kicker, color: color)
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 9) {
                        Circle()
                            .fill(color.opacity(0.55))
                            .frame(width: 5, height: 5)
                            .padding(.top, 7)
                        Text(item)
                            .font(NudgeType.rounded(14))
                            .foregroundStyle(Theme.ink.opacity(0.88))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(17)
        }
    }
}
