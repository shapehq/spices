//
//  SpiceDispensers.swift
//  Example
//
//  Created by Simon Støvring on 19/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation
import Spices

final class ExampleSpiceDispenser: SpiceDispenser {
    static let shared = ExampleSpiceDispenser()
    
    let general = GeneralSpiceDispenser.shared
    let showsDebugInfo: Spice<Bool> = Spice(false)
    let testUser: Spice<TestUser> = Spice(.userA)
    
    private init() {}
}

final class GeneralSpiceDispenser: SpiceDispenser {
    static let shared = GeneralSpiceDispenser()

    let environment: Spice<Environment> = Spice(.development)

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
        switch ExampleSpiceDispenser.shared.general.environment.value {
        case .production: return [ .userA, .userB ]
        case .development: return [ .userC ]
        }
    }
}
