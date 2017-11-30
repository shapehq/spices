//
//  SpiceDispenser.swift
//  Spices
//
//  Created by Simon Støvring on 19/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation

public protocol SpiceDispenser {
    var store: UserDefaults { get }
}

public extension SpiceDispenser {
    public var store: UserDefaults {
        return .standard
    }
    
    public func prepare() {
        updateKeys(path: [])
    }
    
    internal func updateKeys(path: [String]) {
        let spicyMirror = Mirror(reflecting: self)
        for (name, value) in spicyMirror.children {
            guard let name = name else { continue }
            if let spiceDispenser = value as? SpiceDispenser {
                spiceDispenser.updateKeys(path: path + [name])
            } else if var spice = value as? SpiceType {
                spice.key = key(from: path + [name])
                spice.store = store
            }
        }
    }
    
    internal func allSpices() -> [AnySpice] {
        var spices: [AnySpice] = []
        let spicyMirror = Mirror(reflecting: self)
        for (_, value) in spicyMirror.children {
            if let spice = value as? SpiceType {
                spices.append(AnySpice(spice))
            }
        }
        return spices
    }
    
    internal func validateValues() {
        let spicyMirror = Mirror(reflecting: self)
        for (name, value) in spicyMirror.children {
            guard let name = name else { continue }
            if let spiceDispenser = value as? SpiceDispenser {
                spiceDispenser.validateValues()
            } else if var spice = value as? SpiceType {
                spice.validateCurrentValue()
            }
        }
    }
    
    private func key(from path: [String]) -> String {
        return path.joined(separator: ".")
    }
}

