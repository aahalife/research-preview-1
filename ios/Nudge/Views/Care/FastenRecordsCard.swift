import SwiftUI

struct FastenRecordsCard: View {
    @Environment(AppModel.self) private var model
    @State private var showConnect: Bool = false
    @State private var expanded: Bool = false
    @State private var showLiveInfo: Bool = false
    @State private var showTestSetup: Bool = false
    var body: some View {
        OrganicSurface {
            VStack(alignment: .leading, spacing: 12) {
                Label("Fasten Connect", systemImage: "link").font(NudgeType.serif(20))
                if let record = model.demoRecordImport {
                    Text(record.isRevoked ? "Demo connection paused" : record.isPartial ? "Partial sample import" : "Sample import ready")
                        .font(NudgeType.rounded(15, .semibold))
                    Text("\(record.items.count) items · \(record.importedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(NudgeType.rounded(12)).foregroundStyle(Theme.inkMuted)
                    DisclosureGroup("Review imported sample items", isExpanded: $expanded) {
                        ForEach(record.items) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title).font(NudgeType.rounded(14, .medium))
                                Text(item.detail).font(NudgeType.rounded(12)).foregroundStyle(Theme.inkMuted)
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 7)
                        }
                    }
                    Text(record.provenance).font(NudgeType.rounded(12)).foregroundStyle(Theme.inkMuted)
                    HStack {
                        Button("Try again") { showConnect = true }.frame(minHeight: 44)
                        Spacer()
                        Button("Remove import", role: .destructive) { model.demoRecordImport = nil; model.persistUserData() }.frame(minHeight: 44)
                    }
                } else {
                    Text("Bring authorized records together. Try profile confirmation, sharing and an import with sample data.")
                        .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                    Button("Try a demo connection") { showConnect = true }.frame(minHeight: 44)
                        .accessibilityIdentifier("records.connectFasten")
                }
                Button("Fasten test setup") { showTestSetup = true }.frame(minHeight: 44)
                    .font(NudgeType.rounded(13, .medium))
                    .accessibilityIdentifier("records.fastenTestSetup")
                Button("Connect my real records") { showLiveInfo = true }.frame(minHeight: 44)
                    .font(NudgeType.rounded(13, .medium))
            }.padding(18)
        }
        .foregroundStyle(Theme.ink)
        .sheet(isPresented: $showConnect) {
            FastenConnectionView(pathway: model.pathway) { model.demoRecordImport = $0; model.persistUserData() }
        }
        .sheet(isPresented: $showTestSetup) { FastenSetupView() }
        .alert("Real connections aren't configured yet", isPresented: $showLiveInfo) {
            Button("OK", role: .cancel) { }
        } message: { Text("This build uses sample records. A verified account, Fasten tenant configuration and provider authorization are required before your records can be imported. No real data has been requested.") }
    }
}
