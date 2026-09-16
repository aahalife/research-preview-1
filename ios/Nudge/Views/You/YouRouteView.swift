import SwiftUI

/// One destination renderer for both the personal history and contextual clinical routes.
struct YouRouteView: View {
    @Environment(AppModel.self) private var model
    let destination: YouDestination

    var body: some View {
        ZStack {
            LivingGradientView()
            switch destination {
            case .records: RecordsDrawerView()
            case .category(let category): RecordCategoryView(category: category)
            case .labDetail(let id):
                if let series = model.series(id) {
                    LabDetailView(series: series)
                } else {
                    ContentUnavailableView("This result isn't available", systemImage: "doc.text")
                }
            case .medications: MedicationsView()
            case .medDetail(let id):
                if let med = model.medications.first(where: { $0.id == id }) {
                    MedDetailView(medication: med)
                } else {
                    ContentUnavailableView("This medication isn't available", systemImage: "pills")
                }
            case .care: CareTeamView()
            case .visitPrep(let id): VisitPrepView(appointmentID: id)
            case .conditions: ConditionOverviewView()
            case .guide: DiscussionGuideView()
            case .life: LifeCatalogView()
            case .journeys: JourneysView()
            case .currents: CurrentsView()
            case .connections: ConnectionsView()
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
