import SwiftUI

/// The four clinical workspaces and the separate provider inbox share detail routes.
struct CareHubView: View {
    @Environment(AppModel.self) private var model
    var isMessages: Bool = false

    private var path: Binding<NavigationPath> {
        Binding(get: { isMessages ? model.messagesPath : model.carePath }, set: {
            if isMessages { model.messagesPath = $0 } else { model.carePath = $0 }
        })
    }

    var body: some View {
        NavigationStack(path: path) {
            ZStack {
                LivingGradientView()
                if isMessages {
                    MessagesView()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Care")
                                .font(NudgeType.serif(32))
                                .foregroundStyle(Theme.ink)
                                .padding(.trailing, 52)
                            surfacesGrid
                            HStack(spacing: 24) {
                                NavigationLink(value: YouDestination.care) {
                                    Label("Care team", systemImage: "person.2")
                                }
                                NavigationLink(value: CareDestination.bills) {
                                    Label("Bills & wallet", systemImage: "creditcard")
                                }
                            }
                            .font(NudgeType.rounded(13, .medium))
                            .foregroundStyle(Theme.inkMuted)
                            .frame(minHeight: 44)
                            if model.showsLookingAhead, let nudge = model.lookingAhead {
                                LookingAheadCard(nudge: nudge) {
                                    model.addGuideItem(kind: .question, text: nudge.guideQuestion, from: "A look ahead")
                                    model.carePath.append(YouDestination.guide)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 132)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationDestination(for: CareDestination.self) { CareRouteView(destination: $0) }
            .navigationDestination(for: YouDestination.self) { YouRouteView(destination: $0) }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { consumePending() }
            .onChange(of: model.pendingCareDestination) { _, _ in consumePending() }
        }
    }

    private var surfacesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            CareTile(glyph: "calendar", title: "Appointments", status: appointmentsStatus, accent: Theme.gold) {
                model.carePath.append(CareDestination.appointments)
            }
            CareTile(glyph: "list.bullet.clipboard", title: "Care plan", status: "Your goals and next steps", accent: Theme.life) {
                model.carePath.append(CareDestination.carePlan)
            }
            CareTile(glyph: "pills", title: "Meds & refills", status: medsStatus, accent: Theme.warm) {
                model.carePath.append(CareDestination.medications)
            }
            CareTile(glyph: "waveform.path.ecg", title: "Records & results", status: recordsStatus, accent: Theme.rose) {
                model.carePath.append(CareDestination.records)
            }
        }
    }

    private var appointmentsStatus: String {
        guard let next = model.appointments.filter({ $0.date >= .now && $0.status != .cancelled }).min(by: { $0.date < $1.date }) else {
            return model.appointments.isEmpty ? "Nothing scheduled" : "Visit history and preparation"
        }
        return "Next \(Self.relativeDay(next.date))"
    }

    private var medsStatus: String {
        let low = model.medications.filter { $0.supplyDaysRemaining <= 7 }.count
        return low > 0 ? "\(low) running low" : "Your medication list"
    }

    private var recordsStatus: String {
        model.recordUpdateCount > 0 ? "A new result to review" : "Your health history"
    }

    private func consumePending() {
        guard let destination = model.pendingCareDestination else { return }
        model.openCare(destination)
    }

    static func relativeDay(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now),
                                                   to: Calendar.current.startOfDay(for: date)).day ?? 0
        switch days {
        case ..<0: return "past"
        case 0: return "today"
        case 1: return "tomorrow"
        case 2...6: return date.formatted(.dateTime.weekday(.wide))
        default: return "in \(days) days"
        }
    }
}

struct CareTile: View {
    let glyph: String
    let title: String
    let status: String
    let accent: Color
    var badge: Int = 0
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tick()
            SoundEngine.shared.tick()
            action()
        } label: {
            OrganicSurface(radius: 26) {
                VStack(alignment: .leading, spacing: 16) {
                    Image(systemName: glyph)
                        .font(.system(size: 19, weight: .light))
                        .foregroundStyle(accent)
                        .frame(width: 42, height: 42)
                        .background(accent.opacity(0.14), in: .circle)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(NudgeType.serif(17))
                            .foregroundStyle(Theme.ink)
                        Text(status)
                            .font(NudgeType.rounded(12))
                            .foregroundStyle(Theme.inkMuted)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
                .padding(16)
            }
        }
        .buttonStyle(NudgeButtonStyle())
        .accessibilityIdentifier("care.\(title)")
    }
}

/// An optional population-level prompt, never a diagnosis or individual prediction.
struct LookingAheadCard: View {
    let nudge: LookingAheadNudge
    let onAddToGuide: () -> Void
    @State private var showBasis: Bool = false
    @State private var added: Bool = false

    var body: some View {
        OrganicSurface(radius: 30) {
            VStack(alignment: .leading, spacing: 11) {
                Kicker(text: "A gentle look ahead", color: Theme.sky)
                Text(nudge.headline)
                    .font(NudgeType.serif(19))
                    .foregroundStyle(Theme.ink)
                Text(nudge.body)
                    .font(NudgeType.rounded(13.5))
                    .foregroundStyle(Theme.inkMuted)
                    .lineSpacing(3)
                if showBasis {
                    Text(nudge.basis)
                        .font(NudgeType.rounded(12))
                        .foregroundStyle(Theme.inkMuted)
                }
                HStack(spacing: 10) {
                    Button(added ? "Added to your guide" : "Add to my guide") {
                        onAddToGuide()
                        added = true
                    }
                    .disabled(added)
                    .font(NudgeType.rounded(13.5, .semibold))
                    .foregroundStyle(Theme.ink)
                    .frame(minHeight: 44)
                    Button(showBasis ? "Hide why" : "Why am I seeing this?") {
                        withAnimation(NudgeSpring.gentle) { showBasis.toggle() }
                    }
                    .font(NudgeType.rounded(12.5, .medium))
                    .foregroundStyle(Theme.inkMuted)
                    .frame(minHeight: 44)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(18)
        }
    }
}
