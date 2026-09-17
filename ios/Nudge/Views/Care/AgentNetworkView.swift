import SwiftUI

/// Saved reviewable work comes first; agent-domain examples are explicitly illustrative.
struct AgentNetworkView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var path: [String] = []
    @State private var reviewedWorkflow: ReviewedWorkflow? = nil

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LivingGradientView()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        intelligenceCard
                        if !model.workflows.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your saved drafts").font(NudgeType.serif(22))
                                ForEach(model.workflows) { workflow in
                                    Button { reviewedWorkflow = workflow } label: {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(workflow.title).font(NudgeType.rounded(15, .semibold))
                                            Text(workflow.status.rawValue).font(NudgeType.rounded(12)).foregroundStyle(Theme.inkMuted)
                                        }.padding(16).frame(maxWidth: .infinity, alignment: .leading).background(Theme.surface, in: .rect(cornerRadius: 18))
                                    }
                                }
                            }
                        }

                        DisclosureGroup("Explore agent examples") {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Illustrative tasks, not live monitoring. Open a proposal to inspect and edit it; no external action runs.")
                                    .font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
                                ForEach(model.pendingActions) { action in AgentActionCard(action: action) }
                                if !model.agentTasksWaiting.isEmpty { waitingSection }
                                agentsSection
                            }.padding(.top, 12)
                        }.font(NudgeType.rounded(15, .semibold))

                        ProvenanceChip(text: "Prepared here. Reviewed by you. External delivery remains unconnected.")
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 44)
                }
                .scrollIndicators(.hidden)
            }
            .navigationDestination(for: String.self) { agentID in
                ZStack { LivingGradientView(); AgentDetailView(serviceID: agentID) }
                    .toolbar(.hidden, for: .navigationBar)
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) { topBar }
        }
        .sheet(item: $reviewedWorkflow) { item in WorkflowReviewView(originID: item.originID, title: item.title, detail: item.detail) }
        .onAppear {
            if let focus = model.agentNetworkFocusID {
                path = [focus]
                model.agentNetworkFocusID = nil
            }
        }
    }

    private var topBar: some View {
        HStack {
            Text("Your Rumi network")
                .font(NudgeType.serif(19))
                .foregroundStyle(Theme.ink)
            Spacer()
            Button {
                Haptics.tick()
                dismiss()
            } label: {
                Text("Done")
                    .font(NudgeType.rounded(14, .semibold))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .capsuleGlass()
            }
            .buttonStyle(NudgeButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Theme.base.opacity(0.6))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Help that leaves you with less to do")
                .font(NudgeType.serif(28))
                .foregroundStyle(Theme.ink)
            Text("Start with a real concern. Rumi helps prepare the words and next step; you inspect the basis, make changes and decide what to keep.")
                .font(NudgeType.rounded(14))
                .foregroundStyle(Theme.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.trailing, 30)
    }

    /// The "well-oiled machine" line — what the network reads across to stay
    /// a step ahead, drawn from the actually-connected sources.
    private var intelligenceCard: some View {
        OrganicSurface(radius: 26) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 9) {
                    Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Theme.sky)
                        .frame(width: 32, height: 32)
                        .background(Theme.sky.opacity(0.14), in: .circle)
                    Text("From concern to prepared work")
                        .font(NudgeType.serif(16))
                        .foregroundStyle(Theme.ink)
                }
                Text("A medication question can become an editable draft. Visit concerns can become a reviewed brief. The useful part is the work you can return to—not another chat bubble.")
                    .font(NudgeType.rounded(13))
                    .foregroundStyle(Theme.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                FlowChips(sources: ["Selected context", "Editable draft", "Your review"])
                Text("This build prepares and saves. It does not contact your care team, book, pay or change treatment.")
                    .font(NudgeType.rounded(12)).foregroundStyle(Theme.inkMuted)
            }
            .padding(15)
        }
    }


    private var waitingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Kicker(text: "Proposals to explore", color: Theme.warm)
            ForEach(model.agentTasksWaiting) { task in
                AgentTaskCard(task: task, showAgentName: true)
            }
        }
    }

    private var agentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Kicker(text: "The family", color: Theme.sky)
            VStack(spacing: 10) {
                ForEach(model.agentServices) { service in
                    NavigationLink(value: service.id) {
                        AgentRow(service: service)
                    }
                    .buttonStyle(NudgeButtonStyle())
                }
            }
        }
    }
}

// MARK: - Agent row (network list)

struct AgentRow: View {
    @Environment(AppModel.self) private var model
    let service: AgentService

    private var accent: Color { agentAccentColor(service.accent) }
    private var active: Int { model.activeTaskCount(forAgent: service.id) }
    private var waiting: Int { model.waitingCount(forAgent: service.id) }

