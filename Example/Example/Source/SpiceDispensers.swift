//
//  SpiceDispensers.swift
//  Example
//
//  Created by Simon Støvring on 19/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation
import SHPSpices

enum MyError: Error {
    case itWentBad
}

final class ExampleSpiceDispenser: SpiceDispenser {
    static let shared = ExampleSpiceDispenser()
    
    let environment = EnvironmentSpiceDispenser.shared
    let sslPinning = SSLPinningDispenser.shared
    let showsDebugInfo: Spice<Bool> = Spice(false)
    let testUser: Spice<TestUser> = Spice(.userA)
    let doTheBoogie = Spice<SpiceButton>(name: "Don't blame it on the boogie") { completion in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIApplication.shared.open(URL(string: "https://www.youtube.com/watch?v=mkBS4zUjJZo")!)
            completion(nil)
        }
    }
    let tourDeFranceWinner = Spice<TourDeFranceWinner>(.jakobFuglsang, hasButtonBehaviour: false) { newValue, completion in
        print(newValue)
        completion(nil)
    }
    
    private init() {}
}

final class EnvironmentSpiceDispenser: SpiceDispenser {
    static let shared = EnvironmentSpiceDispenser()
    
    let serviceOne: Spice<Environment> = Spice(.development, requiresRestart: true)
    let serviceTwo: Spice<Environment> = Spice(.development, requiresRestart: true)
    let all: Spice<Environment> = Spice(requiresRestart: true, didSelect: { newValue, completion in
        EnvironmentSpiceDispenser.shared.serviceOne.setValue(newValue)
        EnvironmentSpiceDispenser.shared.serviceTwo.setValue(newValue)
        completion(nil)
    })
    
    private init() {}
}

final class SSLPinningDispenser: SpiceDispenser {
    fileprivate static let shared = SSLPinningDispenser()
    
    let title: String? = "SSL Pinning"
    let catalogService = Spice(true, requiresRestart: true)
    let bookingService = Spice(true, requiresRestart: true)
    let accountService = Spice(true, requiresRestart: true)
    let all = Spice<EnabledDisabled>(requiresRestart: true) { state, completion in
        let isEnabled = state == .enabled
        SSLPinningDispenser.shared.catalogService.setValue(isEnabled)
        SSLPinningDispenser.shared.bookingService.setValue(isEnabled)
        SSLPinningDispenser.shared.accountService.setValue(isEnabled)
        completion(nil)
    }
}

enum Environment: String, SpiceEnum {
    case production
    case development
    
    var title: String? {
        switch self {
        case .production: return "😎 Production"
        case .development: return "🤓 Development"
        }
    }
}

enum TourDeFranceWinner: String, CaseIterable {
    case peterSagan
    case markCavendish
    case jakobFuglsang
}

enum TestUser: Int, SpiceEnum {
    case userA
    case userB
    case userC
    
    static func validCases() -> [TestUser] {
        switch ExampleSpiceDispenser.shared.environment.serviceOne.value {
        case .production: return [ .userA, .userB ]
        case .development: return [ .userC ]
        }
    }
}

enum EnabledDisabled: String, CaseIterable {
    case enabled
    case disabled
}
