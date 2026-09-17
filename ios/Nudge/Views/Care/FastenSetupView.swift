import SwiftUI

/// Kept outside the synthetic import flow; opening this screen never authorizes a patient.
struct FastenSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: FastenSetupViewModel = FastenSetupViewModel()
    @State private var refreshID: UUID = UUID()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("VENDOR TEST SETUP", systemImage: "wrench.adjustable")
                            .font(NudgeType.rounded(11, .semibold)).foregroundStyle(Theme.inkMuted)
                        Text("Connect with care.").font(NudgeType.display(32))
                            .accessibilityIdentifier("fasten.setup.title")
                        Text("Check the Fasten test service without sharing your profile or changing Demo.")
                            .font(NudgeType.rounded(15)).foregroundStyle(Theme.inkMuted)
                    }
                    if model.isChecking {
                        ProgressView("Checking test configuration…").frame(maxWidth: .infinity, minHeight: 60)
                    }
                    if let error = model.error {
                        Text(error).font(NudgeType.rounded(14)).foregroundStyle(Theme.attention)
                            .accessibilityIdentifier("fasten.setup.error")
                    }
                    if let status = model.status {
                        OrganicSurface {
                            VStack(alignment: .leading, spacing: 18) {
                                row("Test credentials", detail: status.credentialsConfigured ? "Stored on the server. Private-key access is not yet verified." : "Missing or not test-mode credentials.", complete: status.credentialsConfigured)
                                row("Fasten organization", detail: status.organizationSummary, complete: status.organization == "active")
                                row("Signed event delivery", detail: status.webhookSecretConfigured ? "Signing secret configured; delivery still needs verification." : "Add the signing secret from the registered test webhook.", complete: status.webhookSecretConfigured)
                                row("Browser return", detail: status.redirectConfigured ? "Return address configured; the portal registration still needs verification." : "Register the return address in Fasten’s Developer Portal.", complete: status.redirectConfigured)
                            }.padding(18)
                        }
                        DisclosureGroup("Developer setup addresses") {
                            VStack(alignment: .leading, spacing: 14) {
                                address("Redirect URL", url: status.returnURL)
                                address("Webhook URL", url: status.webhookURL)
                                Text("Register these in Fasten test mode. Use only official synthetic test patients once authorization is enabled.")
                                    .font(NudgeType.rounded(12)).foregroundStyle(Theme.inkMuted)
                            }.padding(.top, 12)
                        }.font(NudgeType.rounded(14, .medium))
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Not connected yet").font(NudgeType.serif(21))
                        Text("Browser authorization and record imports remain off while setup and session ownership are completed. A configured key is not permission to access anyone’s records.")
                            .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                        Text("Your local sample import stays separate.")
                            .font(NudgeType.rounded(13, .medium))
                    }.accessibilityIdentifier("fasten.setup.boundary")
                    Button("Check again") { refreshID = UUID() }
                        .font(NudgeType.rounded(15, .semibold))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Theme.life.opacity(0.14), in: .capsule)
                        .disabled(model.isChecking)
                        .accessibilityIdentifier("fasten.setup.refresh")
                }.padding(.horizontal, 20).padding(.vertical, 24)
            }
            .background(Theme.base)
            .foregroundStyle(Theme.ink)
            .navigationTitle("Fasten test setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.accessibilityIdentifier("fasten.setup.close")
                }
            }
            .task(id: refreshID) { await model.refresh() }
        }
    }

    private func row(_ title: String, detail: String, complete: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: complete ? "checkmark.circle" : "circle.dotted")
                .foregroundStyle(complete ? Theme.life : Theme.inkMuted).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(NudgeType.rounded(15, .semibold))
                Text(detail).font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
            }
        }.accessibilityElement(children: .combine)
    }

    private func address(_ title: String, url: URL) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(NudgeType.rounded(12, .semibold))
            Text(url.absoluteString).font(.system(.caption, design: .monospaced)).textSelection(.enabled)
            ShareLink("Share address", item: url).font(NudgeType.rounded(13)).frame(minHeight: 44)
        }
    }
}
