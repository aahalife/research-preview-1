import Foundation
import Observation

@Observable
@MainActor
final class FastenSetupViewModel {
    private(set) var status: FastenSetupStatus? = nil
    private(set) var isChecking: Bool = false
    private(set) var error: String? = nil

    func refresh() async {
        guard !isChecking else { return }
        guard let baseURL = URL(string: Config.EXPO_PUBLIC_RORK_FUNCTIONS_URL),
              baseURL.scheme == "https", baseURL.host != nil,
              baseURL.user == nil, baseURL.password == nil, baseURL.query == nil, baseURL.fragment == nil else {
            error = "The test service address is not configured in this build. Demo remains available."
            return
        }
        isChecking = true
        error = nil
        status = nil
        defer { isChecking = false }
        do {
            let result = try await FastenSetupService(baseURL: baseURL).load()
            try Task.checkCancellation()
            status = result
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            self.error = "We couldn’t check the test setup. Your records and Demo haven’t changed. Try again when you’re connected."
        }
    }
}