    var body: some View {
        OrganicSurface(radius: 24) {
            HStack(spacing: 12) {
                Image(systemName: service.glyph)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(service.active ? accent : Theme.inkMuted)
                    .frame(width: 44, height: 44)
                    .background((service.active ? accent : Theme.inkMuted).opacity(0.14), in: .circle)
                VStack(alignment: .leading, spacing: 2) {
                    Text(service.name)
                        .font(NudgeType.serif(16))
                        .foregroundStyle(Theme.ink)
                    Text(statusLine)
                        .font(NudgeType.rounded(12))
                        .foregroundStyle(waiting > 0 ? Theme.warm : Theme.inkMuted)
                        .lineLimit(1)
                }
                Spacer(minLength: 6)
                if waiting > 0 {
                    Text("\(waiting)")
                        .font(NudgeType.number(11, .semibold))
                        .foregroundStyle(Theme.base)
                        .frame(minWidth: 18)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Theme.warm, in: .capsule)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(Theme.inkMuted)
            }
            .padding(13)
        }
    }

    private var statusLine: String {
        if !service.active { return "Paused — tap to see its work" }
        if waiting > 0 { return "Demo · \(waiting) reviewable examples" }
        return "Demonstration · \(service.role)"
    }
}

// MARK: - Agent detail

/// One agent, opened up: what it's working on, what's waiting on you, and the
/// connected sources it draws from. The pause control sits here too.
struct AgentDetailView: View {
    @Environment(AppModel.self) private var model
    let serviceID: String

    private var service: AgentService? { model.agentServices.first { $0.id == serviceID } }

