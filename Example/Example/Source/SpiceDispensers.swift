//
//  SpiceDispensers.swift
//  Example
//
//  Created by Simon Støvring on 19/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation
import SHPSpices

final class ExampleSpiceDispenser: SpiceDispenser {
    static let shared = ExampleSpiceDispenser()
    
    let environment = EnvironmentSpiceDispenser.shared
    let showsDebugInfo: Spice<Bool> = Spice(false)
    let testUser: Spice<TestUser> = Spice(.userA)
    
    private init() {}
}

final class EnvironmentSpiceDispenser: SpiceDispenser {
    static let shared = EnvironmentSpiceDispenser()

    let serviceOne: Spice<Environment> = Spice(.development, requiresRestart: true)
    let serviceTwo: Spice<Environment> = Spice(.development, requiresRestart: true)
    let all: Spice<Environment> = Spice(requiresRestart: true, didSelect: { newValue in
        EnvironmentSpiceDispenser.shared.serviceOne.setValue(newValue)
        EnvironmentSpiceDispenser.shared.serviceTwo.setValue(newValue)
    })

    private init() {}
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
