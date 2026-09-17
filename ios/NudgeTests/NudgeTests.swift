import Foundation
import SwiftUI
import Testing
@testable import Nudge

@MainActor
struct NudgeTests {
    @Test func onboardingHasThreeShortStages() {
        #expect(OnboardingFlowView.Stage.allCases == [.welcome, .scenario, .preferences])
    }

    @Test func nextVisitIgnoresPastAndCancelledAppointments() {
        let model = AppModel()
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let old = Appointment(with: "Past", date: now.addingTimeInterval(-100), location: "Clinic", prepReady: true)
        let cancelled = Appointment(with: "Cancelled", date: now.addingTimeInterval(50), location: "Clinic", prepReady: true, status: .cancelled)
        let next = Appointment(with: "Next", date: now.addingTimeInterval(100), location: "Clinic", prepReady: true)
        let later = Appointment(with: "Later", date: now.addingTimeInterval(200), location: "Clinic", prepReady: true)
        model.appointments = [later, cancelled, old, next]
        #expect(model.nextAppointment(after: now)?.id == next.id)
        model.appointments = [old, cancelled]
        #expect(model.nextAppointment(after: now) == nil)
    }

    @Test func fourPrimaryDestinations() {
        #expect(AppModel.Tab.allCases.map(\.rawValue) == ["Today", "Care", "Messages", "You"])
    }

    @Test func communicationRoutesHaveTheirOwnHome() {
        #expect(CareDestination.messages.isMessaging)
        #expect(CareDestination.thread(UUID()).isMessaging)
        #expect(CareDestination.requests.isMessaging)
        #expect(!CareDestination.records.isMessaging)
        #expect(!CareDestination.appointments.isMessaging)
    }

    @Test func selectedAppointmentDoesNotFallBack() throws {
        let model = AppModel()
        model.appointments = CareHubFixtures.bundle(for: .metabolic).appointments
        let selected = try #require(model.appointments.last)
        #expect(model.appointment(withID: selected.id) == selected)
        #expect(model.appointment(withID: UUID()) == nil)
        model.appointments = []
        #expect(model.appointment(withID: selected.id) == nil)
    }

    @Test func directMessagesRoutePreservesOtherTabPaths() {
        let model = AppModel()
        model.carePath.append(CareDestination.appointments)
        model.youPath.append(YouDestination.journeys)
        model.openCare(.thread(UUID()))
        #expect(model.tab == .messages)
        #expect(model.messagesPath.count == 1)
        #expect(model.carePath.count == 1)
        #expect(model.youPath.count == 1)
        model.openCare(.messages)
        #expect(model.messagesPath.isEmpty)
    }

    @Test func oldSnapshotsDecodeWithoutDraftsAndKeepEmptyCollections() throws {
        let data = Data("""
        {"pathway":"metabolic","entries":[],"logs":[],"memories":[],"guideItems":[],
         "memoryNotes":[],"threads":[],"requests":[],"documents":[],"paidBillKeys":[],"derivedJourneyGoals":[]}
        """.utf8)
        let decoded = try JSONDecoder().decode(SanoUserData.self, from: data)
        #expect(decoded.guideItems.isEmpty)
        #expect(decoded.memoryNotes.isEmpty)
        #expect(decoded.threads.isEmpty)
        #expect(decoded.messageDrafts == nil)
    }

    @Test func scenarioSnapshotsDoNotOverwriteEachOther() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        PersistenceService.save(SanoUserData(pathway: "metabolic", messageDrafts: ["a": "Unsent A"]), directory: directory)
        PersistenceService.save(SanoUserData(pathway: "oncology", messageDrafts: ["b": "Unsent B"]), directory: directory)
        let first = try #require(PersistenceService.load(pathway: "metabolic", directory: directory))
        #expect(first.messageDrafts?["a"] == "Unsent A")
        #expect(first.messageDrafts?["b"] == nil)
        PersistenceService.save(SanoUserData(pathway: "metabolic", messageDrafts: [:]), directory: directory)
        #expect(PersistenceService.load(pathway: "metabolic", directory: directory)?.messageDrafts?.isEmpty == true)
        #expect(PersistenceService.load(pathway: "oncology", directory: directory)?.messageDrafts?["b"] == "Unsent B")
    }

    @Test func replyDraftsRoundTripWithoutBecomingMessages() throws {
        let snapshot = SanoUserData(pathway: "metabolic", messageDrafts: ["thread-a": "A question for my visit"])
        let decoded = try JSONDecoder().decode(SanoUserData.self, from: JSONEncoder().encode(snapshot))
        #expect(decoded.messageDrafts?["thread-a"] == "A question for my visit")
        #expect(decoded.threads.isEmpty)
    }
}
