import Foundation
import SwiftUI

extension AppModel {
    func openConversation(context: CareContext) {
        guard context.scenario == pathway.rawValue else { return }
        companion.prepare(context: context)
        withAnimation(NudgeSpring.gentle) { showConversation = true }
    }

    func context(for medication: Medication) -> CareContext {
        .init(id: medication.id, scenario: pathway.rawValue, title: medication.name,
              source: "Sample medication list · not a live dispense record",
              detail: "\(medication.dose) · \(medication.scheduleLine). Listed purpose: \(medication.purposeLine). Sample supply: \(medication.supplyDaysRemaining) days; date and calculation basis unverified. No pharmacy availability or refill authorization is known.",
              question: "Help me prepare a refill question about \(medication.name).")
    }

    func context(for series: LabSeries) -> CareContext {
        let values = series.points.sorted { $0.date < $1.date }.suffix(12)
            .map { "\($0.date.formatted(date: .abbreviated, time: .omitted)): \($0.value) \(series.unit)" }.joined(separator: "\n")
        return .init(id: series.id, scenario: pathway.rawValue, title: series.name,
                     source: "Sample series · \(series.provenance)", detail: values,
                     question: "Help me understand these \(series.name) results and prepare a question for my care team.")
    }

    func context(for item: RecordItem) -> CareContext {
        .init(id: "record|\(item.category.rawValue)|\(item.source)|\(item.title)|\(item.date.timeIntervalSince1970)", scenario: CarePathway.metabolic.rawValue, title: item.title,
              source: "Sample record · \(item.source) · \(item.date.formatted(date: .abbreviated, time: .omitted))",
              detail: "\(item.category.rawValue): \(item.detail)\n\(item.conflictNote ?? "No additional source text supplied.")",
              question: "Explain what this \(item.category.rawValue.lowercased()) entry says, and what information is missing.")
    }

    func context(for insight: Insight) -> CareContext {
        .init(id: insight.id.uuidString, scenario: pathway.rawValue, title: insight.headline,
              source: "Illustrative insight · \(insight.provenance)",
              detail: "\(insight.body)\nListed basis: \(insight.sources.joined(separator: ", ")). \(insight.confidence ?? "No confidence estimate supplied.") This is a sample narrative, not a newly computed clinical finding.",
              question: "Help me think through this insight without assuming it proves a cause.")
    }

    func context(for piece: CurrentsPiece) -> CareContext {
        .init(id: piece.id.uuidString, scenario: pathway.rawValue, title: piece.headline,
              source: "Sample Currents editorial · \(piece.format.rawValue)", detail: piece.body,
              question: "Can we talk about this piece and whether any part fits my day?")
    }

    func context(for entry: CareEntry) -> CareContext {
        .init(id: entry.id.uuidString, scenario: pathway.rawValue, title: entry.title,
              source: "Life log · \(entry.at.formatted(date: .abbreviated, time: .shortened))",
              detail: "\(entry.kind.displayName): \(entry.detail). Note: \(entry.note ?? "None"). Library images and estimates are not measured nutrition or effort.",
              question: "I logged \(entry.title). Help me reflect on it without drawing conclusions from one entry.")
    }
}
