import Foundation
import SHPSpices

enum ServiceEnvironment: String, CaseIterable {
    case production
    case staging
}

final class ExampleVariableStore: VariableStore {
    static let shared = ExampleVariableStore()

    @Variable(requiresRestart: true) var environment: ServiceEnvironment = .production
    @Variable var enableLogging = false
    let featureFlags = FeatureFlagsVariableStore()
    @Variable var clearCache = {
        URLCache.shared.removeAllCachedResponses()
    }
    @Variable var longOperation = {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    @Variable var failingOperation = {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        throw NSError(domain: "dk.shape.Spices", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "🚨 This error was intentional to demonstrate how Spices handles failing operations."
        ])
    }

    private init() {}
}

final class FeatureFlagsVariableStore: VariableStore {
    @Variable var notifications = false
    @Variable var fastRefreshWidgets = false

    fileprivate init() {}
}