    var body: some View {
        ScrollView {
            if let service {
                VStack(alignment: .leading, spacing: 18) {
                    detailHeader(service)
                    let tasks = orderedTasks
                    if tasks.isEmpty {
                        emptyState
                    } else {
                        ForEach(groupedSections(tasks), id: \.0) { titleAndKind in
                            sectionView(title: titleAndKind.0, tasks: titleAndKind.1)
                        }
                    }
                    ProvenanceChip(text: "Demo pause prevents reviewing new proposals. There is no connected background service in this build.")
                        .padding(.top, 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
    }

    private func detailHeader(_ service: AgentService) -> some View {
        let accent = agentAccentColor(service.accent)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 13) {
                Image(systemName: service.glyph)
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(accent)
                    .frame(width: 58, height: 58)
                    .background(accent.opacity(0.15), in: .circle)
                VStack(alignment: .leading, spacing: 3) {
                    Text(service.name)
                        .font(NudgeType.serif(24))
                        .foregroundStyle(Theme.ink)
                    Text(service.role)
                        .font(NudgeType.rounded(13))
                        .foregroundStyle(Theme.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Button {
                model.toggleAgentService(service.id)
            } label: {
                HStack(spacing: 7) {
                    Circle()
                        .fill(service.active ? Theme.life : Theme.inkMuted.opacity(0.5))
                        .frame(width: 8, height: 8)
                    Text(service.active ? "Demo examples available" : "Demo paused")
                        .font(NudgeType.rounded(13, .semibold))
                        .foregroundStyle(service.active ? Theme.life : Theme.inkMuted)
                    Spacer()
                    Text(service.active ? "Pause" : "Resume")
                        .font(NudgeType.rounded(12.5, .semibold))
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 7)
                        .capsuleGlass()
                }
                .padding(13)
                .background(Theme.surface.opacity(0.7), in: .rect(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(NudgeButtonStyle())
        }
        .padding(.trailing, 20)
    }

    private var orderedTasks: [AgentTask] {
        model.tasks(forAgent: serviceID)
    }

    private func groupedSections(_ tasks: [AgentTask]) -> [(String, [AgentTask])] {
        var out: [(String, [AgentTask])] = []
        let waiting = tasks.filter { $0.status == .waiting }
        let working = tasks.filter { $0.status == .working }
        let scheduled = tasks.filter { $0.status == .scheduled }
        let done = tasks.filter { $0.status == .done }
        if !waiting.isEmpty { out.append(("Example proposals", waiting)) }
        if !working.isEmpty { out.append(("Illustrative work", working)) }
        if !scheduled.isEmpty { out.append(("Illustrative scheduling", scheduled)) }
        if !done.isEmpty { out.append(("Example outcomes · not receipts", done)) }
        return out
    }

    private func sectionView(title: String, tasks: [AgentTask]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Kicker(text: title, color: title.contains("ok") ? Theme.warm : Theme.sky)
            ForEach(tasks) { task in
                AgentTaskCard(task: task, showAgentName: false)
            }
        }
    }

    private var emptyState: some View {
        OrganicSurface(radius: 24) {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.seal")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(Theme.life)
                Text("All quiet here — nothing needs you.")
                    .font(NudgeType.rounded(13.5))
                    .foregroundStyle(Theme.inkMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(26)
        }
    }
}

// MARK: - Agent task card

/// A single piece of an agent's work, with its mode, the sources it reads, and —
/// when it's waiting — the one tap that lets it proceed.
struct AgentTaskCard: View {
    @Environment(AppModel.self) private var model
    let task: AgentTask
    var showAgentName: Bool
    @State private var review: ReviewedWorkflow? = nil

    private var agentName: String? {
        model.agentServices.first { $0.id == task.agentID }?.name
    }

    var body: some View {
        OrganicSurface(radius: 24) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    modeChip
                    Spacer()
                    if showAgentName, let agentName {
                        Text(agentName)
                            .font(NudgeType.rounded(11, .medium))
                            .foregroundStyle(Theme.inkMuted)
                    }
                    if task.status == .done {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.life)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(NudgeType.serif(16.5))
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(task.status == .done ? "Illustrative outcome: " + task.outcomeLine : task.detail)
                        .font(NudgeType.rounded(13))
                        .foregroundStyle(Theme.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !task.sources.isEmpty {
                    FlowSourceChips(sources: task.sources)
                }

                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 10, weight: .medium))
                    Text(task.cadence)
                        .font(NudgeType.rounded(11.5, .medium))
                }
                .foregroundStyle(Theme.inkMuted.opacity(0.85))

                if task.status == .waiting {
                    HStack(spacing: 10) {
                        Button {
                            review = model.workflowForAgentTask(task.id)
                        } label: {
                            Text("Review proposal")
                                .font(NudgeType.rounded(13.5, .semibold))
                                .foregroundStyle(Theme.base)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 9)
                                .background(Theme.ink, in: .capsule)
                        }
                        .buttonStyle(NudgeButtonStyle())
                        .disabled(model.agentServices.first(where: { $0.id == task.agentID })?.active != true)
                        Button {
                            model.declineAgentTask(task.id)
                        } label: {
                            Text("Not now")
                                .font(NudgeType.rounded(13.5, .medium))
                                .foregroundStyle(Theme.ink)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 9)
                                .background(Theme.raised.opacity(0.9), in: .capsule)
                                .overlay(Capsule().strokeBorder(Theme.edge.opacity(0.7), lineWidth: 0.8))
                        }
                        .buttonStyle(NudgeButtonStyle())
                    }
                    .padding(.top, 2)
                }
            }
            .padding(15)
        }
        .sheet(item: $review) { value in
            WorkflowReviewView(originID: value.originID, title: value.title, detail: value.detail, context: value.context)
        }
    }

    private var modeChip: some View {
        let isAuto = task.mode == .automatic
        let tint = isAuto ? Theme.sky : Theme.warm
        return HStack(spacing: 5) {
            Image(systemName: isAuto ? "sparkles" : "hand.raised")
                .font(.system(size: 9, weight: .semibold))
            Text(task.mode == .automatic ? "Demo example" : "Review-first example")
                .font(NudgeType.rounded(10.5, .semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(tint.opacity(0.13), in: .capsule)
    }
}

// MARK: - Today pulse card

/// The compact, never-overshadowing presence of the network on Today: a glance
/// at what's humming, the first thing waiting on a tap, and a door into the
/// whole family. Calm by default; capable when you look.
struct AgentPulseCard: View {
    @Environment(AppModel.self) private var model

    private var inMotion: Int { model.agentTasksInMotion.count }
    private var waiting: [AgentTask] { model.agentTasksWaiting }

    var body: some View {
        Button {
            Haptics.glass()
            SoundEngine.shared.glass()
            model.showAgentNetwork = true
        } label: {
            OrganicSurface(radius: 28) {
                VStack(alignment: .leading, spacing: 11) {
                    HStack(spacing: 9) {
                        agentDots
                        VStack(alignment: .leading, spacing: 1) {
                            Kicker(text: "Explore agent examples", color: Theme.sky)
                            Text(summaryLine)
                                .font(NudgeType.rounded(12.5))
                                .foregroundStyle(Theme.inkMuted)
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .light))
                            .foregroundStyle(Theme.inkMuted)
                    }

                    if let first = waiting.first {
                        Divider().overlay(Theme.edge)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "hand.raised")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Theme.warm)
                                Text(first.title)
                                    .font(NudgeType.serif(15.5))
                                    .foregroundStyle(Theme.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Text(first.detail)
                                .font(NudgeType.rounded(12.5))
                                .foregroundStyle(Theme.inkMuted)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            HStack(spacing: 9) {
                                Button {
                                    model.openAgentNetwork(focus: first.agentID)
                                } label: {
                                    Text("Review proposal")
                                        .font(NudgeType.rounded(13, .semibold))
                                        .foregroundStyle(Theme.base)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(Theme.ink, in: .capsule)
                                }
                                .buttonStyle(NudgeButtonStyle())
                                Button {
                                    model.declineAgentTask(first.id)
                                } label: {
                                    Text("Not now")
                                        .font(NudgeType.rounded(13, .medium))
                                        .foregroundStyle(Theme.ink)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(Theme.raised.opacity(0.9), in: .capsule)
                                        .overlay(Capsule().strokeBorder(Theme.edge.opacity(0.7), lineWidth: 0.8))
                                }
                                .buttonStyle(NudgeButtonStyle())
                                if waiting.count > 1 {
                                    Text("+\(waiting.count - 1) more")
                                        .font(NudgeType.rounded(11.5, .medium))
                                        .foregroundStyle(Theme.inkMuted)
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .buttonStyle(NudgeButtonStyle())
        .accessibilityLabel("Your Rumi agent network. \(summaryLine)")
    }

    private var summaryLine: String {
        let w = waiting.count
        if w > 0 { return "Demo examples · \(w) proposals to review" }
        return "Illustrative agent tasks · no external actions"
    }

    private var agentDots: some View {
        let active = model.agentServices.filter { $0.active && model.activeTaskCount(forAgent: $0.id) > 0 }.prefix(4)
        return ZStack {
            ForEach(Array(active.enumerated()), id: \.element.id) { index, service in
                Image(systemName: service.glyph)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(agentAccentColor(service.accent))
                    .frame(width: 28, height: 28)
                    .background(Theme.surface, in: .circle)
                    .overlay(Circle().strokeBorder(Theme.base, lineWidth: 1.5))
                    .offset(x: CGFloat(index) * 17)
            }
        }
        .frame(width: 28 + 17 * CGFloat(max(0, min(4, active.count) - 1)), height: 28, alignment: .leading)
    }
}

// MARK: - Source chips

/// Live source chips for a task — connected sources read as active dots;
/// linkable ones not yet connected become a gentle "Connect" invitation.
struct FlowSourceChips: View {
    @Environment(AppModel.self) private var model
    let sources: [AgentSource]

    var body: some View {
        FlowLayout(spacing: 6, lineSpacing: 6) {
            ForEach(sources) { source in
                chip(source)
            }
        }
    }

    @ViewBuilder
    private func chip(_ source: AgentSource) -> some View {
        let connection = source.connectionID.flatMap { id in model.connections.first { $0.id == id } }
        let needsConnect = connection != nil && connection?.connected == false
        if needsConnect, let connection {
            Button {
                model.openCare(.connections)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 9, weight: .semibold))
                    Text("Demo source: \(source.label)")
                        .font(NudgeType.rounded(10.5, .medium))
                }
                .foregroundStyle(Theme.inkMuted)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Theme.raised.opacity(0.7), in: .capsule)
                .overlay(Capsule().strokeBorder(Theme.edge.opacity(0.7), lineWidth: 0.8))
            }
            .buttonStyle(NudgeButtonStyle())
        } else {
            HStack(spacing: 4) {
                Circle().fill(Theme.life).frame(width: 5, height: 5)
                Text("Example: " + source.label)
                    .font(NudgeType.rounded(10.5, .medium))
            }
            .foregroundStyle(Theme.ink.opacity(0.75))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Theme.life.opacity(0.1), in: .capsule)
        }
    }
}

/// Plain source-name chips for the network's "reading across" summary.
struct FlowChips: View {
    let sources: [String]
    var body: some View {
        FlowLayout(spacing: 6, lineSpacing: 6) {
            ForEach(sources, id: \.self) { label in
                HStack(spacing: 4) {
                    Circle().fill(Theme.life).frame(width: 5, height: 5)
                    Text(label)
                        .font(NudgeType.rounded(10.5, .medium))
                }
                .foregroundStyle(Theme.ink.opacity(0.75))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Theme.life.opacity(0.1), in: .capsule)
            }
        }
    }
}

// MARK: - Helpers

func agentAccentColor(_ key: AccentKey) -> Color {
    switch key {
    case .warm: return Theme.warm
    case .life: return Theme.life
    case .sky: return Theme.sky
    case .gold: return Theme.gold
    case .rose: return Theme.rose
    }
}

/// A simple wrapping flow layout for chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += rowHeight + lineSpacing; rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = bounds.minX, y: CGFloat = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.minX + maxWidth, x > bounds.minX {
                x = bounds.minX; y += rowHeight + lineSpacing; rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
