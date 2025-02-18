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
}

final class FeatureFlagsVariableStore: VariableStore {
    @Variable var notifications = false
    @Variable var fastRefreshWidgets = false
}
