import SwiftUI

struct HabitPlanView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    var journeyID: UUID? = nil
    var habitID: UUID? = nil
    var proposedTitle: String = ""
    var proposedCue: String = ""
    var onSaved: (() -> Void)? = nil
    @State private var title: String = ""
    @State private var support: HabitSupportPlan = .init()
    @State private var note: String = ""
    @State private var loaded: Bool = false
    @State private var feedback: String? = nil
    private var habit: AtomicHabit? { model.journeys.first { $0.id == journeyID }?.habits.first { $0.id == habitID } }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(habitID == nil ? "Make it fit your life." : "A small step, your way.").font(NudgeType.display(29))
                    Text("Choose what matters to you. A plan is an experiment, not a promise to be perfect.")
                        .font(NudgeType.rounded(14)).foregroundStyle(Theme.inkMuted)
                }.listRowBackground(Color.clear)
                Section("Your step") {
                    TextField("One tiny action", text: $title, axis: .vertical).accessibilityIdentifier("habit.title")
                    TextField("Why this matters to me · optional", text: $support.reason, axis: .vertical)
                    TextField("After I… (an everyday cue)", text: $support.cue, axis: .vertical).accessibilityIdentifier("habit.cue")
                }
                Section("Room for real life") {
                    TextField("What might get in the way?", text: $support.barrier, axis: .vertical).accessibilityIdentifier("habit.barrier")
                    TextField("On a hard day, a smaller option…", text: $support.fallback, axis: .vertical).accessibilityIdentifier("habit.fallback")
                    Picker("How doable does it feel?", selection: $support.confidence) {
                        Text("Not yet").tag(1); Text("A stretch").tag(2); Text("Maybe").tag(3); Text("Doable").tag(4); Text("Very doable").tag(5)
                    }
                    Text("Your own check, not a health score. If it feels too big, shrink the step or choose another cue.")
                        .font(NudgeType.rounded(13)).foregroundStyle(Theme.inkMuted)
                    Toggle("Pause this habit", isOn: $support.paused)
                }
                if let journeyID, let habitID, habit != nil {
                    Section("How did it go today?") {
                        TextField("Anything you'd like to remember?", text: $note, axis: .vertical)
                        ForEach(HabitCheckIn.Outcome.allCases, id: \.self) { outcome in
                            Button(outcome.rawValue) {
                                model.recordHabitCheckIn(journeyID: journeyID, habitID: habitID, outcome: outcome, note: note)
                                feedback = outcome == .blocked ? "That tells us something about the plan, not about you. You can change the cue or make the step smaller." : outcome == .skipped ? "A day off doesn't erase anything. Come back when it fits." : "Noted. There's no need to raise the bar."
                            }.disabled(support.paused || habit?.support?.paused == true)
                        }
                        if let feedback { Text(feedback).font(NudgeType.rounded(14)).foregroundStyle(Theme.warm) }
                        Button("Undo today's check-in", role: .destructive) { model.undoHabitCheckIn(journeyID: journeyID, habitID: habitID); feedback = "Today's check-in was removed." }
                    }
                    Section("Your recent check-ins") {
                        let history = model.habitCheckIns.filter { $0.habitID == habitID }.sorted { $0.at > $1.at }
                        if history.isEmpty { Text("Nothing to catch up on. Start when you're ready.") }
                        ForEach(history.prefix(7)) { checkIn in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(checkIn.outcome.rawValue)
                                Text(checkIn.at.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundStyle(Theme.inkMuted)
                                if !checkIn.note.isEmpty { Text(checkIn.note).font(.caption) }
                            }
                        }
                    }
                }
                Section {
                    Button(habitID == nil ? "Choose this step" : "Save my changes") {
                        support.updatedAt = .now
                        model.saveHabit(journeyID: journeyID, habitID: habitID, title: title, support: support)
                        if !model.storageError { onSaved?(); dismiss() }
                    }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier("habit.save")
                    Text("You can edit or pause at any time. Rumi won't change your care plan, medication or activity restrictions.")
                        .font(.caption).foregroundStyle(Theme.inkMuted)
                }
            }
            .scrollContentBackground(.hidden).background(Theme.base).tint(Theme.warm)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .onAppear {
                guard !loaded else { return }; loaded = true
                title = habit?.title ?? proposedTitle
                support = habit?.support ?? .init(cue: habit?.contextLine ?? proposedCue)
            }
        }
    }
}
