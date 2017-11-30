//
//  SpiceEnum.swift
//  Spices
//
//  Created by Simon Støvring on 20/11/2017.
//  Copyright © 2017 Shape. All rights reserved.
//

import Foundation

public protocol SpiceEnum: Hashable {
    var title: String? { get }
    static func validCases() -> [Self]
    static func validate(currentValue: Self) -> Self
}

public extension SpiceEnum {
    var title: String? {
        return nil
    }
    
    static func validCases() -> [Self] {
        return Self.shp_allCases()
    }
    
    static func validate(currentValue: Self) -> Self {
        let validCases = self.validCases()
        if validCases.contains(currentValue) {
            // The current value is valid.
            return currentValue
        } else {
            // Find another value or allow the current value in worst case.
            return validCases.first ?? currentValue
        }
    }
}

extension SpiceEnum {
    static func shp_allCases() -> [Self] {
        return Array(shp_cases())
    }
    
    static func shp_cases() -> AnySequence<Self> {
        typealias S = Self
        return AnySequence { () -> AnyIterator<S> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) {
                    $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee }
                }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
    }
}
