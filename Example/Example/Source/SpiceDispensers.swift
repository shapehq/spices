import Foundation
import SHPSpices

final class RootSpiceDispenser: SpiceDispenser {
    static let shared = RootSpiceDispenser()

    let environment: Spice<Environment> = Spice(.production, requiresRestart: true)
    let testUser: Spice<TestUser> = Spice(.userA)
    let showsDebugInfo: Spice<Bool> = Spice(false)
    let clearCache = Spice<SpiceButton> { completion in
        URLCache.shared.removeAllCachedResponses()
        completion(nil)
    }
    let featureFlags: FeatureFlagsSpiceDispenser = .shared

    private init() {}
}

final class FeatureFlagsSpiceDispenser: SpiceDispenser {
    static let shared = FeatureFlagsSpiceDispenser()

    let enableInAppSupport: Spice<Bool> = Spice(false, name: "Enable In-App Support")
    let enableNewIAPFlow: Spice<Bool> = Spice(false, name: "Enable New IAP Flow")
    let enableOfflineMode: Spice<Bool> = Spice(false)

    private init() {}
}

enum Environment: String, CaseIterable, SpiceEnum {
    case production
    case staging

    var title: String? {
        switch self {
        case .production:
            "🚀 Production"
        case .staging:
            "🧪 Staging"
        }
    }
}

enum TestUser: String, SpiceEnum {
    case userA
    case userB
    case userC

    static func validCases() -> [Self] {
        switch RootSpiceDispenser.shared.environment.value {
        case .production:
            [.userA, .userB]
        case .staging:
            [.userC]
        }
    }
}
