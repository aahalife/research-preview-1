import SwiftUI

/// Direct access to the selected upcoming visit and its preparation.
struct TodayVisitCard: View {
    @Environment(AppModel.self) private var model
    let appointment: Appointment

    var body: some View {
        OrganicSurface(radius: 22) {
            VStack(alignment: .leading, spacing: 0) {
                Button { model.openCare(.appointmentDetail(appointment.id)) } label: {
                    HStack(alignment: .top, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("UPCOMING VISIT")
                                .font(NudgeType.rounded(10, .semibold))
                                .tracking(1.1)
                                .foregroundStyle(Theme.warm)
                            Text(appointment.with)
                                .font(NudgeType.serif(19))
                                .foregroundStyle(Theme.ink)
                            Text(appointment.date.formatted(.dateTime.weekday(.wide).hour().minute()))
                                .font(NudgeType.rounded(13))
                                .foregroundStyle(Theme.inkMuted)
                            Text(appointment.status.rawValue)
                                .font(NudgeType.rounded(11, .medium))
                                .foregroundStyle(Theme.warm)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        VStack(spacing: 2) {
                            Text(appointment.date.formatted(.dateTime.month(.abbreviated)).uppercased())
                                .font(NudgeType.rounded(10, .semibold))
                            Text(appointment.date.formatted(.dateTime.day()))
                                .font(NudgeType.number(24, .medium))
                        }
                        .foregroundStyle(Theme.warm)
                        .frame(width: 56, height: 60)
                        .background(Theme.accentSoft, in: .rect(cornerRadius: 14))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .contentShape(Rectangle())
                }
                .buttonStyle(NudgeButtonStyle())
                .accessibilityIdentifier("today.upcomingVisit")
                Divider().overlay(Theme.edge).padding(.horizontal, 18)
                Button { model.openCare(.visitPrep(appointment.id)) } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "list.bullet.clipboard")
                        Text("Prepare for this visit")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .font(NudgeType.rounded(13, .medium))
                    .foregroundStyle(Theme.warm)
                    .frame(minHeight: 48)
                    .padding(.horizontal, 18)
                }
                .buttonStyle(NudgeButtonStyle())
                .accessibilityIdentifier("today.prepareVisit")
            }
        }
    }
}
