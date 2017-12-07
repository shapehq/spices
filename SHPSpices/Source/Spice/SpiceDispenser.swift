//
//  SpiceDispenser.swift
//  Spices
//
//  Created by Simon Støvring on 19/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation

enum SpiceDispenserProperty {
    case spiceDispenser(String, SpiceDispenser)
    case spice(String, SpiceType)
}

public protocol SpiceDispenser: class {
    var store: UserDefaults { get }
    var title: String? { get }
}

public extension SpiceDispenser {
    var title: String? {
        return nil
    }
}

public extension SpiceDispenser {
    public var store: UserDefaults {
        return UserDefaults(suiteName: "dk.shape.SpiceDispenser") ?? .standard
    }
    
    public func prepare() {
        recursivePrepare(rootSpiceDispenser: self, path: [])
        validateValues()
    }
    
    internal func recursivePrepare(rootSpiceDispenser: SpiceDispenser, path: [String]) {
        properties().forEach { property in
            switch property {
            case .spiceDispenser(let name, let spiceDispenser):
                spiceDispenser.recursivePrepare(rootSpiceDispenser: rootSpiceDispenser, path: path + [name])
            case .spice(let name, var spice):
                spice.rootSpiceDispenser = rootSpiceDispenser
                spice.key = key(from: path + [name])
                spice.store = store
            }
        }
    }
    
    internal func validateValues() {
        properties().forEach { property in
            switch property {
            case .spiceDispenser(_, let spiceDispenser):
                return spiceDispenser.validateValues()
            case .spice(_, let spice):
                spice.validateCurrentValue()
            }
        }
    }
    
    internal func properties() -> [SpiceDispenserProperty] {
        let spicyMirror = Mirror(reflecting: self)
        return spicyMirror.children.flatMap { name, value in
            guard let name = name else { return nil }
            if let spiceDispenser = value as? SpiceDispenser {
                return .spiceDispenser(name, spiceDispenser)
            } else if let spice = value as? SpiceType {
                return .spice(name, spice)
            } else {
                return nil
            }
        }
    }
    
    private func key(from path: [String]) -> String {
        return path.joined(separator: ".")
    }
}

