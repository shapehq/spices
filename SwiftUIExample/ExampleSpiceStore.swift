import Foundation
import SHPSpices

enum ServiceEnvironment: String, CaseIterable {
    case production
    case staging
}

final class ExampleSpiceStore: SpiceStore {
    @Spice(requiresRestart: true) var environment: ServiceEnvironment = .production
    @Spice var enableLogging = false
    @Spice var clearCache = {
        URLCache.shared.removeAllCachedResponses()
    }
    
    let featureFlags = FeatureFlagsSpiceStore()
}

final class FeatureFlagsSpiceStore: SpiceStore {
    @Spice var notifications = false
    @Spice var fastRefreshWidgets = false

    fileprivate init() {}
}
