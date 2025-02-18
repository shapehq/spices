import Foundation
import SHPSpices

enum ServiceEnvironment: String, CaseIterable {
    case production
    case staging
}

final class ExampleVariableStore: VariableStore {
    @Variable(requiresRestart: true) var environment: ServiceEnvironment = .production
    @Variable var enableLogging = false
    let featureFlags = FeatureFlagsVariableStore()
    @Variable var clearCache = {
        URLCache.shared.removeAllCachedResponses()
    }
    @Variable var longOperation = {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

final class FeatureFlagsVariableStore: VariableStore {
    @Variable var notifications = false
    @Variable var fastRefreshWidgets = false
}
