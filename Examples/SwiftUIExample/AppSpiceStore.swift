import Foundation
import Spices

enum ServiceEnvironment: String, CaseIterable {
    case production
    case staging
}

final class AppSpiceStore: SpiceStore {
    @Spice(requiresRestart: true) var environment: ServiceEnvironment = .production
    @Spice var enableLogging = false
    @Spice var clearCache = {
        try await Task.sleep(for: .seconds(1))
        URLCache.shared.removeAllCachedResponses()
    }

    let featureFlags = FeatureFlagsSpiceStore()
}

final class FeatureFlagsSpiceStore: SpiceStore {
    @Spice var notifications = false
    @Spice var fastRefreshWidgets = false

    fileprivate init() {}
}
