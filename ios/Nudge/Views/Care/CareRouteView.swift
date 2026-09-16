import SwiftUI

/// Shared detail destinations keep legacy and contextual entry points on the same screens.
struct CareRouteView: View {
    let destination: CareDestination

    var body: some View {
        ZStack {
            LivingGradientView()
            switch destination {
            case .messages: MessagesView()
            case .thread(let id): MessageThreadView(threadID: id)
            case .appointments: AppointmentsView()
            case .appointmentDetail(let id): AppointmentDetailView(appointmentID: id)
            case .trip(let id): TripView(appointmentID: id)
            case .carePlan: CarePlanView()
            case .medications: MedicationsView()
            case .requests: RequestsView()
            case .savings(let id): SavingsView(medID: id)
            case .records: RecordsDrawerView()
            case .bills: BillsView()
            case .billDetail(let id): BillDetailView(billID: id)
            case .documents: DocumentsView()
            case .visitPrep(let id): VisitPrepView(appointmentID: id)
            case .reports: ReportsView()
            case .wallet: WalletView()
            case .connections: ConnectionsView()
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
