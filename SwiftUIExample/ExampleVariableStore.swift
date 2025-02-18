import SHPSpices

enum ServiceEnvironment: String, CaseIterable {
    case production
    case staging
}

final class ExampleVariableStore: VariableStore {
    @Variable var environment: ServiceEnvironment = .production
    @Variable var enableLogging = false
    let featureFlags = FeatureFlagsVariableStore()
}

final class FeatureFlagsVariableStore: VariableStore {
    @Variable var notifications = false
    @Variable var fastRefreshWidgets = false
}
