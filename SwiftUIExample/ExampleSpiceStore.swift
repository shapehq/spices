import Foundation
import SHPSpices

enum ServiceEnvironment: String, CaseIterable {
    case production
    case staging
}

final class ExampleSpiceStore: SpiceStore {
    @Spice(requiresRestart: true) var environment: ServiceEnvironment = .production
    @Spice var enableLogging = false
    let featureFlags = FeatureFlagsSpiceStore()
    @Spice var clearCache = {
        URLCache.shared.removeAllCachedResponses()
    }
    @Spice var longOperation = {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    @Spice var failingOperation = {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        throw NSError(domain: "dk.shape.Spices", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "🚨 This error was intentional to demonstrate how Spices handles failing operations."
        ])
    }
}

final class FeatureFlagsSpiceStore: SpiceStore {
    @Spice var notifications = false
    @Spice var fastRefreshWidgets = false

    fileprivate init() {}
}
