import SwiftUI

/// Demonstrates authorization UX using only a synthetic scenario. No credentials or real PHI leave this view.
struct FastenConnectionView: View {
    @Environment(\.dismiss) private var dismiss
    let pathway: CarePathway
    let onComplete: (DemoRecordImport) -> Void
    @State private var profile: RecordConnectionProfile = .init()
    @State private var initialized: Bool = false
    @State private var step: Int = 0
    @State private var scopes: Set<String> = ["Results", "Medications", "Conditions"]
    @State private var consent: Bool = false
    @State private var partial: Bool = false
    @State private var error: String? = nil
    @State private var imported: DemoRecordImport? = nil
    @State private var progress: Int = 0
    @State private var task: Task<Void, Never>? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Label("FASTEN CONNECTION · DEMO", systemImage: "link")
                        .font(NudgeType.kicker()).foregroundStyle(Theme.warm)
                    Text(title).font(NudgeType.display(32)).accessibilityIdentifier("fasten.title")
                    if step == 0 { identity }
                    else if step == 1 { sharing }
                    else if step == 2 { importing }
                    else { review }
                    if let error { Text(error).font(NudgeType.rounded(14)).foregroundStyle(Theme.attention).accessibilityIdentifier("fasten.error") }
                }
                .padding(.horizontal, 22).padding(.vertical, 20)
            }
            .background(Theme.base)
            .foregroundStyle(Theme.ink)
            .safeAreaInset(edge: .bottom) { footer }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { task?.cancel(); dismiss() }.accessibilityIdentifier("fasten.close")
                }
                if step == 1 {
                    ToolbarItem(placement: .topBarTrailing) { Button("Back") { step = 0; consent = false } }
                }
            }
        }
        .onAppear {
            guard !initialized else { return }
            initialized = true
            let sample = RecordConnectionProfile.sample(pathway.rawValue)
            profile = .init(firstName: sample.firstName, lastName: sample.lastName, email: sample.email)
        }
        .onDisappear { task?.cancel() }
    }

    private var title: String {
        ["Start with you.", "You choose what to share.", "Bringing it together.", "A clearer picture."][step]
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Example social-profile prefill").font(NudgeType.rounded(16, .semibold))
            Text("Apple or Google can share available names and email. These are sample values, not a completed social sign-in. Birthday usually needs your confirmation.")
                .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
            field("First name", text: $profile.firstName, id: "firstName")
            field("Last name", text: $profile.lastName, id: "lastName")
            field("Date of birth · YYYY-MM-DD", text: $profile.dateOfBirth, id: "dob")
                .keyboardType(.numbersAndPunctuation)
            field("Email · optional", text: $profile.email, id: "email").keyboardType(.emailAddress).textInputAutocapitalization(.never)
            Button("Use sample birthday") { profile.dateOfBirth = RecordConnectionProfile.sample(pathway.rawValue).dateOfBirth; error = nil }
                .frame(minHeight: 44).accessibilityIdentifier("fasten.sampleDOB")
            Text("Use sample details only. Name and birthday help match records, but never grant access on their own. A real connection requires provider sign-in or verified identity and consent.")
                .font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
        }
    }

    private var sharing: some View {
        VStack(alignment: .leading, spacing: 18) {
            OrganicSurface {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Sample health system", systemImage: "building.2")
                    Text("\(profile.firstName) \(profile.lastName) · \(profile.dateOfBirth)")
                        .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                    Text("In live use, Fasten opens the provider's authorization page. Rumi never asks for your portal password.")
                        .font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
                }.padding(18)
            }
            ForEach(["Results", "Medications", "Conditions"], id: \.self) { scope in
                Toggle(scope, isOn: Binding(get: { scopes.contains(scope) }, set: { if $0 { scopes.insert(scope) } else { scopes.remove(scope) } }))
                    .accessibilityIdentifier("fasten.scope.\(scope)")
            }
            Toggle("I agree to import these sample records into this demo", isOn: $consent)
                .accessibilityIdentifier("fasten.consent")
            DisclosureGroup("Demo options") { Toggle("Show a partial result import", isOn: $partial).padding(.vertical, 12) }
            Text("No real account is connected. Your selections only control this local demonstration.")
                .font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
        }.tint(Theme.warm)
    }

    private var importing: some View {
        VStack(alignment: .leading, spacing: 20) {
            RumiMarkView(size: 80, animated: true).frame(maxWidth: .infinity)
            ProgressView(value: Double(progress), total: 3).tint(Theme.warm)
            ForEach(Array(["Sample authorization", "Preparing selected records", "Checking sources and dates"].enumerated()), id: \.offset) { index, label in
                Label(label, systemImage: progress > index ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(progress > index ? Theme.warm : Theme.inkMuted)
            }
            Text("Simulated import · no request is sent to Fasten. You can close at any time.")
                .font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
        }
    }

    private var review: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let imported {
                Text(imported.isPartial ? "Some sample results are still pending." : "Your selected sample records are ready.")
                    .font(NudgeType.rounded(17, .semibold))
                Text("\(imported.items.count) items · \(profile.firstName) \(profile.lastName)")
                    .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                ForEach(imported.items) { item in
                    VStack(alignment: .leading, spacing: 5) {
                        Kicker(text: item.category)
                        Text(item.title).font(NudgeType.rounded(16, .medium))
                        Text(item.detail).font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
                    }.padding(16).frame(maxWidth: .infinity, alignment: .leading).background(Theme.surface, in: .rect(cornerRadius: 18))
                }
                Text(imported.provenance).font(NudgeType.rounded(12)).foregroundStyle(Theme.inkMuted)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 4) {
            if step != 2 {
                Button(step == 0 ? "Confirm details" : step == 1 ? "Authorize sample import" : "Keep these sample records") {
                    error = nil
                    if step == 0 {
                        guard profile.isValid else { error = "Enter a valid name and birthday in YYYY-MM-DD format."; return }
                        guard profile.matchesSample(pathway.rawValue) else { error = "These details don't match this sample story. No records were matched. Restore the sample details or close to continue without connecting."; return }
                        step = 1
                    } else if step == 1 { startImport() }
                    else if let imported { onComplete(imported); dismiss() }
                }
                .buttonStyle(.borderedProminent).tint(Theme.buttonFill)
                .controlSize(.large).frame(maxWidth: .infinity)
                .disabled(step == 1 && (!consent || scopes.isEmpty))
                .accessibilityIdentifier("fasten.continue.\(step)")
            }
            if error != nil {
                Button("Restore sample details") { profile = .sample(pathway.rawValue); error = nil }.frame(minHeight: 44)
            }
        }.padding(16).frame(maxWidth: .infinity).background(Theme.base)
    }

    private func field(_ title: String, text: Binding<String>, id: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title).font(NudgeType.rounded(13, .medium)).foregroundStyle(Theme.inkMuted)
            TextField(title, text: text).font(NudgeType.rounded(16)).padding(14)
                .background(Theme.surface, in: .rect(cornerRadius: 12)).autocorrectionDisabled()
                .accessibilityIdentifier("fasten.\(id)")
        }
    }

    private func startImport() {
        guard consent, !scopes.isEmpty, profile.matchesSample(pathway.rawValue) else { return }
        step = 2
        progress = 0
        task = Task {
            do {
                for value in 1...3 {
                    try await Task.sleep(for: .milliseconds(400))
                    try Task.checkCancellation()
                    progress = value
                }
                let persona = PersonaFixtures.persona(for: pathway)
                var items: [DemoRecordImport.Item] = []
                if scopes.contains("Results") {
                    for series in persona.labSeries.prefix(partial ? 1 : persona.labSeries.count) {
                        if let latest = series.latest {
                            items.append(.init(id: "lab-\(series.id)", category: "Result", title: series.name,
                                detail: "\(latest.value) \(series.unit) · \(latest.date.formatted(date: .abbreviated, time: .omitted)) · sample"))
                        }
                    }
                }
                if scopes.contains("Medications") {
                    items += persona.medications.map { .init(id: "med-\($0.id)", category: "Medication", title: $0.name, detail: "\($0.dose) · sample medication list") }
                }
                if scopes.contains("Conditions") {
                    items += persona.conditions.map { .init(id: "condition-\($0.name)", category: "Condition", title: $0.name, detail: "\($0.state) · sample record") }
                }
                imported = .init(profile: profile, scopes: scopes.sorted(), items: items, importedAt: .now, isPartial: partial && scopes.contains("Results"))
                step = 3
            } catch { }
        }
    }
}
