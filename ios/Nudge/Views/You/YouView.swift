import SwiftUI

enum YouDestination: Hashable {
    case records
    case category(RecordCategory)
    case labDetail(String)
    case medications
    case medDetail(String)
    case care
    case visitPrep(UUID)
    case conditions
    case guide
    case life
    case journeys
    case currents
    case connections
}

/// Personal history and everyday support, with clinical aliases preserved for older entry points.
struct YouView: View {
    @Environment(AppModel.self) private var model

    enum Section: String, CaseIterable {
        case story = "Story"
        case insights = "Insights"
    }

    var body: some View {
        @Bindable var model = model
        NavigationStack(path: $model.youPath) {
            ZStack {
                LivingGradientView()
                VStack(spacing: 0) {
                    header
                    quickDoors
                    switch model.youSection {
                    case .story: StoryTimelineView()
                    case .insights: InsightsHubView()
                    }
                }
            }
            .navigationDestination(for: YouDestination.self) { YouRouteView(destination: $0) }
            .navigationDestination(for: CareDestination.self) { CareRouteView(destination: $0) }
            .toolbar(.hidden, for: .navigationBar)
            .onReceive(NotificationCenter.default.publisher(for: .nudgeOpenConditions)) { _ in
                model.openYou(.conditions)
            }
            .onReceive(NotificationCenter.default.publisher(for: .nudgeOpenLife)) { _ in
                model.openYou(.life)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            GlassSurface(radius: 24) {
                HStack(spacing: 4) {
                    ForEach(Section.allCases, id: \.self) { item in
                        let selected = model.youSection == item
                        Button {
                            Haptics.tick()
                            withAnimation(NudgeSpring.ui) { model.youSection = item }
                        } label: {
                            Text(item.rawValue)
                                .font(NudgeType.rounded(13, selected ? .semibold : .medium))
                                .foregroundStyle(selected ? Theme.ink : Theme.inkMuted)
                                .padding(.horizontal, 16)
                                .frame(minHeight: 44)
                                .background {
                                    if selected { Capsule().fill(Theme.surface.opacity(0.9)) }
                                }
                        }
                        .buttonStyle(NudgeButtonStyle())
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                }
                .padding(4)
            }
            Spacer(minLength: 0)
            Button { model.showSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(Theme.inkMuted)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Account and settings")
        }
        .padding(.leading, 20)
        .padding(.trailing, 72)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var quickDoors: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                door(glyph: "leaf", label: "Journeys", accent: Theme.life, destination: .journeys)
                door(glyph: "water.waves", label: "Currents", accent: Theme.sky, destination: .currents)
                door(glyph: "fork.knife", label: "Life", accent: Theme.rose, destination: .life)
                door(glyph: "link", label: "Connections", accent: Theme.gold, destination: .connections)
            }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func door(glyph: String, label: String, accent: Color, destination: YouDestination) -> some View {
        NavigationLink(value: destination) {
            HStack(spacing: 6) {
                Image(systemName: glyph)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(accent)
                Text(label)
                    .font(NudgeType.rounded(12, .medium))
                    .foregroundStyle(Theme.ink)
            }
            .padding(.horizontal, 13)
            .frame(minHeight: 44)
            .background(.ultraThinMaterial, in: .capsule)
            .overlay(Capsule().strokeBorder(accent.opacity(0.3), lineWidth: 0.8))
        }
        .buttonStyle(NudgeButtonStyle())
        .accessibilityIdentifier("you.\(label.lowercased())")
    }
}
